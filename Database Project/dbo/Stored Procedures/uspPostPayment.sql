CREATE PROCEDURE uspPostPayment
	@batchId			AS NVARCHAR(20)		= '',
	@journalType		AS NVARCHAR(30)		= '',
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= '',
	@userId				AS INT				= 1,
	@successfulCount	AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@recapId			AS NVARCHAR(250)	=  NEWID OUTPUT
	--OUTPUT Parameter for GUID
	--Provision for Date Begin and Date End Parameter
	--Provision for Journal Begin and Journal End Parameter
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
-- Start the transaction 
BEGIN TRANSACTION

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostData (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

CREATE TABLE #tmpValidData (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@param, '') <> '') 
	INSERT INTO #tmpPostData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
--ELSE IF Provision for Date Begin and Date End Parameter
--ELSE IF Provision for Journal Begin and Journal End Parameter
ELSE
	INSERT INTO #tmpPostData SELECT [intPaymentId] FROM tblAPPayment

--=====================================================================================================================================
-- 	POPULATE VALID JOURNALS TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #tmpValidData
	SELECT DISTINCT A.[intPaymentId]
	FROM tblAPPayment A 
	WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPostData) AND 
		1 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)

SELECT @successfulCount = COUNT(*) FROM #tmpValidData

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		UPDATE tblAPPayment
			SET ysnPosted = 0
		FROM tblAPPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)

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
			 [strPaymentRecordNum]
			,(SELECT intAccountID FROM tblGLAccount WHERE intAccountID = (SELECT intGLAccountID FROM tblCMBankAccount WHERE intBankAccountID = A.intBankAccountId))
			,'Posted Payable'
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmountPaid
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserID]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountID
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		--Withheld
		UNION
		SELECT
			 [strPaymentRecordNum]
			,(SELECT intWithholdAccountId FROM tblAPPreference)
			,'Posted Payable'
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblWithheldAmount
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserID]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountID
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		---- DEBIT SIDE
		UNION ALL 
		SELECT	[strPaymentRecordNum]
				,C.[intAccountId]
				,'Posted Payable'
				,A.[strVendorId]
				,A.dtmDatePaid
				,[dblDebit]				= B.dblPayment
				,[dblCredit]			= 0
				,[dblDebitUnit]			= ISNULL(B.dblPayment, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(B.dblPayment, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserID]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchID]			= @batchId
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		

		-- Update the posted flag in the transaction table
		UPDATE tblAPPayment
		SET		ysnPosted = 1
				--,intConcurrencyID += 1 
		WHERE	intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)


		--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
		UPDATE tblAPBill
			SET tblAPBill.dblAmountDue = (C.dblTotal - B.dblPayment),
								--GROUP BY A.intPaymentId,C.dblTotal, C.intBillId),
				tblAPBill.ysnPaid = (CASE WHEN C.dblAmountDue = 0 THEN 1 ELSE 0 END)
		FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C
							ON B.intBillId = C.intBillId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData) AND C.intBillId = C.intBillId

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE strTransactionID IN (SELECT CAST(intPaymentId AS NVARCHAR(50)) FROM #tmpValidData);

		--GO

		WITH Units 
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
		)
		INSERT INTO tblGLDetailRecap (
			 [strTransactionID]
			,[intAccountID]
			,[strDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyID]	
			,[dblExchangeRate]
			,[intUserID]
			,[dtmDateEntered]
			,[strBatchID]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
		)
		--CREDIT SIDE
		SELECT
			 CAST(A.intPaymentId AS NVARCHAR(50))--[strPaymentRecordNum]
			,(SELECT intAccountID FROM tblGLAccount WHERE intAccountID = (SELECT intGLAccountID FROM tblCMBankAccount WHERE intBankAccountID = A.intBankAccountId))
			,'Posted Payable'
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmountPaid
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserID]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			LEFT JOIN tblAPPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		--Withheld
		UNION
		SELECT
			 CAST(A.intPaymentId AS NVARCHAR(50))--[strPaymentRecordNum]
			,(SELECT intWithholdAccountId FROM tblAPPreference)
			,'Posted Payable'
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblWithheldAmount
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserID]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchID]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountID
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		---- DEBIT SIDE
		UNION ALL 
		SELECT	CAST(A.intPaymentId AS NVARCHAR(50))--[strPaymentRecordNum]
				,C.[intAccountId]
				,'Posted Payable'
				,A.[strVendorId]
				,A.dtmDatePaid
				,[dblDebit]				= B.dblPayment
				,[dblCredit]			= 0
				,[dblDebitUnit]			= ISNULL(B.dblPayment, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(B.dblPayment, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserID]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchID]			= @batchId
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpValidData)
		--GROUP BY A.intPaymentId, B.intAccountId, A.dtmDatePaid

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
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------

--UPDATE	tblGLSummary 
--SET		 [dblDebit] = ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
--		,[dblCredit] = ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
--		,[intConcurrencyID] = ISNULL([intConcurrencyID], 0) + 1
--FROM	(
--			SELECT	 [dblDebit]		= SUM(ISNULL(B.[dblDebit], 0))
--					,[dblCredit]	= SUM(ISNULL(B.[dblCredit], 0))
--					,[intAccountID] = A.[intAccountID]
--					,[dtmDate]		= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
--			FROM tblGLSummary A 
--					INNER JOIN JournalDetail B 
--					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountID] = B.[intAccountID]			
--			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID]
--		) AS GLDetailGrouped
--WHERE tblGLSummary.[intAccountID] = GLDetailGrouped.[intAccountID] AND 
--	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

--IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
--WITH Units
--AS 
--(
--	SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
--	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
--),
--JournalDetail 
--AS
--(
--	SELECT [dtmDate]		= ISNULL(B.[dtmDate], GETDATE())
--		,[intAccountID]		= A.[intAccountID]
--		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
--									WHEN [dblDebit] < 0 THEN 0
--									ELSE [dblDebit] END 
--		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
--									WHEN [dblCredit] < 0 THEN 0
--									ELSE [dblCredit] END	
--		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
--		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountID] = A.[intAccountID]), 0)
--	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalID] = B.[intJournalID]
--	WHERE B.intJournalID IN (SELECT [intJournalID] FROM #tmpValidJournals)
--)
--INSERT INTO tblGLSummary (
--	 [intAccountID]
--	,[dtmDate]
--	,[dblDebit]
--	,[dblCredit]
--	,[dblDebitUnit]
--	,[dblCreditUnit]
--	,[intConcurrencyID]
--)
--SELECT	
--	 [intAccountID]		= A.[intAccountID]
--	,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
--	,[dblDebit]			= SUM(A.[dblDebit])
--	,[dblCredit]		= SUM(A.[dblCredit])
--	,[dblDebitUnit]		= SUM(A.[dblDebitUnit])
--	,[dblCreditUnit]	= SUM(A.[dblCreditUnit])
--	,[intConcurrencyID] = 1
--FROM JournalDetail A
--WHERE NOT EXISTS 
--		(
--			SELECT TOP 1 1
--			FROM tblGLSummary B
--			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
--				  A.[intAccountID] = B.[intAccountID]
--		)
--GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID];

--IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @recapId = (SELECT TOP 1 intPaymentId FROM #tmpValidData) --only support recap per record
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION		            
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpPostData')) DROP TABLE #tmpPostData
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpValidData')) DROP TABLE #tmpValidData
GO