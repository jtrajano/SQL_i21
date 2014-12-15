CREATE PROCEDURE [dbo].[uspARPostPayment]
	@batchId			AS NVARCHAR(20)		= NULL,
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
CREATE TABLE #tmpARReceivablePostData (
	intPaymentId int PRIMARY KEY,
	UNIQUE (intPaymentId)
);

CREATE TABLE #tmpARReceivableInvalidData (
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	strBatchNumber NVARCHAR(50),
	intTransactionId INT
);

DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
SET @recapId = '1'

--SET BatchId
IF(@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

SET @batchIdUsed = @batchId

DECLARE @UserEntityID int
SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @userId),@userId)

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
				INSERT INTO #tmpARReceivablePostData SELECT intID FROM fnGetRowsFromDelimitedValues(@param)
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

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT intID INTO #tmpReceivableExclude FROM fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpARReceivablePostData A
	WHERE EXISTS(SELECT * FROM #tmpReceivableExclude B WHERE A.intPaymentId = B.intID)
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
				INSERT INTO 
					#tmpARReceivableInvalidData
				SELECT
					'There was no payment to receive.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				LEFT JOIN 
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				GROUP BY
					A.intPaymentId, A.strRecordNumber
				HAVING
					SUM(B.dblPayment) = 0

				--Payment without detail
				INSERT INTO 
					#tmpARReceivableInvalidData
				SELECT 
					'There was no payment to receive.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM 
					tblARPayment A 
				LEFT JOIN 
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						
				WHERE
					B.intPaymentId IS NULL

				--Fiscal Year
				INSERT INTO 
					#tmpARReceivableInvalidData
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				WHERE
					ISNULL([dbo].isOpenAccountingDate(A.dtmDatePaid), 0) = 0
					
				--Company Location
				INSERT INTO 
					#tmpARReceivableInvalidData
				SELECT 
					'Company location of ' + A.strRecordNumber + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				WHERE L.intCompanyLocationId IS NULL
				
				--Sales Discount Account
				INSERT INTO 
					#tmpARReceivableInvalidData
				SELECT 
					'The Sales Discounts account of Company Location ' + L.strLocationName + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				INNER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount G
						ON L.intSalesDiscounts = G.intAccountId						
				WHERE
					G.intAccountId IS NULL				
					

				--NOT BALANCE +overpayment
				INSERT INTO
					#tmpARReceivableInvalidData
				SELECT
					'The debit and credit amounts are not balanced.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) <> (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)

				--ALREADY POSTED
				INSERT INTO
					#tmpARReceivableInvalidData
				SELECT 
					'The transaction is already posted.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					A.ysnPosted = 1

				--RECEIVABLES(S) ALREADY PAID IN FULL
				INSERT INTO
					#tmpARReceivableInvalidData
				SELECT 
					C.strInvoiceNumber + ' already paid in full.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					C.ysnPaid = 1 
					AND B.dblPayment <> 0
					
				INSERT INTO
					#tmpARReceivableInvalidData
				SELECT 
					'Payment on ' + C.strInvoiceNumber + ' is over the transaction''s amount due'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail B
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN
					tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN
					#tmpARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					B.dblPayment <> 0 
					AND C.ysnPaid = 0 
					AND C.dblAmountDue < (B.dblPayment + B.dblDiscount)
				
			END

		--UNPOSTING VALIDATIONS
		IF(ISNULL(@post,0) = 0)
			BEGIN

				--Already cleared/reconciled
				INSERT INTO
					#tmpARReceivableInvalidData
				SELECT 
					'The transaction is already cleared.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					tblCMBankTransaction B 
						ON A.strRecordNumber = B.strTransactionId
				WHERE B.ysnClr = 1
			END
		
	--Get all invalid
		DECLARE @totalInvalid INT
		SET @totalInvalid = (SELECT COUNT(*) FROM #tmpARReceivableInvalidData)

		IF(@totalInvalid > 0)
			BEGIN

				INSERT INTO 
					tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					strError
					,strTransactionType
					,strTransactionId
					,strBatchNumber
					,intTransactionId
				FROM
					#tmpARReceivableInvalidData

				SET @invalidCount = @totalInvalid

				--DELETE Invalid Transaction From temp table
				DELETE 
					#tmpARReceivablePostData
				FROM
					#tmpARReceivablePostData A
				INNER JOIN 
					#tmpARReceivableInvalidData
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
-- 	CHECK IF THE PROCESS IS RECAR OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN
		CREATE TABLE #tmpGLDetail(
			dtmDate                   DATETIME         NOT NULL,
			intAccountId              INT              NULL,
			dblDebit                  NUMERIC (18, 6)  NULL,
			dblCredit                 NUMERIC (18, 6)  NULL,
			dblDebitUnit              NUMERIC (18, 6)  NULL,
			dblCreditUnit             NUMERIC (18, 6)  NULL,
		);

		--POSTING
		WITH Units
		AS 
		(
			SELECT
				A.dblLbsPerUnit
				,B.intAccountId 
			FROM
				tblGLAccountUnit A 
			INNER JOIN 
				tblGLAccount B 
					ON A.intAccountUnitId = B.intAccountUnitId
		)
		
		INSERT INTO tblGLDetail (
			intTransactionId, 
			strTransactionId,
			intAccountId,
			strDescription,
			strReference,
			dtmTransactionDate,
			dblDebit,
			dblCredit,
			dblDebitUnit,
			dblCreditUnit,
			dtmDate,
			ysnIsUnposted,
			intConcurrencyId,
			dblExchangeRate,
			intUserId,
			intEntityId,
			dtmDateEntered,
			strBatchId,
			strCode,
			strModuleName,
			strTransactionForm,
			strTransactionType
		)
		OUTPUT INSERTED.dtmDate, INSERTED.intAccountId, INSERTED.dblDebit, INSERTED.dblCredit, INSERTED.dblDebitUnit, INSERTED.dblCreditUnit  INTO #tmpGLDetail
		--DEBIT
		SELECT
			 A.intPaymentId
			,A.strRecordNumber
			,A.intAccountId
			,GLAccnt.strDescription
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit			= CASE WHEN @post = 1 THEN A.dblAmountPaid ELSE 0 END
			,dblCredit			= CASE WHEN @post = 1 THEN 0 ELSE A.dblAmountPaid END
			,dblDebitUnit		= CASE WHEN @post = 1 THEN ISNULL(A.dblAmountPaid, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END
			,dblCreditUnit		= CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblAmountPaid, 0) * ISNULL(U.dblLbsPerUnit, 0) END
			,DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,intEntityId			= @UserEntityID
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblGLAccount GLAccnt
				ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId					
		
		UNION ALL
		
		--Discount
		SELECT
			A.intPaymentId
			,A.strRecordNumber
			,(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = L.intSalesDiscounts)
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = L.intSalesDiscounts)
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit			= CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0 END
			,dblCredit			= CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount  END
			,dblDebitUnit		= CASE WHEN @post = 1 THEN ISNULL(B.dblDiscount, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END
			,dblCreditUnit		= CASE WHEN @post = 1 THEN 0 ELSE ISNULL(B.dblDiscount, 0) * ISNULL(U.dblLbsPerUnit, 0) END
			,DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,intEntityId			= @UserEntityID
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intLocationId = L.intCompanyLocationId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			B.dblAmountDue = (B.dblPayment + B.dblDiscount)
			AND B.dblDiscount <> 0
		
		--CREDIT
		UNION ALL 
		SELECT	A.intPaymentId
				,strRecordNumber
				,B.intAccountId
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId)
				,D.strCustomerNumber
				,A.dtmDatePaid
				,dblDebit			= CASE WHEN @post = 1 THEN 0 
											ELSE (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) END
				,dblCredit			= CASE WHEN @post = 1 THEN (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) 
											ELSE 0 END 
				,dblDebitUnit			= CASE WHEN @post = 1 THEN 0
										  ELSE (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)  * ISNULL(U.dblLbsPerUnit, 0) END
				,dblCreditUnit		= CASE WHEN @post = 1 THEN (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) * ISNULL(U.dblLbsPerUnit, 0)
										  ELSE 0 END
				,DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
				,CASE WHEN @post = 1 THEN 0 ELSE 1 END
				,1
				,dblExchangeRate		= 1
				,intUserId			= @userId
				,intEntityId			= @UserEntityID
				,dtmDateEntered		= GETDATE()
				,strBatchId			= @batchId
				,strCode				= 'AR'
				,strModuleName		= @MODULE_NAME
				,strTransactionForm	= @SCREEN_NAME
				,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN 
			tblARCustomer D 
				ON A.intCustomerId = D.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId 
		WHERE
			B.dblPayment <> 0

				
		UNION ALL	
			
		--Discount
		SELECT
			A.intPaymentId
			,A.strRecordNumber
			,B.intAccountId 
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId)
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit			= CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount END
			,dblCredit			= CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0  END
			,dblDebitUnit		= CASE WHEN @post = 1 THEN 0 ELSE ISNULL(B.dblDiscount, 0)  * ISNULL(U.dblLbsPerUnit, 0) END
			,dblCreditUnit		= CASE WHEN @post = 1 THEN ISNULL(B.dblDiscount, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END
			,DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,intEntityId			= @UserEntityID
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			B.dblAmountDue = (B.dblPayment + B.dblDiscount) --fully paid
			AND B.dblDiscount <> 0


--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
	IF (@post = 1)
		BEGIN

			WITH PaymentDetail
			AS
			(
				SELECT   dtmDate          = ISNULL(A.dtmDate, GETDATE())
						,intAccountId     = A.intAccountId
						,dblDebit         = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
													WHEN dblDebit < 0 THEN 0
													ELSE dblDebit END
						,dblCredit        = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
													WHEN dblCredit < 0 THEN 0
													ELSE dblCredit END
						,dblDebitUnit     = ISNULL(dblDebitUnit, 0)
						,dblCreditUnit    = ISNULL(dblCreditUnit, 0)
				FROM #tmpGLDetail A
			)
			UPDATE  tblGLSummary
			SET      dblDebit         = ISNULL(tblGLSummary.dblDebit, 0) + ISNULL(GLDetailGrouped.dblDebit, 0)
					,dblCredit        = ISNULL(tblGLSummary.dblCredit, 0) + ISNULL(GLDetailGrouped.dblCredit, 0)
					,dblDebitUnit     = ISNULL(tblGLSummary.dblDebitUnit, 0) + ISNULL(GLDetailGrouped.dblDebitUnit, 0)
					,dblCreditUnit    = ISNULL(tblGLSummary.dblCreditUnit, 0) + ISNULL(GLDetailGrouped.dblCreditUnit, 0)
					,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
			FROM    (
						SELECT   dblDebit         = SUM(ISNULL(B.dblDebit, 0))
								,dblCredit        = SUM(ISNULL(B.dblCredit, 0))
								,dblDebitUnit     = SUM(ISNULL(B.dblDebitUnit, 0))
								,dblCreditUnit    = SUM(ISNULL(B.dblCreditUnit, 0))
								,intAccountId     = A.intAccountId
								,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
						FROM tblGLSummary A
								INNER JOIN PaymentDetail B
								ON CONVERT(DATE, A.dtmDate) = CONVERT(DATE, B.dtmDate) AND A.intAccountId = B.intAccountId AND A.strCode = 'AR'
						GROUP BY ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId
					) AS GLDetailGrouped
			WHERE tblGLSummary.intAccountId = GLDetailGrouped.intAccountId AND tblGLSummary.strCode = 'AR' AND
				  ISNULL(CONVERT(DATE, tblGLSummary.dtmDate), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.dtmDate), '');
			IF @@ERROR <> 0   GOTO Post_Rollback;

			--=====================================================================================================================================
			--  INSERT TO GL SUMMARY RECORDS
			---------------------------------------------------------------------------------------------------------------------------------------
			WITH PaymentDetail
			AS
			(
				SELECT dtmDate        = ISNULL(A.dtmDate, GETDATE())
					,intAccountId     = A.intAccountId
					,dblDebit         = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
												WHEN dblDebit < 0 THEN 0
												ELSE dblDebit END
					,dblCredit        = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
												WHEN dblCredit < 0 THEN 0
												ELSE dblCredit END
					,dblDebitUnit     = ISNULL(A.dblDebitUnit, 0)
					,dblCreditUnit    = ISNULL(A.dblCreditUnit, 0)
				FROM #tmpGLDetail A
			)
			INSERT INTO tblGLSummary (
				 intAccountId
				,dtmDate
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strCode
				,intConcurrencyId
			)
			SELECT
				 intAccountId     = A.intAccountId
				,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
				,dblDebit         = SUM(A.dblDebit)
				,dblCredit        = SUM(A.dblCredit)
				,dblDebitUnit     = SUM(A.dblDebitUnit)
				,dblCreditUnit    = SUM(A.dblCreditUnit)
				,strCode = 'AR'
				,intConcurrencyId = 1
			FROM PaymentDetail A
			WHERE NOT EXISTS
					(
						SELECT TOP 1 1
						FROM tblGLSummary B
						WHERE ISNULL(CONVERT(DATE, A.dtmDate), '') = ISNULL(CONVERT(DATE, B.dtmDate), '') AND
							  A.intAccountId = B.intAccountId AND B.strCode = 'AR'
					)
			GROUP BY ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId;

		END
	ELSE
		BEGIN

			WITH GLDetail
			AS
			(
				SELECT   dtmDate      = ISNULL(A.dtmDate, GETDATE())
						,intAccountId = A.intAccountId
						,dblDebit     = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
												WHEN dblCredit < 0 THEN 0
												ELSE dblCredit END
						,dblCredit    = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
												WHEN dblDebit < 0 THEN 0
												ELSE dblDebit END
						,dblDebitUnit     = CASE  WHEN dblDebitUnit < 0 THEN ABS(dblDebitUnit)
												WHEN dblCreditUnit < 0 THEN 0
												ELSE dblCreditUnit END
						,dblCreditUnit    = CASE  WHEN dblCreditUnit < 0 THEN ABS(dblCreditUnit)
												WHEN dblDebitUnit < 0 THEN 0
												ELSE dblDebitUnit END
				FROM tblGLDetail A WHERE A.strTransactionId IN (SELECT strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData))
				AND ysnIsUnposted = 0 AND strCode = 'AR'
			)
			UPDATE  tblGLSummary
			SET      dblDebit = ISNULL(tblGLSummary.dblDebit, 0) - ISNULL(GLDetailGrouped.dblDebit, 0)
					,dblCredit = ISNULL(tblGLSummary.dblCredit, 0) - ISNULL(GLDetailGrouped.dblCredit, 0)
					,dblDebitUnit = ISNULL(tblGLSummary.dblDebitUnit, 0) - ISNULL(GLDetailGrouped.dblDebitUnit, 0)
					,dblCreditUnit = ISNULL(tblGLSummary.dblCreditUnit, 0) - ISNULL(GLDetailGrouped.dblCreditUnit, 0)
					,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
			FROM    (
						SELECT   dblDebit         = SUM(ISNULL(B.dblCredit, 0))
								,dblCredit        = SUM(ISNULL(B.dblDebit, 0))
								,dblDebitUnit     = SUM(ISNULL(B.dblCreditUnit, 0))
								,dblCreditUnit    = SUM(ISNULL(B.dblDebitUnit, 0))
								,intAccountId     = A.intAccountId
								,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
						FROM tblGLSummary A
								INNER JOIN GLDetail B
								ON CONVERT(DATE, A.dtmDate) = CONVERT(DATE, B.dtmDate) AND A.intAccountId = B.intAccountId AND A.strCode = 'AR'
						GROUP BY ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId
					) AS GLDetailGrouped
			WHERE tblGLSummary.intAccountId = GLDetailGrouped.intAccountId AND tblGLSummary.strCode = 'AR' AND
				  ISNULL(CONVERT(DATE, tblGLSummary.dtmDate), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.dtmDate), '');

		END

	IF @@ERROR <> 0	GOTO Post_Rollback;

	IF(ISNULL(@post,0) = 0)
		BEGIN
			
			--Unposting Process
			UPDATE tblARPaymentDetail
			SET tblARPaymentDetail.dblAmountDue = (CASE WHEN B.dblAmountDue = 0 THEN B.dblDiscount + C.dblAmountDue + B.dblPayment ELSE (C.dblAmountDue + B.dblPayment) END)
			FROM tblARPayment A
				LEFT JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
				LEFT JOIN tblARInvoice C
					ON B.intInvoiceId = C.intInvoiceId
			WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

			--Update dblAmountDue, dtmDatePaid and ysnPaid on tblARInvoice
			UPDATE tblARInvoice
				SET tblARInvoice.dblAmountDue = B.dblAmountDue,
					tblARInvoice.ysnPaid = 0,
					tblARInvoice.dtmPostDate = NULL,	
					tblARInvoice.dblDiscount = 0,
					tblARInvoice.dblPayment = 0
					
			FROM tblARPayment A
						INNER JOIN tblARPaymentDetail B 
								ON A.intPaymentId = B.intPaymentId
						INNER JOIN tblARInvoice C
								ON B.intInvoiceId = C.intInvoiceId
						WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

			UPDATE tblGLDetail
				SET tblGLDetail.ysnIsUnposted = 1
			FROM tblARPayment A
				INNER JOIN tblGLDetail B
					ON A.strRecordNumber = B.strTransactionId
			WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

			---- Creating the temp table:
			--DECLARE @isSuccessful BIT
			--CREATE TABLE #tmpCMBankTransaction (
			-- --intTransactionId INT PRIMARY KEY,
			-- strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
			-- UNIQUE (strTransactionId))

			--INSERT INTO #tmpCMBankTransaction
			-- SELECT strRecordNumber FROM tblARPayment A
			-- INNER JOIN #tmpARReceivablePostData B ON A.intPaymentId = B.intPaymentId

			---- Calling the stored procedure
			--EXEC uspCMBankTransactionReversal @userId, @isSuccessful OUTPUT

			--update payment record based on record from tblCMBankTransaction
			UPDATE tblARPayment
				SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
			FROM tblARPayment A 
				INNER JOIN tblCMBankTransaction B
					ON A.strRecordNumber = B.strTransactionId
			WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

			--update payment record
			UPDATE tblARPayment
				SET ysnPosted= 0
			FROM tblARPayment A 
			WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
			
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

			IF @@ERROR <> 0 OR @success = 0 GOTO Post_Rollback;

		END
	ELSE
		BEGIN

			-- Update the posted flag in the transaction table
			UPDATE tblARPayment
			SET		ysnPosted = 1
					--,intConcurrencyId += 1 
			WHERE	intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)

			UPDATE tblARPaymentDetail
				SET tblARPaymentDetail.dblAmountDue = (B.dblAmountDue) - (B.dblPayment + B.dblDiscount)
			FROM tblARPayment A
				LEFT JOIN tblARPaymentDetail B
					ON A.intPaymentId = B.intPaymentId
			WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)


			--Update dblAmountDue, dtmDatePaid and ysnPaid on tblARInvoice
			UPDATE tblARInvoice
				SET tblARInvoice.dblAmountDue = B.dblAmountDue,
					tblARInvoice.ysnPaid = (CASE WHEN (B.dblAmountDue) = 0 THEN 1 ELSE 0 END),
					tblARInvoice.dtmPostDate = (CASE WHEN (B.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE NULL END)
			FROM tblARPayment A
						INNER JOIN tblARPaymentDetail B 
								ON A.intPaymentId = B.intPaymentId
						INNER JOIN tblARInvoice C
								ON B.intInvoiceId = C.intInvoiceId
						WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
						
			UPDATE tblARInvoice
				SET tblARInvoice.dblDiscount = (
													SELECT
														SUM(dblDiscount)
													FROM tblARPaymentDetail 															
													WHERE
														intInvoiceId = B.intInvoiceId
														AND intPaymentId = A.intPaymentId																											
												)
					,dblPayment = A.dblAmountPaid 
			FROM tblARPayment A
						INNER JOIN tblARPaymentDetail B 
								ON A.intPaymentId = B.intPaymentId
						INNER JOIN tblARInvoice C
								ON B.intInvoiceId = C.intInvoiceId
						WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)					

			--Update Bill Amount Due associated on the other payment record
			UPDATE tblARPaymentDetail
			SET dblAmountDue = C.dblAmountDue
			FROM tblARPaymentDetail A
				INNER JOIN tblARPayment B
					ON A.intPaymentId = B.intPaymentId
					AND A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
					AND B.ysnPosted = 0
				INNER JOIN tblARInvoice C
					ON A.intInvoiceId = C.intInvoiceId

			----Insert to bank transaction
			--INSERT INTO tblCMBankTransaction(
			--	strTransactionId,
			--	intBankTransactionTypeId,
			--	intBankAccountId,
			--	intCurrencyId,
			--	dblExchangeRate,
			--	dtmDate,
			--	strPayee,
			--	intPayeeId,
			--	strAddress,
			--	strZipCode,
			--	strCity,
			--	strState,
			--	strCountry,
			--	dblAmount,
			--	strAmountInWords,
			--	strMemo,
			--	strReferenceNo,
			--	ysnCheckToBePrinted,
			--	ysnCheckVoid,
			--	ysnPosted,
			--	strLink,
			--	ysnClr,
			--	dtmDateReconciled,
			--	intCreatedUserId,
			--	dtmCreated,
			--	intLastModifiedUserId,
			--	dtmLastModified,
			--	intConcurrencyId
			--)
			--SELECT
			--	strTransactionId = A.strRecordNumber,
			--	intBankTransactionTypeID = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AR Payment'),
			--	intBankAccountID = A.intBankAccountId,
			--	intCurrencyID = A.intCurrencyId,
			--	dblExchangeRate = 0,
			--	dtmDate = A.dtmDatePaid,
			--	strPayee = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.intEntityId),
			--	intPayeeID = B.intEntityId,
			--	strAddress = '',
			--	strZipCode = '',
			--	strCity = '',
			--	strState = '',
			--	strCountry = '',
			--	dblAmount = A.dblAmountPaid,
			--	strAmountInWords = dbo.fnConvertNumberToWord(A.dblAmountPaid),
			--	strMemo = '',
			--	strReferenceNo = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE '' END,
			--	ysnCheckToBePrinted = 1,
			--	ysnCheckVoid = 0,
			--	ysnPosted = 1,
			--	strLink = @batchId,
			--	ysnClr = 0,
			--	dtmDateReconciled = NULL,
			--	intCreatedUserID = @userId,
			--	dtmCreated = GETDATE(),
			--	intLastModifiedUserID = NULL,
			--	dtmLastModified = GETDATE(),
			--	intConcurrencyId = 1
			--	FROM tblARPayment A
			--		INNER JOIN tblARCustomer B
			--			ON A.intCustomerId = B.intCustomerId
			--		--LEFT JOIN tblSMPaymentMethod C ON A.intPaymentMethodId = C.intPaymentMethodID
			--	WHERE A.intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
			--	--AND C.strPaymentMethod = 'Check'

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

		--RECAR
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intPaymentId FROM #tmpARReceivablePostData);

		--GO

		WITH Units 
		AS 
		(
			SELECT	A.dblLbsPerUnit, B.intAccountId 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.intAccountUnitId = B.intAccountUnitId
		)
		INSERT INTO tblGLDetailRecap (
			 strTransactionId
			,intTransactionId
			,intAccountId
			,strDescription
			,strReference	
			,dtmTransactionDate
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,dtmDate
			,ysnIsUnposted
			,intConcurrencyId	
			,dblExchangeRate
			,intUserId
			,dtmDateEntered
			,strBatchId
			,strCode
			,strModuleName
			,strTransactionForm
			,strTransactionType
		)
		--DEBIT SIDE
		SELECT
			 strRecordNumber
			,A.intPaymentId
			,A.intAccountId
			,GLAccnt.strDescription
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit		= (CASE WHEN @post = 1 THEN A.dblAmountPaid ELSE 0 END)
			,dblCredit		= (CASE WHEN @post = 1 THEN 0 ELSE A.dblAmountPaid END)
			,dblDebitUnit	= (CASE WHEN @post = 1 THEN (ISNULL(A.dblAmountPaid, 0))  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END)
			,dblCreditUnit	= (CASE WHEN @post = 1 THEN 0 ELSE (ISNULL(A.dblAmountPaid, 0)) * ISNULL(U.dblLbsPerUnit, 0) END)
			,A.dtmDatePaid
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblGLAccount GLAccnt
				ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId	

		--Discount
		UNION ALL
		SELECT
			 strRecordNumber
			,A.intPaymentId
			,(SELECT intAccountId FROM tblGLAccount WHERE intAccountId = L.intSalesDiscounts)
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = L.intSalesDiscounts)
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit			= CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0 END
			,dblCredit			= CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount  END
			,dblDebitUnit		= CASE WHEN @post = 1 THEN ISNULL(B.dblDiscount, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END
			,dblCreditUnit		= CASE WHEN @post = 1 THEN 0 ELSE ISNULL(B.dblDiscount, 0) * ISNULL(U.dblLbsPerUnit, 0) END
			,A.dtmDatePaid
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intLocationId = L.intCompanyLocationId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId					
		WHERE
			1 = (CASE WHEN @post = 1 AND B.dblAmountDue = (B.dblPayment + B.dblDiscount) THEN  1--fully paid when unposted
					  WHEN  @post = 0 AND B.dblAmountDue = 0 THEN 1 --fully paid when posted
					  ELSE 0 END)
			AND B.dblDiscount <> 0

		
		---- CREDIT SIDE
		UNION ALL 
		SELECT	strRecordNumber
				,A.intPaymentId
				,B.intAccountId
				,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId)
				,D.strCustomerNumber
				,A.dtmDatePaid
				,dblDebit			= CASE WHEN @post = 1 THEN 0 
											ELSE (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) END
				,dblCredit			= CASE WHEN @post = 1 THEN (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) 
											ELSE 0 END 
				,dblDebitUnit			= CASE WHEN @post = 1 THEN 0
										  ELSE (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)  * ISNULL(U.dblLbsPerUnit, 0) END
				,dblCreditUnit		= CASE WHEN @post = 1 THEN (CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END) * ISNULL(U.dblLbsPerUnit, 0)
										  ELSE 0 END
				,A.dtmDatePaid
				,CASE WHEN @post = 1 THEN 0 ELSE 1 END
				,1
				,dblExchangeRate		= 1
				,intUserId			= @userId
				,dtmDateEntered		= GETDATE()
				,strBatchId			= @batchId
				,strCode				= 'AR'
				,strModuleName		= @MODULE_NAME
				,strTransactionForm	= @SCREEN_NAME
				,strTransactionType	= @SCREEN_NAME
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN 
			tblARCustomer D 
				ON A.intCustomerId = D.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId 				
		WHERE
			B.dblPayment <> 0
		
		
		UNION ALL	
			
		--Discount
		SELECT
			A.strRecordNumber
			,A.intPaymentId
			,B.intAccountId 
			,(SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId)
			,C.strCustomerNumber
			,A.dtmDatePaid
			,dblDebit			= CASE WHEN @post = 1 THEN 0 ELSE B.dblDiscount END
			,dblCredit			= CASE WHEN @post = 1 THEN B.dblDiscount ELSE 0  END
			,dblDebitUnit		= CASE WHEN @post = 1 THEN 0 ELSE ISNULL(B.dblDiscount, 0)  * ISNULL(U.dblLbsPerUnit, 0) END
			,dblCreditUnit		= CASE WHEN @post = 1 THEN ISNULL(B.dblDiscount, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END
			,DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,CASE WHEN @post = 1 THEN 0 ELSE 1 END
			,1
			,dblExchangeRate		= 1
			,intUserId			= @userId
			,dtmDateEntered		= GETDATE()
			,strBatchId			= @batchId
			,strCode				= 'AR'
			,strModuleName		= @MODULE_NAME
			,strTransactionForm	= @SCREEN_NAME
			,strTransactionType	= @SCREEN_NAME	
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId
		INNER JOIN
			#tmpARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			B.dblAmountDue = (B.dblPayment + B.dblDiscount) --fully paid
			AND B.dblDiscount <> 0
		

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
	SET @recapId = (SELECT TOP 1 intPaymentId FROM #tmpARReceivablePostData) --only support recAR per record
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
			DELETE FROM tblARPaymentDetail
			WHERE intPaymentId IN (SELECT intPaymentId FROM #tmpARReceivablePostData)
			AND dblPayment = 0
		END

		----IF(@post = 1)
		----BEGIN

		----	----clean gl detail recAR after posting
		----	--DELETE FROM tblGLDetailRecap
		----	--FROM tblGLDetailRecap A
		----	--INNER JOIN #tmpARReceivablePostData B ON A.intTransactionId = B.intPaymentId 

		
		----	----removed from tblARInvalidTransaction the successful records
		----	--DELETE FROM tblARInvalidTransaction
		----	--FROM tblARInvalidTransaction A
		----	--INNER JOIN #tmpARReceivablePostData B ON A.intTransactionId = B.intPaymentId 

		----END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpARReceivablePostData')) DROP TABLE #tmpARReceivablePostData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..##tmpPayableInvalidData')) DROP TABLE #tmpPayableInvalidData
