CREATE PROCEDURE uspPostBill
	@batchId			AS NVARCHAR(20)		= '',
	@journalType		AS NVARCHAR(30)		= '',
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= '',
	@userId				AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@recapId			AS NVARCHAR(250)	=  NEWID OUTPUT
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

CREATE TABLE #tmpValidBillData (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
);

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@param, '') <> '') 
	INSERT INTO #tmpPostBillData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
--ELSE IF Provision for Date Begin and Date End Parameter
--ELSE IF Provision for Journal Begin and Journal End Parameter
ELSE
	INSERT INTO #tmpPostBillData SELECT [intBillId] FROM tblAPBill

--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpValidBillData
	SELECT DISTINCT A.[intBillId]
	FROM tblAPBill A 
	WHERE  A.[intBillId] IN (SELECT [intBillId] FROM #tmpPostBillData) AND 
		1 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDate]), 0)

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		UPDATE tblAPBill
			SET ysnPosted = 0
		FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpValidBillData)

	END
	ELSE
	BEGIN
		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
		)
		INSERT INTO tblGLDetail (
			[strTransactionID], 
			[intAccountID],
			[strDescription],
			[strReference],
			[dtmTransactionDate],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[dtmDate],
			[ysnIsUnposted],
			[intConcurrencyID],
			[dblExchangeRate],
			[intUserID],
			[dtmDateEntered],
			[strBatchID],
			[strCode],
			[strModuleName],
			[strTransactionForm]
		)
		--CREDIT
		SELECT	
			[strTransactionID] = A.strBillId, 
			[intAccountID] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = 0,
			[dblCredit] = A.dblTotal,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyID] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpValidBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[strTransactionID] = A.strBillId, 
			[intAccountID] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = B.dblTotal, --Bill Detail
			[dblCredit] = 0, -- Bill
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyID] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpValidBillData)
	
		UPDATE tblAPBill
			SET ysnPosted = 1
		WHERE tblAPBill.intBillId IN (SELECT intBillId FROM #tmpValidBillData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session

		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
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
			[strTransactionID] = A.strBillId, 
			[intAccountID] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = 0,
			[dblCredit] = A.dblTotal,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyID] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpValidBillData)
	
		--DEBIT
		UNION ALL 
		SELECT	
			[strTransactionID] = A.strBillId, 
			[intAccountID] = A.intAccountId,
			[strDescription] = A.strDescription,
			[strReference] = A.strVendorId,
			[dtmTransactionDate] = A.dtmDate,
			[dblDebit] = B.dblTotal,
			[dblCredit] = 0,
			[dblDebitUnit]			= ISNULL(A.[dblTotal], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dblCreditUnit]		= ISNULL(A.[dblTotal], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0),
			[dtmDate] = A.dtmDate,
			[ysnIsUnposted] = 0,
			[intConcurrencyID] = 1,
			[dblExchangeRate]		= 1,
			[intUserID]			= @userId,
			[dtmDateEntered]		= GETDATE(),
			[strBatchID]			= @batchId,
			[strCode]				= 'AP',
			[strModuleName]		= @MODULE_NAME,
			[strTransactionForm] = A.intBillId
		FROM	[dbo].tblAPBill A LEFT JOIN [dbo].tblAPBillDetail B
					ON A.intBillId = B.intBillId
		WHERE	A.intBillId IN (SELECT intBillId FROM #tmpValidBillData)

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
SELECT @successfulCount = COUNT(*) FROM #tmpValidBillData

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
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpPostBillData')) DROP TABLE #tmpPostBillData
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpValidBillData')) DROP TABLE #tmpValidBillData
GO