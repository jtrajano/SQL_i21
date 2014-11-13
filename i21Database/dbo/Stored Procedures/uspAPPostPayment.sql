CREATE PROCEDURE uspAPPostPayment
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
DECLARE @WithholdAccount INT = (SELECT intWithholdAccountId FROM tblAPPreference)
DECLARE @DiscountAccount INT = (SELECT intDiscountAccountId FROM tblAPPreference)
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Payable'
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

--Removed excluded bills to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT [intID] INTO #tmpPaymentsExclude FROM [dbo].fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPayablePostData A
	WHERE EXISTS(SELECT * FROM #tmpPaymentsExclude B WHERE A.intPaymentId = B.intID)
END

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--POST VALIDATIONS
	IF(ISNULL(@post,0) = 1)
		BEGIN

			--Payment without payment on detail
			INSERT INTO #tmpPayableInvalidData
				SELECT 
					'There was no bill to pay on this payment.',
					'Payable',
					A.strPaymentRecordNum,
					@batchId,
					A.intPaymentId
				FROM tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData)
				GROUP BY A.intPaymentId, A.strPaymentRecordNum
				HAVING SUM(B.dblPayment) = 0

			--Payment without detail
			INSERT INTO #tmpPayableInvalidData
				SELECT 
					'There was no bill to pay on this payment.',
					'Payable',
					A.strPaymentRecordNum,
					@batchId,
					A.intPaymentId
				FROM tblAPPayment A 
				LEFT JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData)
				AND B.intPaymentId IS NULL

			--Fiscal Year
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

			--NOT BALANCE
			INSERT INTO #tmpPayableInvalidData
				SELECT 
					'The debit and credit amounts are not balanced.',
					'Payable',
					A.strPaymentRecordNum,
					@batchId,
					A.intPaymentId
				FROM tblAPPayment A 
				WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData) AND 
					(A.dblAmountPaid + A.dblWithheld) <> (SELECT SUM(dblPayment) FROM tblAPPaymentDetail WHERE intPaymentId = A.intPaymentId)
					--include over payment

			--ALREADY POSTED
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

			--BILL(S) ALREADY PAID IN FULL
			INSERT INTO #tmpPayableInvalidData
			SELECT 
				C.strBillId + ' already paid in full.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
					ON B.intBillId = C.intBillId
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData)
				AND C.ysnPaid = 1 AND B.dblPayment <> 0
				
			INSERT INTO #tmpPayableInvalidData
			SELECT 
				'Payment on ' + C.strBillId + ' is over the transaction''s amount due',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C
					ON B.intBillId = C.intBillId
			WHERE  A.[intPaymentId] IN (SELECT [intPaymentId] FROM #tmpPayablePostData)
			AND B.dblPayment <> 0 AND C.ysnPaid = 0 AND C.dblAmountDue < (B.dblPayment + B.dblDiscount)
			
		END

	--UNPOSTING VALIDATIONS
	IF(ISNULL(@post,0) = 0)
	BEGIN

		--Already cleared/reconciled
		INSERT INTO #tmpPayableInvalidData
			SELECT 
				'The transaction is already cleared.',
				'Payable',
				A.strPaymentRecordNum,
				@batchId,
				A.intPaymentId
			FROM tblAPPayment A 
				INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
			WHERE B.ysnClr = 1 AND intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--CM Voiding Validation
		INSERT INTO #tmpPayableInvalidData
			SELECT C.strText,
					'Payable',
					A.strPaymentRecordNum,
					@batchId,
					A.intPaymentId
			FROM    tblAPPayment A INNER JOIN tblCMBankTransaction B
						ON A.strPaymentRecordNum = B.strTransactionId
						AND intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
					CROSS APPLY dbo.fnGetBankTransactionReversalErrors(B.intTransactionId) C
	END

	DECLARE @totalInvalid INT
	SET @totalInvalid = (SELECT COUNT(*) FROM #tmpPayableInvalidData)

	IF(@totalInvalid > 0)
	BEGIN

		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
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
BEGIN
		CREATE TABLE #tmpGLDetail(
			[dtmDate]                   DATETIME         NOT NULL,
			[intAccountId]              INT              NULL,
			[dblDebit]                  NUMERIC (18, 6)  NULL,
			[dblCredit]                 NUMERIC (18, 6)  NULL,
			[dblDebitUnit]              NUMERIC (18, 6)  NULL,
			[dblCreditUnit]             NUMERIC (18, 6)  NULL,
		);

		--POSTING
		WITH Units
		AS 
		(
			SELECT	A.[dblLbsPerUnit], B.[intAccountId] 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitId] = B.[intAccountUnitId]
		)
		INSERT INTO tblGLDetail (
			[intTransactionId], 
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
			[intEntityId],
			[dtmDateEntered],
			[strBatchId],
			[strCode],
			[strModuleName],
			[strTransactionForm],
			[strTransactionType]
		)
		OUTPUT INSERTED.dtmDate, INSERTED.intAccountId, INSERTED.dblDebit, INSERTED.dblCredit, INSERTED.dblDebitUnit, INSERTED.dblCreditUnit  INTO #tmpGLDetail
		--CREDIT
		SELECT
			 [intPaymentId]
			,[strPaymentRecordNum]
			,A.intAccountId--(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,GLAccnt.strDescription --(SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,C.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 1 THEN 0 ELSE A.dblAmountPaid END
			,[dblCredit]			= CASE WHEN @post = 1 THEN A.dblAmountPaid ELSE 0 END
			,[dblDebitUnit]			= CASE WHEN @post = 1 THEN ISNULL(A.[dblAmountPaid], 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) ELSE 0 END
			,[dblCreditUnit]		= CASE WHEN @post = 1 THEN ISNULL(A.[dblAmountPaid], 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = A.[intAccountId]), 0) ELSE 0 END
			,DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[intEntityId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
		--INNER JOIN tblAPPaymentDetail B
		--	ON	A.intPaymentId = B.intPaymentId
		INNER JOIN [dbo].tblGLAccount GLAccnt
			ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN tblAPVendor C
			ON A.intVendorId = C.intVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Withheld
		UNION
		SELECT
			 [intPaymentId]
			,[strPaymentRecordNum]
			,@WithholdAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @WithholdAccount)
			,B.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 1 THEN 0 ELSE A.dblWithheld END
			,[dblCredit]			= CASE WHEN @post = 1 THEN A.dblWithheld ELSE 0 END
			,[dblDebitUnit]			= CASE WHEN @post = 1 THEN ISNULL(A.dblWithheld, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @WithholdAccount), 0) ELSE 0 END
			,[dblCreditUnit]		= CASE WHEN @post = 1 THEN ISNULL(A.dblWithheld, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @WithholdAccount), 0) ELSE 0 END
			,DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[intEntityId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A INNER JOIN [dbo].tblGLAccount GLAccnt
					ON A.intBankAccountId = GLAccnt.intAccountId
				INNER JOIN tblAPVendor B
					ON A.intVendorId = B.intVendorId AND B.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

		--Discount
		UNION
		SELECT
			 A.[intPaymentId]
			,[strPaymentRecordNum]
			,@DiscountAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount)
			,C.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= SUM(CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount END)
			,[dblCredit]			= SUM(CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0 END)
			,[dblDebitUnit]			= CASE WHEN @post = 1 THEN SUM(ISNULL(B.dblDiscount, 0))  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0) ELSE 0 END
			,[dblCreditUnit]		= CASE WHEN @post = 1 THEN SUM(ISNULL(B.dblDiscount, 0)) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0) ELSE 0 END
			,DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[intEntityId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intVendorId = C.intVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) --fully paid
		AND B.dblDiscount <> 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid
		
		---- DEBIT SIDE
		UNION ALL 
		SELECT	A.[intPaymentId]
				,[strPaymentRecordNum]
				,B.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.[intAccountId])
				,D.[strVendorId]
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
				,[dblDebitUnit]			= CASE WHEN @post = 1 THEN SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = B.[intAccountId]), 0)
										  ELSE 0 END
				,[dblCreditUnit]		= CASE WHEN @post = 1 THEN SUM(CASE WHEN (B.dblAmountDue = B.dblPayment) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = B.[intAccountId]), 0)
										  ELSE 0 END
				,DATEADD(dd, DATEDIFF(dd, 0, A.[dtmDatePaid]), 0)
				,CASE WHEN @post = 1 THEN 0 ELSE 1 END
				,1
				,[dblExchangeRate]		= 1
				,[intUserId]			= @userId
				,[intEntityId]			= @userId
				,[dtmDateEntered]		= GETDATE()
				,[strBatchId]			= @batchId
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,[strTransactionForm]	= @SCREEN_NAME
				,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				--INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
				INNER JOIN tblAPVendor D ON A.intVendorId = D.intVendorId 
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblPayment <> 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		D.strVendorId,
		A.dtmDatePaid,
		B.intAccountId;

--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
IF (@post = 1)
BEGIN

	WITH PaymentDetail
	AS
	(
		SELECT   [dtmDate]          = ISNULL(A.[dtmDate], GETDATE())
				,[intAccountId]     = A.[intAccountId]
				,[dblDebit]         = CASE  WHEN [dblCredit] < 0 THEN ABS([dblCredit])
											WHEN [dblDebit] < 0 THEN 0
											ELSE [dblDebit] END
				,[dblCredit]        = CASE  WHEN [dblDebit] < 0 THEN ABS([dblDebit])
											WHEN [dblCredit] < 0 THEN 0
											ELSE [dblCredit] END
				,[dblDebitUnit]     = ISNULL([dblDebitUnit], 0)
				,[dblCreditUnit]    = ISNULL([dblCreditUnit], 0)
		FROM #tmpGLDetail A
	)
	UPDATE  tblGLSummary
	SET      [dblDebit]         = ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
			,[dblCredit]        = ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
			,[dblDebitUnit]     = ISNULL(tblGLSummary.[dblDebitUnit], 0) + ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
			,[dblCreditUnit]    = ISNULL(tblGLSummary.[dblCreditUnit], 0) + ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
			,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
	FROM    (
				SELECT   [dblDebit]         = SUM(ISNULL(B.[dblDebit], 0))
						,[dblCredit]        = SUM(ISNULL(B.[dblCredit], 0))
						,[dblDebitUnit]     = SUM(ISNULL(B.[dblDebitUnit], 0))
						,[dblCreditUnit]    = SUM(ISNULL(B.[dblCreditUnit], 0))
						,[intAccountId]     = A.[intAccountId]
						,[dtmDate]          = ISNULL(CONVERT(DATE, A.[dtmDate]), '')
				FROM tblGLSummary A
						INNER JOIN PaymentDetail B
						ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = 'AP'
				GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
			) AS GLDetailGrouped
	WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = 'AP' AND
		  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');
	IF @@ERROR <> 0   GOTO Post_Rollback;

	--=====================================================================================================================================
	--  INSERT TO GL SUMMARY RECORDS
	---------------------------------------------------------------------------------------------------------------------------------------
	WITH PaymentDetail
	AS
	(
		SELECT [dtmDate]        = ISNULL(A.[dtmDate], GETDATE())
			,[intAccountId]     = A.[intAccountId]
			,[dblDebit]         = CASE  WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END
			,[dblCredit]        = CASE  WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END
			,[dblDebitUnit]     = ISNULL(A.[dblDebitUnit], 0)
			,[dblCreditUnit]    = ISNULL(A.[dblCreditUnit], 0)
		FROM #tmpGLDetail A
	)
	INSERT INTO tblGLSummary (
		 [intAccountId]
		,[dtmDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strCode]
		,[intConcurrencyId]
	)
	SELECT
		 [intAccountId]     = A.[intAccountId]
		,[dtmDate]          = ISNULL(CONVERT(DATE, A.[dtmDate]), '')
		,[dblDebit]         = SUM(A.[dblDebit])
		,[dblCredit]        = SUM(A.[dblCredit])
		,[dblDebitUnit]     = SUM(A.[dblDebitUnit])
		,[dblCreditUnit]    = SUM(A.[dblCreditUnit])
		,[strCode] = 'AP'
		,[intConcurrencyId] = 1
	FROM PaymentDetail A
	WHERE NOT EXISTS
			(
				SELECT TOP 1 1
				FROM tblGLSummary B
				WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND
					  A.[intAccountId] = B.[intAccountId] AND B.[strCode] = 'AP'
			)
	GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId];

END
ELSE
BEGIN

	WITH GLDetail
	AS
	(
		SELECT   [dtmDate]      = ISNULL(A.[dtmDate], GETDATE())
				,[intAccountId] = A.[intAccountId]
				,[dblDebit]     = CASE  WHEN [dblDebit] < 0 THEN ABS([dblDebit])
										WHEN [dblCredit] < 0 THEN 0
										ELSE [dblCredit] END
				,[dblCredit]    = CASE  WHEN [dblCredit] < 0 THEN ABS([dblCredit])
										WHEN [dblDebit] < 0 THEN 0
										ELSE [dblDebit] END
				,[dblDebitUnit]     = CASE  WHEN [dblDebitUnit] < 0 THEN ABS([dblDebitUnit])
										WHEN [dblCreditUnit] < 0 THEN 0
										ELSE [dblCreditUnit] END
				,[dblCreditUnit]    = CASE  WHEN [dblCreditUnit] < 0 THEN ABS([dblCreditUnit])
										WHEN [dblDebitUnit] < 0 THEN 0
										ELSE [dblDebitUnit] END
		FROM [dbo].tblGLDetail A WHERE A.[strTransactionId] IN (SELECT strPaymentRecordNum FROM tblAPPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData))
		AND ysnIsUnposted = 0 AND strCode = 'AP'
	)
	UPDATE  tblGLSummary
	SET      [dblDebit] = ISNULL(tblGLSummary.[dblDebit], 0) - ISNULL(GLDetailGrouped.[dblDebit], 0)
			,[dblCredit] = ISNULL(tblGLSummary.[dblCredit], 0) - ISNULL(GLDetailGrouped.[dblCredit], 0)
			,[dblDebitUnit] = ISNULL(tblGLSummary.[dblDebitUnit], 0) - ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
			,[dblCreditUnit] = ISNULL(tblGLSummary.[dblCreditUnit], 0) - ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
			,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
	FROM    (
				SELECT   [dblDebit]         = SUM(ISNULL(B.[dblCredit], 0))
						,[dblCredit]        = SUM(ISNULL(B.[dblDebit], 0))
						,[dblDebitUnit]     = SUM(ISNULL(B.[dblCreditUnit], 0))
						,[dblCreditUnit]    = SUM(ISNULL(B.[dblDebitUnit], 0))
						,[intAccountId]     = A.[intAccountId]
						,[dtmDate]          = ISNULL(CONVERT(DATE, A.[dtmDate]), '')
				FROM tblGLSummary A
						INNER JOIN GLDetail B
						ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = 'AP'
				GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId]
			) AS GLDetailGrouped
	WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = 'AP' AND
		  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

END

IF @@ERROR <> 0	GOTO Post_Rollback;

	IF(ISNULL(@post,0) = 0)
	BEGIN
		
		--Unposting Process
		UPDATE tblAPPaymentDetail
		SET tblAPPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 THEN B.dblDiscount + C.dblAmountDue + B.dblPayment ELSE (C.dblAmountDue + B.dblPayment) END)
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
				ON A.strPaymentRecordNum = B.strTransactionId
		WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)

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
		EXEC dbo.uspCMBankTransactionReversal @userId, @isSuccessful OUTPUT

		--update payment record based on record from tblCMBankTransaction
		UPDATE tblAPPayment
			SET ysnVoid = CASE WHEN A.ysnPrinted = 1 AND ISNULL(A.strPaymentInfo,'') <> '' THEN 1 ELSE 0 END
			,strPaymentInfo = CASE WHEN A.ysnPrinted = 1 AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
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

		UPDATE tblAPPaymentDetail
			SET tblAPPaymentDetail.dblAmountDue = (B.dblAmountDue) - (B.dblPayment + B.dblDiscount)
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
			[strReferenceNo] = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE '' END,
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
					ON A.intVendorId = B.intVendorId
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
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intPaymentId FROM #tmpPayablePostData);

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
			,[strTransactionType]
		)
		--CREDIT SIDE
		SELECT
			 [strPaymentRecordNum]
			,A.intPaymentId
			,A.intAccountId--(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = (SELECT intGLAccountId FROM tblCMBankAccount WHERE intBankAccountId = A.intBankAccountId))
			,GLAccnt.strDescription
			,C.[strVendorId]
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
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
		--INNER JOIN tblAPPaymentDetail B
		--	ON A.intPaymentId = B.intPaymentId
		INNER JOIN [dbo].tblGLAccount GLAccnt
			ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN tblAPVendor C
			ON A.intVendorId = C.intVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		A.dtmDatePaid,
		A.dblWithheld,
		A.intAccountId,
		GLAccnt.strDescription,
		C.strVendorId

		--Withheld
		UNION
		SELECT
			 [strPaymentRecordNum]
			,A.intPaymentId
			,@WithholdAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @WithholdAccount)
			,B.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 0 THEN A.dblWithheld ELSE 0 END
			,[dblCredit]			= CASE WHEN @post = 0 THEN 0 ELSE A.dblWithheld END
			,[dblDebitUnit]			= ISNULL(A.dblWithheld, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @WithholdAccount), 0)
			,[dblCreditUnit]		= ISNULL(A.dblWithheld, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @WithholdAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPVendor B
					ON A.intVendorId = B.intVendorId AND B.ysnWithholding = 1
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		--Discount
		UNION
		SELECT
			 [strPaymentRecordNum]
			,A.intPaymentId
			,@DiscountAccount
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount)
			,C.[strVendorId]
			,A.[dtmDatePaid]
			,[dblDebit]				= CASE WHEN @post = 0 THEN B.dblDiscount ELSE 0 END
			,[dblCredit]			= CASE WHEN @post = 0 THEN 0 ELSE B.dblDiscount END 
			,[dblDebitUnit]			= ISNULL(A.dblWithheld, 0)  * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,[dblCreditUnit]		= ISNULL(A.dblWithheld, 0) * ISNULL((SELECT [dblLbsPerUnit] FROM Units WHERE [intAccountId] = @DiscountAccount), 0)
			,A.[dtmDatePaid]
			,0
			,1
			,[dblExchangeRate]		= 1
			,[intUserId]			= @userId
			,[dtmDateEntered]		= GETDATE()
			,[strBatchId]			= @batchId
			,[strCode]				= 'AP'
			,[strModuleName]		= @MODULE_NAME
			,[strTransactionForm]	= @SCREEN_NAME
			,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPVendor C
					ON A.intVendorId = C.intVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND 1 = (CASE WHEN @post = 1 AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) THEN  1--fully paid when unposted
					  WHEN  @post = 0 AND B.dblAmountDue = 0 THEN 1 --fully paid when posted
					  ELSE 0 END)
		AND B.dblDiscount <> 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		C.strVendorId,
		A.dtmDatePaid,
		A.dblWithheld,
		B.dblDiscount,
		B.dblPayment,
		B.dblInterest,
		B.dblAmountDue
		
		---- DEBIT SIDE
		UNION ALL 
		SELECT	[strPaymentRecordNum]
				,A.intPaymentId
				,C.[intAccountId]
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = C.[intAccountId])
				,D.[strVendorId]
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
				,[strCode]				= 'AP'
				,[strModuleName]		= @MODULE_NAME
				,[strTransactionForm]	= @SCREEN_NAME
				,[strTransactionType]	= @TRAN_TYPE
		FROM	[dbo].tblAPPayment A 
				INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
				INNER JOIN tblAPVendor D ON A.intVendorId = D.intVendorId
		WHERE	A.intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
		AND B.dblPayment <> 0
		GROUP BY A.[strPaymentRecordNum],
		A.intPaymentId,
		D.strVendorId,
		A.dtmDatePaid,
		A.dblWithheld,
		A.intAccountId,
		A.dblAmountPaid,
		--B.dblPayment,
		--B.dblInterest,
		--B.dblAmountDue,
		C.intAccountId

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
		--DELETE PAYMENT DETAIL WITH PAYMENT AMOUNT EQUAL TO 0
		IF(@post = 1)
		BEGIN
			DELETE FROM tblAPPaymentDetail
			WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpPayablePostData)
			AND dblPayment = 0
		END

		--IF(@post = 1)
		--BEGIN

		--	----clean gl detail recap after posting
		--	--DELETE FROM tblGLDetailRecap
		--	--FROM tblGLDetailRecap A
		--	--INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		
		--	----removed from tblAPInvalidTransaction the successful records
		--	--DELETE FROM tblAPInvalidTransaction
		--	--FROM tblAPInvalidTransaction A
		--	--INNER JOIN #tmpPayablePostData B ON A.intTransactionId = B.intPaymentId 

		--END
		SET @success = 1
	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..#tmpPayablePostData')) DROP TABLE #tmpPayablePostData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE ID = OBJECT_ID('tempdb..##tmpPayableInvalidData')) DROP TABLE #tmpPayableInvalidData
