CREATE PROCEDURE uspAPPostBill
	@batchId			AS NVARCHAR(20)		= NULL,
	@billBatchId		AS NVARCHAR(20)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@isBatch			AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@exclude			AS NVARCHAR(MAX)	= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
-- Start the transaction 
BEGIN TRANSACTION

IF @userId IS NULL
BEGIN
	RAISERROR('User is required', 16, 1);
END

--DECLARE @success BIT
--DECLARE @successfulCount INT
--EXEC uspPostBill '', '', 1, 0, 12, 1, @success OUTPUT, @successfulCount OUTPUT

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostBillData (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
);

CREATE TABLE #tmpInvalidBillData (
	[strError] [NVARCHAR](100),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--DECLARRE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @GLEntries AS RecapTableType 
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
DECLARE @validBillIds NVARCHAR(MAX)
DECLARE @billIds NVARCHAR(MAX) = @param

SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@param IS NOT NULL) 
BEGIN
	IF(@param = 'all')
	BEGIN
		INSERT INTO #tmpPostBillData SELECT intBillId FROM tblAPBill WHERE ysnPosted = 0
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPostBillData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
	END
END


IF (@billBatchId IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT B.intBillId FROM tblAPBillBatch A
			LEFT JOIN tblAPBill B	
				ON A.intBillBatchId = B.intBillBatchId
	WHERE A.intBillBatchId = @billBatchId
END
	
IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT intBillId FROM tblAPBill
	WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate AND ysnPosted = 0
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT intBillId FROM tblAPBill
	WHERE intBillId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
END

--Removed excluded bills to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT [intID] INTO #tmpBillsExclude FROM [dbo].fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPostBillData A
	WHERE EXISTS(SELECT * FROM #tmpBillsExclude B WHERE A.intBillId = B.intID)
END

--SET THE UPDATED @billIds
SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--VALIDATIONS
	INSERT INTO #tmpInvalidBillData 
	SELECT * FROM fnAPValidatePostBill(@billIds, @post)

	DECLARE @totalInvalid INT = 0
	SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidBillData

	IF(@totalInvalid > 0)
	BEGIN

		--Insert Invalid Post transaction result
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT strError, strTransactionType, strTransactionId, @batchId, intTransactionId FROM #tmpInvalidBillData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE #tmpPostBillData
			FROM #tmpPostBillData A
				INNER JOIN #tmpInvalidBillData
					ON A.intBillId = #tmpInvalidBillData.intTransactionId

	END

	DECLARE @totalRecords INT
	SELECT @totalRecords = COUNT(*) FROM #tmpPostBillData

	COMMIT TRANSACTION --COMMIT inserted invalid transaction

	IF(@totalRecords = 0 OR (@isBatch = 0 AND @totalInvalid > 0))  
	BEGIN
		SET @success = 0
		GOTO Post_Exit
	END

	BEGIN TRANSACTION
END

--CREATE TEMP GL ENTRIES
SELECT @validBillIds = COALESCE(@validBillIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

IF ISNULL(@post,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPCreateBillGLEntries(@validBillIds, @userId, @batchId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@validBillIds, 'Bill', DEFAULT, @userId, @batchId)
END
--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0
BEGIN

	EXEC uspGLBookEntries @GLEntries, @post

	IF(ISNULL(@post,0) = 0)
	BEGIN

		IF(@billBatchId IS NOT NULL AND @totalRecords > 0)
		BEGIN
			UPDATE tblAPBillBatch
				SET ysnPosted = 0
				FROM tblAPBillBatch WHERE intBillBatchId = @billBatchId
		END

		UPDATE tblAPBill
			SET ysnPosted = 0,
				ysnPaid = 0
		FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		UPDATE tblGLDetail
			SET ysnIsUnposted = 1
		WHERE tblGLDetail.[strTransactionId] IN (SELECT strBillId FROM tblAPBill WHERE intBillId IN 
				(SELECT intBillId FROM #tmpPostBillData))

		--Update Inventory Item Receipt
		UPDATE A
			SET A.dblBillQty = A.dblBillQty - B.dblQtyReceived
		FROM tblICInventoryReceiptItem A
			INNER JOIN tblAPBillDetail B ON B.intItemReceiptId = A.intInventoryReceiptItemId
		AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData)

		--Insert Successfully unposted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			@UnpostSuccessfulMsg,
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A
		WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

	END
	ELSE
	BEGIN

		UPDATE tblAPBill
			SET ysnPosted = 1
		WHERE tblAPBill.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--Update Inventory Item Receipt
		UPDATE A
			SET A.dblBillQty = A.dblBillQty + B.dblQtyReceived
		FROM tblICInventoryReceiptItem A
			INNER JOIN tblAPBillDetail B ON B.intItemReceiptId = A.intInventoryReceiptItemId
		AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData)

		--Insert Successfully posted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg,
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A
		WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		IF @@ERROR <> 0	GOTO Post_Rollback;

	END
END
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intBillId FROM #tmpPostBillData);

		INSERT INTO tblGLDetailRecap (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
		)
		SELECT
			[strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
		FROM @GLEntries

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	SELECT * FROM #tmpPostBillData
	GOTO Post_Cleanup
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Cleanup:
	IF(ISNULL(@recap,0) = 0)
	BEGIN

		IF(@post = 1)
		BEGIN
			--clean gl detail recap after posting
			DELETE FROM tblGLDetailRecap
			FROM tblGLDetailRecap A
			INNER JOIN #tmpPostBillData B ON A.intTransactionId = B.intBillId 
		END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPostBillData')) DROP TABLE #tmpPostBillData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvalidBillData')) DROP TABLE #tmpInvalidBillData