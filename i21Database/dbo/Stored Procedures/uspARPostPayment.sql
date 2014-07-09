CREATE PROCEDURE uspARPostPayment
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
CREATE TABLE #tmpARReceivablePostData (
	[intPaymentId] [int] PRIMARY KEY,
	UNIQUE (intPaymentId)
);

CREATE TABLE #tmpARReceivableInvalidData (
	[strError] [NVARCHAR](100),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[strBatchNumber] [NVARCHAR](50),
	[intTransactionId] INT
);

--DECLARRE VARIABLES
--DECLARE @WithholdAccount INT = (SELECT intWithholdAccountId FROM tblAPPreference)
DECLARE @DiscountAccount INT = (SELECT intDiscountAccountId FROM tblAPPreference)--Check where to get discount account
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
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
		INSERT INTO #tmpARReceivablePostData SELECT intPaymentId FROM tblARPayment WHERE ysnPosted = 0
	END
	ELSE
	BEGIN
		INSERT INTO #tmpARReceivablePostData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
	END
END

IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpARReceivablePostData
	SELECT intPaymentId FROM tblARPayment
	WHERE dtmDatePaid BETWEEN @beginDate AND @endDate AND ysnPosted = @post
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpARReceivablePostData
	SELECT intPaymentId FROM tblARPayment
	WHERE intPaymentId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = @post
END

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--POST VALIDATIONS
	IF(ISNULL(@post,0) = 1)
		BEGIN

			--Payment without payment on detail (get all detail that has 0 payment)
			INSERT INTO #tmpARReceivableInvalidData
				SELECT 
					'There was no payment to receive.',
					'Receivable',
					A.strRecordNumber,
					@batchId,
					A.intPaymentId
				FROM tblARPayment A 
				LEFT JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData)
				GROUP BY A.intPaymentId, A.strRecordNumber
				HAVING SUM(B.dblPayment) = 0

			--Payment without detail
			INSERT INTO #tmpARReceivableInvalidData
				SELECT 
					'There was no payment to receive.',
					'Receivable',
					A.strRecordNumber,
					@batchId,
					A.intPaymentId
				FROM tblARPayment A 
				LEFT JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData)
				AND B.intPaymentId IS NULL

			--Fiscal Year
			INSERT INTO #tmpARReceivableInvalidData
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.',
					'Receivable',
					A.strRecordNumber,
					@batchId,
					A.intPaymentId
				FROM tblARPayment A 
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData) AND 
					0 = ISNULL([dbo].isOpenAccountingDate(A.[dtmDatePaid]), 0)

			--NOT BALANCE +over[ayment
			INSERT INTO #tmpARReceivableInvalidData
				SELECT 
					'The debit and credit amounts are not balanced.',
					'Receivable',
					A.strRecordNumber,
					@batchId,
					A.intPaymentId
				FROM tblARPayment A 
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData) AND 
					(A.dblAmountPaid) <> (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)

			--ALREADY POSTED
			INSERT INTO #tmpARReceivableInvalidData
			SELECT 
				'The transaction is already posted.',
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A 
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData) AND 
				A.ysnPosted = 1

			--RECEIVABLES(S) ALREADY PAID IN FULL
			INSERT INTO #tmpARReceivableInvalidData
			SELECT 
				C.strInvoiceNumber + ' already paid in full.',
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C
					ON B.intInvoiceId = C.intInvoiceId
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData)
				AND C.ysnPaid = 1 AND B.dblPayment <> 0
				
			INSERT INTO #tmpARReceivableInvalidData
			SELECT 
				'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due',
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C
					ON B.intInvoiceId = C.intInvoiceId
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpARReceivablePostData)
			AND B.dblPayment <> 0 AND C.ysnPaid = 0 AND C.dblAmountDue < (B.dblPayment + B.dblDiscount)
			
		END

	--UNPOSTING VALIDATIONS
	IF(ISNULL(@post,0) = 0)
	BEGIN

		--Already cleared/reconciled
		INSERT INTO #tmpARReceivableInvalidData
			SELECT 
				'The transaction is already cleared.',
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A 
				INNER JOIN tblCMBankTransaction B ON A.strRecordNumber = B.strTransactionId
			WHERE B.ysnClr = 1
	END
	
--Get all invalid
	DECLARE @totalInvalid INT
	SET @totalInvalid = (SELECT COUNT(*) FROM #tmpARReceivableInvalidData)

	IF(@totalInvalid > 0)
	BEGIN

		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT * FROM #tmpARReceivableInvalidData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE #tmpARReceivablePostData
			FROM #tmpARReceivablePostData A
				INNER JOIN #tmpARReceivableInvalidData
					ON A.intPaymentId = #tmpARReceivableInvalidData.intTransactionId

	END

--Get all to be post record
	DECLARE @totalRecords INT
	SELECT @totalRecords = COUNT(*) FROM #tmpARReceivablePostData

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
BEGIN
		--POSTING
		--INSERT GL ENTRIES
		--WHY REVERSAL IS NECESSARY??
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
		--==================
		--CREDIT SIDE
		--==================
		SELECT
			 [strRecordNumber]-- to be change by intID
			,A.intAccountId--(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,GLAccnt.strDescription --(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,C.[strCustomerNumber]
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 1 THEN 0 ELSE A.dblAmountPaid END
			,[dblCredit]			= CASE WHEN @post = 1 THEN A.dblAmountPaid ELSE 0 END
			,[dblDebitUnit]			= ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
		--INNER JOIN tblAPPaymentDetail B
		--	ON	A.intPaymentId = B.intPaymentId
		INNER JOIN [dbo].tblGLAccount GLAccnt
			ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN tblARCustomer C
			ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		--GROUP BY A.strRecordNumber,
		--A.intPaymentId,
		--A.dtmDatePaid,
		--A.intAccountId,
		--GLAccnt.strDescription,
		--C.strCustomerNumber
		

		--Discount Credit Side
		UNION
		SELECT
			 [strRecordNumber]
			,A.intAccountId
			,GLAccnt.strDescription
			,C.[strCustomerNumber]
			,A.[dtmDatePaid]
			,[dblDebit]				= SUM(CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount END)
			,[dblCredit]			= SUM(CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0 END)
			,[dblDebitUnit]			= SUM(ISNULL(B.dblDiscount, 0))  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,[dblCreditUnit]		= SUM(ISNULL(B.dblDiscount, 0)) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intAccountId = GLAccnt.intAccountId
				INNER JOIN tblARCustomer C
					ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) --fully paid
		AND B.dblDiscount <> 0
		GROUP BY A.[strRecordNumber],
		A.intPaymentId,
		A.intAccountId,
		C.strCustomerNumber,
		A.dtmDatePaid,
		GLAccnt.strDescription
		
		
		
		--============================
		---- DEBIT SIDE
		--============================
		UNION ALL 
		SELECT	[strRecordNumber]
				,B.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.[intAccountId])
				,D.[strCustomerNumber]
				,A.dtmDatePaid
				,[dblDebit]				= CASE WHEN @post = 1 THEN SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) 
											ELSE 0 END
				,[dblCredit]			= CASE WHEN @post = 1 THEN 0 
											ELSE SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)
											END 
				,[dblDebitUnit]			= SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = B.[intAccountId]), 0)
				,[dblCreditUnit]		= SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = B.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @batchId
				,[strCode]				= 'AR'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
				--INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
				INNER JOIN tblARCustomer D ON A.intEntityId = D.intEntityId 
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND B.dblPayment <> 0
		GROUP BY A.[strRecordNumber],
		A.intPaymentId,
		D.strCustomerNumber,
		A.dtmDatePaid,
		B.intAccountId
		
		
		--Discount Debit Side
		UNION
		SELECT
			 [strRecordNumber]
			,@DiscountAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount)
			,C.[strCustomerNumber]
			,A.[dtmDatePaid]
			,[dblDebit]				= SUM(CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0 END)
			,[dblCredit]			= SUM(CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount END)
			,[dblDebitUnit]			= SUM(ISNULL(B.dblDiscount, 0))  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,[dblCreditUnit]		= SUM(ISNULL(B.dblDiscount, 0)) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARCustomer C
					ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) --fully paid
		AND B.dblDiscount <> 0
		GROUP BY A.[strRecordNumber],
		A.intPaymentId,
		C.strCustomerNumber,
		A.dtmDatePaid
	
	
	
	IF(ISNULL(@post,0) = 0)
	BEGIN
	--==========================================================================
	--                 UNPOSTING PROCESS
	--==========================================================================	
	
		--Modified ysnPosted of tblARPayment
		UPDATE tblARPayment
			SET ysnPosted = 0
		FROM tblARPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		--Modified dblAmountDue of tblARPaymentDetail to its original value
		UPDATE tblARPaymentDetail
			SET tblARPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 THEN B.dblDiscount + B.dblPayment ELSE B.dblPayment END)
		FROM tblARPayment A
			LEFT JOIN tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		--Modified dblAmountDue, dtmDatePaid and ysnPaid on tblARInvoice
		UPDATE tblARInvoice
			SET tblARInvoice.dblAmountDue = B.dblAmountDue,
				tblARInvoice.ysnPaid = 0,
				tblARInvoice.dtmDate = NULL
		FROM tblARPayment A
					INNER JOIN tblARPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
					
		--Modified ysnIsUnposted of tblGLDetail
		UPDATE tblGLDetail
			SET tblGLDetail.ysnIsUnposted = 1
		FROM tblARPayment A
			INNER JOIN tblGLDetail B
				ON A.strRecordNumber = B.strTransactionId

		--DELETE IF NOT CHECK PAYMENT AND DOESN'T HAVE CHECK NUMBER
		DELETE FROM tblCMBankTransaction
		WHERE strTransactionId IN (
			SELECT strRecordNumber 
			FROM tblARPayment
				INNER JOIN tblSMPaymentMethod ON tblARPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
			 WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData) 
			AND tblSMPaymentMethod.strPaymentMethod != 'Check' 
			OR (ISNULL(tblARPayment.strPaymentInfo,'') = '' AND tblSMPaymentMethod.strPaymentMethod = 'Check')
		)

		--VOID IF CHECK PAYMENT
		UPDATE tblCMBankTransaction
		SET ysnCheckVoid = 1,
			ysnPosted = 0
		WHERE strTransactionId IN (
			SELECT strRecordNumber 
			FROM tblARPayment
			 WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData) 
		)

		--Insert Successfully unposted transactions.
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@UnpostSuccessfulMsg,
			'Receivable',
			A.strRecordNumber,
			@batchId,
			A.intPaymentId
		FROM tblARPayment A
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

	END
	ELSE
	BEGIN
	--==========================================================================
	--                 POSTING PROCESS
	--==========================================================================
	
		-- Update the posted flag in the transaction table
		UPDATE tblARPayment
		SET		ysnPosted = 1
		WHERE	intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		UPDATE tblARPaymentDetail
			SET tblARPaymentDetail.dblAmountDue = (B.dblInvoiceTotal) - (B.dblPayment + B.dblDiscount)
		FROM tblARPayment A
			LEFT JOIN tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)


		--Modified dblAmountDue, dtmDatePaid and ysnPaid on tblARInvoice
		UPDATE tblARInvoice
			SET tblARInvoice.dblAmountDue = B.dblAmountDue,
				tblARInvoice.ysnPaid = (CASE WHEN (B.dblAmountDue) = 0 THEN 1 ELSE 0 END),
				tblARInvoice.dtmDate = (CASE WHEN (B.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE NULL END)
		FROM tblARPayment A
					INNER JOIN tblARPaymentDetail B 
							ON A.intPaymentId = B.intPaymentId
					INNER JOIN tblARInvoice C
							ON B.intInvoiceId = C.intInvoiceId
					WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		--Insert to bank transaction
		--INSERT INTO tblCMBankTransaction(
		--	[strTransactionId],
		--	[intBankTransactionTypeId],
		--	[intBankAccountId],
		--	[intCurrencyId],
		--	[dblExchangeRate],
		--	[dtmDate],
		--	[strPayee],
		--	[intPayeeId],
		--	[strAddress],
		--	[strZipCode],
		--	[strCity],
		--	[strState],
		--	[strCountry],
		--	[dblAmount],
		--	[strAmountInWords],
		--	[strMemo],
		--	[strReferenceNo],
		--	[ysnCheckToBePrinted],
		--	[ysnCheckVoid],
		--	[ysnPosted],
		--	[strLink],
		--	[ysnClr],
		--	[dtmDateReconciled],
		--	[intCreatedUserId],
		--	[dtmCreated],
		--	[intLastModifiedUserId],
		--	[dtmLastModified],
		--	[intConcurrencyId]
		--)
		--SELECT
		--	[strTransactionId] = A.strRecordNumber,
		--	[intBankTransactionTypeID] = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AR Payment'),
		--	[intBankAccountID] = A.intAccountId,
		--	[intCurrencyID] = A.intCurrencyId,
		--	[dblExchangeRate] = 0,
		--	[dtmDate] = A.dtmDatePaid,
		--	[strPayee] = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.intEntityId),
		--	[intPayeeID] = B.intEntityId,
		--	[strAddress] = '',
		--	[strZipCode] = '',
		--	[strCity] = '',
		--	[strState] = '',
		--	[strCountry] = '',
		--	[dblAmount] = A.dblAmountPaid,
		--	[strAmountInWords] = dbo.fnConvertNumberToWord(A.dblAmountPaid),
		--	[strMemo] = '',
		--	[strReferenceNo] = '',
		--	[ysnCheckToBePrinted] = 0,
		--	[ysnCheckVoid] = 0,
		--	[ysnPosted] = 1,
		--	[strLink] = @batchId,
		--	[ysnClr] = 0,
		--	[dtmDateReconciled] = NULL,
		--	[intCreatedUserID] = @userId,
		--	[dtmCreated] = GETDATE(),
		--	[intLastModifiedUserID] = NULL,
		--	[dtmLastModified] = GETDATE(),
		--	[intConcurrencyId] = 1
		--	FROM tblARPayment A
		--		INNER JOIN tblARCustomer B
		--			ON A.intEntityId = B.intEntityId
		--	WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		--Insert Successfully posted transactions.
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg,
			'Receivable',
			A.strRecordNumber,
			@batchId,
			A.intPaymentId
		FROM tblARPayment A
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
END
ELSE
	BEGIN

		--RECAP
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intPaymentId FROM #tmpARReceivablePostData);

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
			 [strRecordNumber]
			,A.intPaymentId
			,A.intAccountId--(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,GLAccnt.strDescription
			,C.[strCustomerNumber]
			,A.[dtmDatePaid]
			,[dblDebit]				= SUM(CASE WHEN @post = 0 THEN 
										A.dblAmountPaid
									 ELSE 0 END)
			,[dblCredit]			= SUM(CASE WHEN @post = 0 THEN 0 ELSE 
										A.dblAmountPaid
										END)
			,[dblDebitUnit]			= SUM(ISNULL(A.[dblAmountPaid], 0))  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,[dblCreditUnit]		= SUM(ISNULL(A.[dblAmountPaid], 0)) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
		--INNER JOIN tblAPPaymentDetail B
		--	ON A.intPaymentId = B.intPaymentId
		INNER JOIN [dbo].tblGLAccount GLAccnt
			ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN tblARCustomer C
			ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		GROUP BY A.[strRecordNumber],
		A.intPaymentId,
		A.dtmDatePaid,
		A.intAccountId,
		GLAccnt.strDescription,
		C.strCustomerNumber

		
		--Discount
		UNION
		SELECT
			 strRecordNumber
			,A.intPaymentId
			,A.intAccountId
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = A.intAccountId)
			,C.strCustomerNumber
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 0 THEN 0 ELSE  B.dblDiscount END
			,[dblCredit]			= CASE WHEN @post = 0 THEN B.dblDiscount ELSE 0 END 
			,[dblDebitUnit]			= ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,[dblCreditUnit]		= ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARCustomer C
					ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND 1 = (CASE WHEN @post = 1 AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) THEN  1--fully paid when unposted
					  WHEN  @post = 0 AND B.dblAmountDue = 0 THEN 1 --fully paid when posted
					  ELSE 0 END)
		AND B.dblDiscount <> 0
		GROUP BY A.strRecordNumber,
		A.intPaymentId,
		A.intAccountId,
		C.strCustomerNumber,
		A.dtmDatePaid,
		B.dblDiscount,
		B.dblPayment,
		B.dblAmountDue
		
		---- DEBIT SIDE
		UNION ALL 
		SELECT	strRecordNumber
				,A.intPaymentId
				,C.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = C.[intAccountId])
				,D.strCustomerNumber
				,A.dtmDatePaid
				,[dblDebit]				= SUM(CASE WHEN @post = 0 THEN 0 ELSE 
												CASE WHEN (B.dblAmountDue = (B.dblPayment + B.dblDiscount))
												THEN B.dblPayment+ B.dblDiscount
												ELSE B.dblPayment END END)
				,[dblCredit]			= SUM(CASE WHEN @post = 0 THEN CASE WHEN (B.dblAmountDue = 0)
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblAmountDue END
											ELSE 0 END)
				,[dblDebitUnit]			= ISNULL(A.dblAmountPaid, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,[dblCreditUnit]		= ISNULL(A.dblAmountPaid, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0)
				,A.[dtmDatePaid]
				,0
				,1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @batchId
				,[strCode]				= 'AR'
				,[strModuleName]		= @MODULE_NAME
				,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN tblARCustomer D ON A.intEntityId = D.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND B.dblPayment <> 0
		GROUP BY A.[strRecordNumber],
		A.intPaymentId,
		D.strCustomerNumber,
		A.dtmDatePaid,
		A.intAccountId,
		A.dblAmountPaid,
		--B.dblPayment,
		--B.dblInterest,
		--B.dblAmountDue,
		C.intAccountId
		
		
		--Discount
		UNION
		SELECT
			 strRecordNumber
			,A.intPaymentId
			,@DiscountAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount)
			,C.strCustomerNumber
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 0 THEN B.dblDiscount ELSE 0 END
			,[dblCredit]			= CASE WHEN @post = 0 THEN 0 ELSE B.dblDiscount END 
			,[dblDebitUnit]			= ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,[dblCreditUnit]		= ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AR'
			,[strModuleName]		= @MODULE_NAME
			,A.intPaymentId
		FROM	[dbo].tblARPayment A 
				INNER JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARCustomer C
					ON A.intEntityId = C.intEntityId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND 1 = (CASE WHEN @post = 1 AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) THEN  1--fully paid when unposted
					  WHEN  @post = 0 AND B.dblAmountDue = 0 THEN 1 --fully paid when posted
					  ELSE 0 END)
		AND B.dblDiscount <> 0
		GROUP BY A.strRecordNumber,
		A.intPaymentId,
		C.strCustomerNumber,
		A.dtmDatePaid,
		B.dblDiscount,
		B.dblPayment,
		B.dblAmountDue

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
	SET @recapId = (SELECT TOP 1 intPaymentId FROM #tmpARReceivablePostData) --only support recap per record
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
		DELETE FROM tblARPaymentDetail
		WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
		AND dblPayment = 0

		--IF(@post = 1)
		--BEGIN

		--	----clean gl detail recap after posting
		--	--DELETE FROM tblGLDetailRecap
		--	--FROM tblGLDetailRecap A
		--	--INNER JOIN #tmpARReceivablePostData B ON A.intTransactionId = B.intPaymentId 

		
		--	----removed from tblAPInvalidTransaction the successful records
		--	--DELETE FROM tblAPInvalidTransaction
		--	--FROM tblAPInvalidTransaction A
		--	--INNER JOIN #tmpARReceivablePostData B ON A.intTransactionId = B.intPaymentId 

		--END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..#tmpARReceivablePostData')) DROP TABLE #tmpARReceivablePostData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..##tmpARReceivableInvalidData')) DROP TABLE #tmpARReceivableInvalidData