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
	[strBatchNumber] [NVARCHAR](50)
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@param IS NOT NULL) 
BEGIN
	INSERT INTO #tmpPostBillData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
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
	WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT intBillId FROM tblAPBill
	WHERE intBillId BETWEEN @beginTransaction AND @endTransaction
END

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------

--Fiscal Year
IF(ISNULL(@post,0) = 1)
BEGIN
	INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Bill',
			A.intBillId,
			@batchId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)

	INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber)
		SELECT 
			'No terms has been specified.',
			'Bill',
			A.intBillId,
			@batchId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			0 = A.intTermsId
END 

IF(ISNULL(@post,0) = 1)
BEGIN
--NOT BALANCE
INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber)
	SELECT 
		'The debit and credit amounts are not balanced.',
		'Bill',
		A.intBillId,
		@batchId
	FROM tblAPBill A 
	WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
		A.dblTotal <> (SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = A.intBillId)
END

--ALREADY HAVE PAYMENTS
IF(ISNULL(@post,0) = 0)
BEGIN
INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber)
	SELECT
		A.strPaymentRecordNum + ' payment was already made on this bill.',
		'Bill',
		C.intBillId,
		@batchId
	FROM tblAPPayment A
		INNER JOIN tblAPPaymentDetail B 
			ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblAPBill C
			ON B.intBillId = C.intBillId
	WHERE  C.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData)
END

--ALREADY POSTED
IF(ISNULL(@post,0) = 1)
BEGIN
	INSERT INTO #tmpInvalidBillData(strError, strTransactionType, strTransactionId, strBatchNumber)
		SELECT 
			'The transaction is already posted.',
			'Bill',
			A.intBillId,
			@batchId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
			A.ysnPosted = 1

END

DECLARE @totalInvalid INT = 0
SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidBillData

IF(@totalInvalid > 0)
BEGIN

	INSERT INTO tblAPInvalidTransaction(strError, strTransactionType, strTransactionId, strBatchNumber)
	SELECT * FROM #tmpInvalidBillData

	SET @invalidCount = @totalInvalid

	--DELETE Invalid Transaction From temp table
	DELETE FROM #tmpPostBillData
	FROM tblAPInvalidTransaction
	WHERE #tmpPostBillData.intBillId = CAST(tblAPInvalidTransaction.strTransactionId AS INT)

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

		--removed from tblAPInvalidTransaction the successful records
		DELETE FROM tblAPInvalidTransaction
		WHERE CAST(strTransactionId AS NVARCHAR(50)) IN (SELECT intBillId FROM #tmpPostBillData)

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
			[strTransactionId], 
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
			[dtmDateEntered],
			[strBatchId],
			[strCode],
			[strModuleName],
			[strTransactionForm]
		)
		--CREDIT
		SELECT	
			[strTransactionId] = A.strBillId, 
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
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
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[strTransactionId] = A.strBillId, 
			[intAccountId] = B.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = B.dblTotal, --Bill Detail
			[dblCredit] = 0, -- Bill
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
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		UPDATE tblAPBill
			SET ysnPosted = 1
		WHERE tblAPBill.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--removed from tblAPInvalidTransaction the successful records
		DELETE FROM tblAPInvalidTransaction
		WHERE CAST(strTransactionId AS NVARCHAR(50)) IN (SELECT intBillId FROM #tmpPostBillData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session

		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
		)
		INSERT INTO tblGLRecap (
			 [strTransactionId]
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
		)
		SELECT	
			[strTransactionId] = A.strBillId, 
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
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
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[strTransactionId] = A.strBillId, 
			[intAccountId] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
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
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

--=====================================================================================================================================
-- 	UPDATE STARTING NUMBERS
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE tblSMStartingNumber
SET [intNumber] = ISNULL([intNumber], 0) + 1
WHERE [strTransactionType] = 'Batch Post';

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------
SET @successfulCount = @totalRecords
--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION		            
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPostBillData')) DROP TABLE #tmpPostBillData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvalidBillData')) DROP TABLE #tmpInvalidBillData