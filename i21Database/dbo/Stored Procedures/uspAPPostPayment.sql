CREATE PROCEDURE uspAPPostPayment
	@batchId			AS NVARCHAR(20)		= NULL,
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

IF @userId IS NULL
BEGIN
	RAISERROR('User is required', 16, 1);
END
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
	[intTransactionId] INT
);

--DECLARRE VARIABLES
DECLARE @WithholdAccount INT = (SELECT intWithholdAccountId FROM tblAPPreference)
DECLARE @DiscountAccount INT = (SELECT intDiscountAccountId FROM tblAPPreference)
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Payable'
DECLARE @paymentIds NVARCHAR(MAX) = @param
DECLARE @validPaymentIds NVARCHAR(MAX)
DECLARE @GLEntries AS RecapTableType 

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
		IF(@post = 0)
		BEGIN
			INSERT INTO #tmpPayablePostData SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 0
		END
		ELSE IF(@post = 1)
		BEGIN
			INSERT INTO #tmpPayablePostData 
			SELECT intPaymentId FROM tblAPPayment WHERE ysnPosted = 1
			AND NOT EXISTS (SELECT 1 FROM tblCMBankTransaction WHERE strTransactionId = tblAPPayment.strPaymentRecordNum AND ysnClr = 1)
		END
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

--Removed excluded bills to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT [intID] INTO #tmpPaymentsExclude FROM [dbo].fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPayablePostData A
	WHERE EXISTS(SELECT * FROM #tmpPaymentsExclude B WHERE A.intPaymentId = B.intID)
END

--SET THE UPDATED @paymentIds
SELECT @paymentIds = COALESCE(@paymentIds + ',', '') +  CONVERT(VARCHAR(12),intPaymentId)
FROM #tmpPayablePostData
ORDER BY intPaymentId

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--VALIDATIONS
	INSERT INTO #tmpPayableInvalidData 
	SELECT * FROM [fnAPValidatePostPayment](@paymentIds, @post)

	DECLARE @totalInvalid INT
	SET @totalInvalid = (SELECT COUNT(*) FROM #tmpPayableInvalidData)

	IF(@totalInvalid > 0)
	BEGIN

		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT strError, strTransactionType, strTransactionId, @batchId, intTransactionId FROM #tmpPayableInvalidData

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

--CREATE TEMP GL ENTRIES
SELECT @validPaymentIds = COALESCE(@validPaymentIds + ',', '') +  CONVERT(VARCHAR(12),intPaymentId)
FROM #tmpPayablePostData
ORDER BY intPaymentId

IF ISNULL(@post,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.[fnAPCreatePaymentGLEntries](@validPaymentIds, @userId, @batchId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@validPaymentIds, 'Payable', DEFAULT, @userId, @batchId)
END

--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	EXEC uspGLBookEntries @GLEntries, @post

	IF @@ERROR <> 0	GOTO Post_Rollback;

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		--Unposting Process
		UPDATE tblAPPaymentDetail
		SET tblAPPaymentDetail.dblAmountDue = C.dblAmountDue
		FROM tblAPPayment A
			LEFT JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
		UPDATE tblAPBill
			SET tblAPBill.dblAmountDue = B.dblAmountDue,
				tblAPBill.ysnPaid = 0,
				tblAPBill.dtmDatePaid = NULL,
				tblAPBill.dblWithheld = 0
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
				ON A.intPaymentId = B.intTransactionId
		WHERE B.[strTransactionId] IN (SELECT strPaymentRecordNum FROM tblAPPayment 
							WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData))

		-- Creating the temp table:
		DECLARE @isSuccessful BIT
		CREATE TABLE #tmpCMBankTransaction (
         --[intTransactionId] INT PRIMARY KEY,
         [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
         UNIQUE (strTransactionId))

		INSERT INTO #tmpCMBankTransaction
		 SELECT strPaymentRecordNum FROM tblAPPayment A
		 INNER JOIN #tmpPayablePostData B ON A.intPaymentId = B.intPaymentId

		-- Calling the stored procedure
		EXEC dbo.uspCMBankTransactionReversal @userId, DEFAULT, @isSuccessful OUTPUT

		--update payment record based on record from tblCMBankTransaction
		UPDATE tblAPPayment
			SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
		FROM tblAPPayment A 
			INNER JOIN tblCMBankTransaction B
				ON A.strPaymentRecordNum = B.strTransactionId
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--update payment record
		UPDATE tblAPPayment
			SET ysnPosted= 0
		FROM tblAPPayment A 
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Insert Successfully unposted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@UnpostSuccessfulMsg,
			'Payable',
			A.strPaymentRecordNum,
			@batchId,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		IF @@ERROR <> 0 OR @isSuccessful = 0 GOTO Post_Rollback;

	END
	ELSE
	BEGIN

		-- Update the posted flag in the transaction table
		UPDATE tblAPPayment
		SET		ysnPosted = 1
				--,intConcurrencyId += 1 
		WHERE	intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		UPDATE B
			SET B.dblAmountDue = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
									THEN 0 ELSE (B.dblAmountDue) - (B.dblPayment) END,
			B.dblDiscount = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
								THEN B.dblDiscount ELSE 0 END,
			B.dblInterest = CASE WHEN (B.dblPayment + B.dblDiscount - B.dblInterest) = B.dblAmountDue 
								THEN B.dblInterest ELSE 0 END
		FROM tblAPPayment A
			LEFT JOIN tblAPPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)


		--Update dblAmountDue, dtmDatePaid and ysnPaid on tblAPBill
		UPDATE tblAPBill
			SET tblAPBill.dblAmountDue = B.dblAmountDue,
				tblAPBill.ysnPaid = (CASE WHEN (B.dblAmountDue) = 0 THEN 1 ELSE 0 END),
				tblAPBill.dtmDatePaid = (CASE WHEN (B.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE NULL END),
				tblAPBill.dblWithheld = B.dblWithheld
		FROM tblAPPayment A
					INNER JOIN tblAPPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblAPBill C
							ON B.intBillId = C.intBillId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Update Bill Amount Due associated on the other payment record
		UPDATE tblAPPaymentDetail
		SET dblAmountDue = C.dblAmountDue
		FROM tblAPPaymentDetail A
			INNER JOIN tblAPPayment B
				ON A.intPaymentId = B.intPaymentId
				AND A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
				AND B.ysnPosted = 0
			INNER JOIN tblAPBill C
				ON A.intBillId = C.intBillId

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
			[intEntityId],
			[intCreatedUserId],
			[dtmCreated],
			[intLastModifiedUserId],
			[dtmLastModified],
			[intConcurrencyId]
		)
		SELECT
			[strTransactionId] = A.strPaymentRecordNum,
			[intBankTransactionTypeID] = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'echeck' THEN 20 ELSE 
						(SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AP Payment') END,
			[intBankAccountID] = A.intBankAccountId,
			[intCurrencyID] = A.intCurrencyId,
			[dblExchangeRate] = 0,
			[dtmDate] = A.dtmDatePaid,
			[strPayee] = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.intEntityVendorId),
			[intPayeeId] = B.intEntityVendorId,
			[strAddress] = '',
			[strZipCode] = '',
			[strCity] = '',
			[strState] = '',
			[strCountry] = '',
			[dblAmount] = A.dblAmountPaid,
			[strAmountInWords] = dbo.fnConvertNumberToWord(A.dblAmountPaid),
			[strMemo] = '',
			[strReferenceNo] = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
			[ysnCheckToBePrinted] = 1,
			[ysnCheckVoid] = 0,
			[ysnPosted] = 1,
			[strLink] = @batchId,
			[ysnClr] = 0,
			[dtmDateReconciled] = NULL,
			[intEntityId] = A.intEntityId,
			[intCreatedUserID] = @userId,
			[dtmCreated] = GETDATE(),
			[intLastModifiedUserID] = NULL,
			[dtmLastModified] = GETDATE(),
			[intConcurrencyId] = 1
			FROM tblAPPayment A
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId
				--LEFT JOIN tblSMPaymentMethod C ON A.intPaymentMethodId = C.intPaymentMethodID
			WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
			--AND C.strPaymentMethod = 'Check'

		--Insert Successfully posted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg,
			'Payable',
			A.strPaymentRecordNum,
			@batchId,
			A.intPaymentId
		FROM tblAPPayment A
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
END
ELSE
	BEGIN

		--RECAP
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLPostRecap
			WHERE intTransactionId IN (SELECT intPaymentId FROM #tmpPayablePostData);

		INSERT INTO tblGLPostRecap(
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
			,[strAccountId]
			,[strAccountGroup]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value--[dblDebit]
			,Credit.Value--[dblCredit]
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblExchangeRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit;

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;

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
		----DELETE PAYMENT DETAIL WITH PAYMENT AMOUNT

		IF(@post = 1)
		BEGIN		
			DELETE FROM tblAPPaymentDetail
			WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
			AND dblPayment = 0
		END

		----IF(@post = 1)
		----BEGIN

		----	----clean gl detail recap after posting
		----	--DELETE FROM tblGLDetailRecap
		----	--FROM tblGLDetailRecap A
		----	--INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		
		----	----removed from tblAPInvalidTransaction the successful records
		----	--DELETE FROM tblAPInvalidTransaction
		----	--FROM tblAPInvalidTransaction A
		----	--INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		----END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPayablePostData')) DROP TABLE #tmpPayablePostData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..##tmpPayableInvalidData')) DROP TABLE #tmpPayableInvalidData
