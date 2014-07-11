CREATE PROCEDURE uspAPPostBill
	@batchId			AS NVARCHAR(20)		= NULL,
	@billBatchId		AS NVARCHAR(20)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT				= 1,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
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
	[strBatchNumber] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--DECLARRE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'

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

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--POSTING VALIDATIONS
	IF(ISNULL(@post,0) = 1)
	BEGIN

		--Fiscal Year
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)

		--No Terms specified
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'No terms has been specified.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			0 = A.intTermsId

		--NOT BALANCE
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The debit and credit amounts are not balanced.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			A.dblTotal <> (SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = A.intBillId)

		--ALREADY POSTED
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The transaction is already posted.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			A.ysnPosted = 1

		--Header Account ID
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			'The AP account is not specified.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			A.intAccountId IS NULL AND A.intAccountId = 0

		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			'The account id on one of the details is not specified.',
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			1 = (SELECT 1 FROM tblAPBillDetail B 
					WHERE B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData)
							AND (B.intAccountId IS NULL AND B.intAccountId = 0))

	END 

	--UNPOSTING VALIDATIONS
	IF(ISNULL(@post,0) = 0)
	BEGIN
		--ALREADY HAVE PAYMENTS
		INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			A.strPaymentRecordNum + ' payment was already made on this bill.',
			'Bill',
			C.intBillId,
			@batchId,
			C.intBillId
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  C.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData)
	END

	DECLARE @totalInvalid INT = 0
	SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidBillData

	IF(@totalInvalid > 0)
	BEGIN

		--Insert Invalid Post transaction result
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT * FROM #tmpInvalidBillData

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

	IF(@totalRecords = 0)  
	BEGIN
		SET @success = 0
		GOTO Post_Exit
	END

	BEGIN TRANSACTION
END
--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0

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
		WHERE strTransactionId IN (SELECT strBillId FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))

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
		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
		)
		INSERT INTO tblGLDetail (
			[intTransactionId], 
			[intAccountId],
			[strDescription],
			[strReference],
			[dtmTransactionDate],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[dtmDate],
			[ysnIsUnposted],
			[intConcurrencyId],
			[dblExchangeRate],
			[intUserId],
			[intEntityId],
			[dtmDateEntered],
			[strBatchId],
			[strCode],
			[strModuleName],
			[strTransactionForm],
			[strTransactionType]
		)
		--CREDIT
		SELECT	
			[intTransactionId] = A.intBillId, 
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = C.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = 0,
			[dblCredit] = A.dblTotal,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyId] = 1,
			[dblExchangeRate]		= 1,
			[intUserId]			= @userId,
			[intEntityId]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = @SCREEN_NAME,
			[strTransactionType] = CASE WHEN intTransactionType = 1 THEN 'Bill'
										WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
										WHEN intTransactionType = 3 THEN 'Debit Memo'
									ELSE 'NONE' END
		FROM	[dbo].tblAPBill A
				LEFT JOIN tblAPVendor C
					ON A.intVendorId = C.intEntityId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[intTransactionId] = A.intBillId, 
			[intAccountId] = B.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = C.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = B.dblTotal, --Bill Detail
			[dblCredit] = 0, -- Bill
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyId] = 1,
			[dblExchangeRate]		= 1,
			[intUserId]			= @userId,
			[intEntityId]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = @SCREEN_NAME,
			[strTransactionType] = CASE WHEN intTransactionType = 1 THEN 'Bill'
										WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
										WHEN intTransactionType = 3 THEN 'Debit Memo'
									ELSE 'NONE' END
		FROM	[dbo].tblAPBill A 
				LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
				LEFT JOIN tblAPVendor C
					ON A.intVendorId = C.intEntityId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		UPDATE tblAPBill
			SET ysnPosted = 1
		WHERE tblAPBill.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

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
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intBillId FROM #tmpPostBillData);

		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
		)
		INSERT INTO tblGLDetailRecap (
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
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
			[strTransactionId] = A.strBillId, 
			[intTransactionId] = A.intBillId,
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = C.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = 0,
			[dblCredit] = A.dblTotal,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyId] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = @SCREEN_NAME,
			[strTransactionType] = CASE WHEN intTransactionType = 1 THEN 'Bill'
										WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
										WHEN intTransactionType = 3 THEN 'Debit Memo'
									ELSE 'NONE' END
		FROM	[dbo].tblAPBill A
		LEFT JOIN tblAPVendor C
					ON A.intVendorId = C.intEntityId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[strTransactionId] = A.strBillId, 
			[intTransactionId] = A.intBillId,
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = C.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = B.dblTotal,
			[dblCredit] = 0,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyId] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = @SCREEN_NAME,
			[strTransactionType] = CASE WHEN intTransactionType = 1 THEN 'Bill'
										WHEN intTransactionType = 2 THEN 'Vendor Prepayment'
										WHEN intTransactionType = 3 THEN 'Debit Memo'
									ELSE 'NONE' END
		FROM	[dbo].tblAPBill A 
				LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
				LEFT JOIN tblAPVendor C
					ON A.intVendorId = C.intEntityId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

--=====================================================================================================================================
-- 	UPDATE STARTING NUMBERS
---------------------------------------------------------------------------------------------------------------------------------------
--UPDATE tblSMStartingNumber
--SET [intNumber] = ISNULL([intNumber], 0) + 1
--WHERE [strTransactionType] = 'Batch Post';


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

		
			----removed from tblAPInvalidTransaction the successful records
			--DELETE FROM tblAPPostResult
			--FROM tblAPPostResult A
			--INNER JOIN #tmpPostBillData B ON A.intTransactionId = B.intBillId 

		END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPostBillData')) DROP TABLE #tmpPostBillData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvalidBillData')) DROP TABLE #tmpInvalidBillData