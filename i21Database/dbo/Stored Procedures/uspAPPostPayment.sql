﻿CREATE PROCEDURE uspAPPostPayment
	@batchId			AS NVARCHAR(20)		= NULL,
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
CREATE TABLE #tmpPayablePostData (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

CREATE TABLE #tmpPayableInvalidData (
	[strError] [NVARCHAR](100),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[strBatchNumber] [NVARCHAR](50),
	[intTransactionId] INT
);

--DECLARRE VARIABLES
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
SET @recapId = '1'

--SET BatchId
IF(@batchId IS NULL)
BEGIN
	EXEC uspSMGetStartingNumber 3, @batchId OUT
END

SET @batchIdUsed = @batchId

--=====================================================================================================================================
-- 	POPULATE TRANSACTIONS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@param IS NOT NULL) 
BEGIN
	IF(@param = 'all')
	BEGIN
		INSERT INTO #tmpPayablePostData SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 0
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPayablePostData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
	END
END

IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpPayablePostData
	SELECT intPaymentId FROM tblAPPayment
	WHERE dtmDatePaid BETWEEN @beginDate AND @endDate
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPayablePostData
	SELECT intPaymentId FROM tblAPPayment
	WHERE intPaymentId BETWEEN @beginTransaction AND @endTransaction
END

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN
--Fiscal Year
IF(ISNULL(@post,0) = 1)
	BEGIN
		INSERT INTO #tmpPayableInvalidData
			SELECT 
				'Unable to find an open fiscal year period to match the transaction date.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A 
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData) AND 
				0 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)
	END

	--NOT BALANCE
	IF(ISNULL(@post,0) = 1)
	BEGIN
		INSERT INTO #tmpPayableInvalidData
			SELECT 
				'The debit and credit amounts are not balanced.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A 
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData) AND 
				(A.dblAmountPaid + A.dblWithheldAmount) <> (SELECT SUM(dblPayment) + SUM(dblDiscount) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId)
	END

	--ALREADY POSTED
	IF(ISNULL(@post,0) = 1)
	BEGIN
		INSERT INTO #tmpPayableInvalidData
			SELECT 
				'The transaction is already posted.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A 
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData) AND 
				A.ysnPosted = 1
	END

	--Already cleared/reconciled
	IF(ISNULL(@post,0) = 0)
	BEGIN
		INSERT INTO #tmpPayableInvalidData
			SELECT 
				'The transaction is already cleared.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A 
				INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
			WHERE B.ysnClr = 1
	END

	DECLARE @totalInvalid INT
	SET @totalInvalid = (SELECT COUNT(*) FROM #tmpPayableInvalidData)

	IF(@totalInvalid > 0)
	BEGIN

		INSERT INTO tblAPInvalidTransaction(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT * FROM #tmpPayableInvalidData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE #tmpPayablePostData
			FROM #tmpPayablePostData A
				INNER JOIN #tmpPayableInvalidData
					ON A.intPaymentId = #tmpPayableInvalidData.intTransactionId

	END


	DECLARE @totalRecords INT
	SELECT @totalRecords = COUNT(*) FROM #tmpPayablePostData

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
IF (ISNULL(@recap, 0) = 0)

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		--Unposting Process
		UPDATE tblAPPayment
			SET ysnPosted = 0
		FROM tblAPPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		UPDATE tblAPPaymentDetail
			SET tblAPPaymentDetail.dblAmountDue = B.dblAmountDue + B.dblPayment
		FROM tblAPPayment A
			LEFT JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
		UPDATE tblAPBill
			SET tblAPBill.dblAmountDue = (C.dblAmountDue + B.dblPayment),
				tblAPBill.ysnPaid = 0,
				tblAPBill.dtmDatePaid = NULL
		FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C
							ON B.intBillId = C.intBillId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		UPDATE tblGLDetail
			SET tblGLDetail.ysnIsUnposted = 1
		FROM tblAPPayment A
			INNER JOIN tblGLDetail B
				ON A.strPaymentRecordNum = B.strTransactionId

		--DELETE IF NOT CHECK PAYMENT
		DELETE FROM tblCMBankTransaction
		WHERE strTransactionId IN (
			SELECT strPaymentRecordNum 
			FROM tblAPPayment
				INNER JOIN tblSMPaymentMethod ON tblAPPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
			 WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData) 
			AND tblSMPaymentMethod.strPaymentMethod != 'Check'
		)

		--VOID IF CHECK PAYMENT
		UPDATE tblCMBankTransaction
		SET ysnCheckVoid = 1,
			ysnPosted = 0
		WHERE strTransactionId IN (
			SELECT strPaymentRecordNum 
			FROM tblAPPayment
			 WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData) 
		)

		--removed from tblAPInvalidTransaction the successful records
		DELETE FROM tblAPInvalidTransaction
		WHERE CAST(strTransactionId AS NVARCHAR(50)) IN (SELECT intPaymentId FROM #tmpPayablePostData)


	END
	ELSE
	BEGIN

		--POSTING
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
			 [strPaymentRecordNum]
			,(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmountPaid
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountId
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		--Withheld
		UNION
		SELECT
			 [strPaymentRecordNum]
			,(SELECT intWithholdAccountId FROM tblAPPreference)
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intWithholdAccountId FROM tblAPPreference))
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblWithheldAmount
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountId
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
				INNER JOIN tblAPVendor 
					ON A.strVendorId = tblAPVendor.strVendorId AND tblAPVendor.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		---- DEBIT SIDE
		UNION ALL 
		SELECT	[strPaymentRecordNum]
				,C.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = C.[intAccountId])
				,A.[strVendorId]
				,A.dtmDatePaid
				,[dblDebit]				= B.dblPayment
				,[dblCredit]			= 0
				,[dblDebitUnit]			= ISNULL(B.dblPayment, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(B.dblPayment, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @batchId
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblPayment <> 0
		

		-- Update the posted flag in the transaction table
		UPDATE tblAPPayment
		SET		ysnPosted = 1
				--,intConcurrencyId += 1 
		WHERE	intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		UPDATE tblAPPaymentDetail
			SET tblAPPaymentDetail.dblAmountDue = (B.dblTotal) - (B.dblPayment + B.dblDiscount)
		FROM tblAPPayment A
			LEFT JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)


		--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
		UPDATE tblAPBill
			SET tblAPBill.dblAmountDue = (C.dblAmountDue - (B.dblPayment + B.dblDiscount)),
				tblAPBill.ysnPaid = (CASE WHEN (C.dblAmountDue - (B.dblPayment + B.dblDiscount)) = 0 THEN 1 ELSE 0 END),
				tblAPBill.dtmDatePaid = (CASE WHEN (C.dblAmountDue - (B.dblPayment + B.dblDiscount)) = 0 THEN A.dtmDatePaid ELSE NULL END)
		FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C
							ON B.intBillId = C.intBillId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Insert to bank transaction
		INSERT INTO tblCMBankTransaction(
			[strTransactionId],
			[intBankTransactionTypeId],
			[intBankAccountId],
			[intCurrencyId],
			[dblExchangeRate],
			[dtmDate],
			[strPayee],
			[intPayeeId],
			[strAddress],
			[strZipCode],
			[strCity],
			[strState],
			[strCountry],
			[dblAmount],
			[strAmountInWords],
			[strMemo],
			[strReferenceNo],
			[ysnCheckToBePrinted],
			[ysnCheckVoid],
			[ysnPosted],
			[strLink],
			[ysnClr],
			[dtmDateReconciled],
			[intCreatedUserId],
			[dtmCreated],
			[intLastModifiedUserId],
			[dtmLastModified],
			[intConcurrencyId]
		)
		SELECT
			[strTransactionId] = A.strPaymentRecordNum,
			[intBankTransactionTypeID] = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AP Payment'),
			[intBankAccountID] = A.intBankAccountId,
			[intCurrencyID] = A.intCurrencyId,
			[dblExchangeRate] = 0,
			[dtmDate] = A.dtmDatePaid,
			[strPayee] = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.intEntityId),
			[intPayeeID] = B.intEntityId,
			[strAddress] = '',
			[strZipCode] = '',
			[strCity] = '',
			[strState] = '',
			[strCountry] = '',
			[dblAmount] = A.dblAmountPaid,
			[strAmountInWords] = dbo.fnConvertNumberToWord(A.dblAmountPaid),
			[strMemo] = '',
			[strReferenceNo] = '',
			[ysnCheckToBePrinted] = 0,
			[ysnCheckVoid] = 0,
			[ysnPosted] = 1,
			[strLink] = @batchId,
			[ysnClr] = 0,
			[dtmDateReconciled] = NULL,
			[intCreatedUserID] = @userId,
			[dtmCreated] = GETDATE(),
			[intLastModifiedUserID] = NULL,
			[dtmLastModified] = GETDATE(),
			[intConcurrencyId] = 1
			FROM tblAPPayment A
				INNER JOIN tblAPVendor B
					ON A.strVendorId = B.strVendorId
			WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
ELSE
	BEGIN

		--RECAP
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE strTransactionId IN (SELECT CAST(intPaymentId AS NVARCHAR(50)) FROM #tmpPayablePostData);

		--GO

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
		)
		--CREDIT SIDE
		SELECT
			 [strPaymentRecordNum]
			,A.intPaymentId
			,(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmountPaid
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
			LEFT JOIN tblAPPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblPayment <> 0
		--Withheld
		UNION
		SELECT
			 [strPaymentRecordNum]
			,A.intPaymentId
			,(SELECT intWithholdAccountId FROM tblAPPreference)
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intWithholdAccountId FROM tblAPPreference))
			,A.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblWithheldAmount
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountId
				INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
					ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId
				INNER JOIN tblAPVendor 
					ON A.strVendorId = tblAPVendor.strVendorId AND tblAPVendor.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		
		---- DEBIT SIDE
		UNION ALL 
		SELECT	[strPaymentRecordNum]
				,A.intPaymentId
				,C.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = C.[intAccountId])
				,A.[strVendorId]
				,A.dtmDatePaid
				,[dblDebit]				= B.dblPayment
				,[dblCredit]			= 0
				,[dblDebitUnit]			= ISNULL(B.dblPayment, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(B.dblPayment, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @batchId
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblPayment <> 0
		--GROUP BY A.intPaymentId, B.intAccountId, A.dtmDatePaid

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
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------

--UPDATE	tblGLSummary 
--SET		 [dblDebit] = ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
--		,[dblCredit] = ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
--		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
--FROM	(
--			SELECT	 [dblDebit]		= SUM(ISNULL(B.[dblDebit], 0))
--					,[dblCredit]	= SUM(ISNULL(B.[dblCredit], 0))
--					,[intAccountId] = A.[intAccountId]
--					,[dtmDate]		= ISNULL(CONVERT(DATE, A.[dtmDate]), '') 								
--			FROM tblGLSummary A 
--					INNER JOIN JournalDetail B 
--					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId]			
--			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
--		) AS GLDetailGrouped
--WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND 
--	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

--IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
--WITH Units
--AS 
--(
--	SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
--	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
--),
--JournalDetail 
--AS
--(
--	SELECT [dtmDate]		= ISNULL(B.[dtmDate], GETDATE())
--		,[intAccountId]		= A.[intAccountId]
--		,[dblDebit]			= CASE	WHEN [dblCredit] < 0 THEN ABS([dblCredit])
--									WHEN [dblDebit] < 0 THEN 0
--									ELSE [dblDebit] END 
--		,[dblCredit]		= CASE	WHEN [dblDebit] < 0 THEN ABS([dblDebit])
--									WHEN [dblCredit] < 0 THEN 0
--									ELSE [dblCredit] END	
--		,[dblDebitUnit]		= ISNULL(A.[dblDebitUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
--		,[dblCreditUnit]	= ISNULL(A.[dblCreditUnit], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
--	FROM [dbo].tblGLJournalDetail A INNER JOIN [dbo].tblGLJournal B ON A.[intJournalID] = B.[intJournalID]
--	WHERE B.intJournalID IN (SELECT [intJournalID] FROM #tmpValidJournals)
--)
--INSERT INTO tblGLSummary (
--	 [intAccountId]
--	,[dtmDate]
--	,[dblDebit]
--	,[dblCredit]
--	,[dblDebitUnit]
--	,[dblCreditUnit]
--	,[intConcurrencyId]
--)
--SELECT	
--	 [intAccountId]		= A.[intAccountId]
--	,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
--	,[dblDebit]			= SUM(A.[dblDebit])
--	,[dblCredit]		= SUM(A.[dblCredit])
--	,[dblDebitUnit]		= SUM(A.[dblDebitUnit])
--	,[dblCreditUnit]	= SUM(A.[dblCreditUnit])
--	,[intConcurrencyId] = 1
--FROM JournalDetail A
--WHERE NOT EXISTS 
--		(
--			SELECT TOP 1 1
--			FROM tblGLSummary B
--			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
--				  A.[intAccountId] = B.[intAccountId]
--		)
--GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId];

--IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @recapId = (SELECT TOP 1 intPaymentId FROM #tmpPayablePostData) --only support recap per record
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
		--DELETE PAYMENT DETAIL WITH PAYMENT AMOUNT
		DELETE FROM tblAPPaymentDetail
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND dblPayment = 0

		IF(@post = 1)
		BEGIN

			--clean gl detail recap after posting
			DELETE FROM tblGLDetailRecap
			FROM tblGLDetailRecap A
			INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		
			--removed from tblAPInvalidTransaction the successful records
			DELETE FROM tblAPInvalidTransaction
			FROM tblAPInvalidTransaction A
			INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..#tmpPayablePostData')) DROP TABLE #tmpPayablePostData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..##tmpPayableInvalidData')) DROP TABLE #tmpPayableInvalidData