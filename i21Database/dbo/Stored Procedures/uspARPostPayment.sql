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
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT,
	@transType			AS NVARCHAR(25)		= 'all'
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Payment Transaction' + CAST(NEWID() AS NVARCHAR(100));
 
DECLARE @ARReceivablePostData TABLE (
	intPaymentId int PRIMARY KEY,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	UNIQUE (intPaymentId)
);

DECLARE @ARReceivableInvalidData TABLE (
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	strBatchNumber NVARCHAR(50),
	intTransactionId INT
);

DECLARE @AROverpayment TABLE (
	intPaymentId int PRIMARY KEY,
	UNIQUE (intPaymentId)
);

DECLARE @ARPrepayment TABLE (
	intPaymentId int PRIMARY KEY,
	UNIQUE (intPaymentId)
);

DECLARE @ZeroPayment TABLE (
	intPaymentId int PRIMARY KEY,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	UNIQUE (intPaymentId)
);

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Receive Payments'
DECLARE @CODE NVARCHAR(25) = 'AR'

DECLARE @ARAccount NVARCHAR(250)
		,@DiscountAccount NVARCHAR(250)
		
SELECT @ARAccount = strValue FROM tblSMPreferences WHERE strPreference = 'DefaultARAccount'
SELECT @DiscountAccount = strValue FROM tblSMPreferences WHERE strPreference = 'DefaultARDiscountAccount'
		

DECLARE @UserEntityID int
SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @userId),@userId)

SET @recapId = '1'
SET @success = 1

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)  
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

IF (@param IS NOT NULL) 
	BEGIN
		IF(@param = 'all')
			BEGIN
				INSERT INTO @ARReceivablePostData SELECT intPaymentId, strRecordNumber FROM tblARPayment WHERE ysnPosted = 0
			END
		ELSE
			BEGIN
				INSERT INTO @ARReceivablePostData SELECT intPaymentId, strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@param))
			END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		INSERT INTO @ARReceivablePostData
		SELECT intPaymentId, strRecordNumber FROM tblARPayment
		WHERE dtmDatePaid BETWEEN @beginDate AND @endDate AND ysnPosted = 0
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @ARReceivablePostData
		SELECT intPaymentId, strRecordNumber FROM tblARPayment
		WHERE intPaymentId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
	END

--Removed excluded payments to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @PaymentsExclude TABLE  (
			intPaymentId INT
		);

		INSERT INTO @PaymentsExclude
		SELECT intID FROM fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM @ARReceivablePostData A
		WHERE EXISTS(SELECT * FROM @PaymentsExclude B WHERE A.intPaymentId = B.intPaymentId)
	END

--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN
	
		-- Zero Payment
		INSERT INTO
			@ZeroPayment
		SELECT
			A.intPaymentId
			,A.strRecordNumber
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId	
		WHERE
			A.dblAmountPaid = 0					
		GROUP BY
			A.intPaymentId, A.strRecordNumber
		HAVING
			SUM(B.dblPayment) = 0			
		

		--POST VALIDATIONS
		IF @post = 1
			BEGIN

				--Payment without payment on detail (get all detail that has 0 payment)
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT
					'There was no payment to receive.'
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
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				WHERE
					A.dblAmountPaid = 0
					AND (NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE strTransactionType <> 'Invoice' AND intInvoiceId = B.intInvoiceId)
						AND B.dblPayment <> 0)
					
				GROUP BY
					A.intPaymentId, A.strRecordNumber
				HAVING
					SUM(B.dblPayment) = 0					

				--Payment without detail
				INSERT INTO 
					@ARReceivableInvalidData
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
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						
				WHERE
					B.intPaymentId IS NULL
					AND A.dblAmountPaid = 0
					
				--Return Payment not allowed
				INSERT INTO
					@ARReceivableInvalidData
				SELECT
					'Return Payment is not allowed.'
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
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) < 0
					AND EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = B.intInvoiceId AND B.dblPayment > 0 AND strTransactionType NOT IN ('Credit Memo', 'Overpayment', 'Prepayment'))

				--Fiscal Year
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId					
				WHERE
					ISNULL([dbo].isOpenAccountingDate(A.dtmDatePaid), 0) = 0
					
				--Company Location
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'Company location of ' + A.strRecordNumber + ' was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				WHERE L.intCompanyLocationId IS NULL
				
				--Sales Discount Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Discounts account in Company Preference was not set.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					tblARPaymentDetail D
						ON A.intPaymentId = D.intPaymentId
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId						 
				INNER JOIN
					tblSMCompanyLocation L
						ON A.intLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount G
						ON L.intSalesDiscounts = G.intAccountId						
				WHERE
					ISNULL(D.dblDiscount,0) <> 0
					AND (@DiscountAccount IS NULL OR LTRIM(RTRIM(@DiscountAccount)) = '')
					
				--Bank Account
				INSERT INTO 
					@ARReceivableInvalidData
				SELECT 
					'The Cash Account is not linked to any of the active Bank Account in Cash Management'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblGLAccount GL
						ON A.intAccountId = GL.intAccountId 
				INNER JOIN 
					tblGLAccountGroup AG
						ON GL.intAccountGroupId = AG.intAccountGroupId 											 
				LEFT OUTER JOIN
					tblCMBankAccount BA
						ON A.intAccountId = BA.intGLAccountId 						
				WHERE
					AG.strAccountGroup = 'Cash Accounts'
					AND (BA.intGLAccountId IS NULL
						 OR BA.ysnActive = 0)
					

				--NOT BALANCE 
				INSERT INTO
					@ARReceivableInvalidData
				SELECT
					'The debit and credit amounts are not balanced.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) < (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
					
				--+overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) > (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
					AND EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)	
					
				--+prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId				
				WHERE
					(A.dblAmountPaid) <> 0
					AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId), 0) = 0	
					AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)							

				--ALREADY POSTED
				INSERT INTO
					@ARReceivableInvalidData
				SELECT 
					'The transaction is already posted.'
					,'Receivable'
					,A.strRecordNumber
					,@batchId
					,A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					A.ysnPosted = 1

				--RECEIVABLES(S) ALREADY PAID IN FULL
				INSERT INTO
					@ARReceivableInvalidData
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
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					C.ysnPaid = 1 
					AND B.dblPayment <> 0
					
				INSERT INTO
					@ARReceivableInvalidData
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
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				WHERE
					B.dblPayment <> 0 
					AND C.ysnPaid = 0 
					AND C.dblAmountDue < (B.dblPayment + B.dblDiscount)
				
			END

		--UNPOSTING VALIDATIONS
		IF @post = 0
			BEGIN

				--Already cleared/reconciled
				INSERT INTO
					@ARReceivableInvalidData
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
				
				---overpayment
				INSERT INTO
					@AROverpayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON A.strRecordNumber = I.strComments 				
				WHERE
					I.strTransactionType = 'Overpayment'
					
				---prepayment
				INSERT INTO
					@ARPrepayment
				SELECT
					A.intPaymentId
				FROM
					tblARPayment A 
				INNER JOIN
					@ARReceivablePostData P
						ON A.intPaymentId = P.intPaymentId
				INNER JOIN
					tblARInvoice I
						ON A.strRecordNumber = I.strComments 				
				WHERE
					I.strTransactionType = 'Prepayment'					
					
			END
		
	--Get all invalid
		DECLARE @totalInvalid INT
		SET @totalInvalid = (SELECT COUNT(*) FROM @ARReceivableInvalidData)

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
					@ARReceivableInvalidData

				SET @invalidCount = @totalInvalid

				--DELETE Invalid Transaction From temp table
				DELETE 
					@ARReceivablePostData
				FROM
					@ARReceivablePostData A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intPaymentId = I.intTransactionId
												
						
				DELETE 
					@AROverpayment
				FROM
					@AROverpayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intPaymentId = I.intTransactionId	
						
				DELETE 
					@ARPrepayment
				FROM
					@ARPrepayment A
				INNER JOIN 
					@ARReceivableInvalidData I
						ON A.intPaymentId = I.intTransactionId											

			END

	--Get all to be post record
		DECLARE @totalRecords INT
		SELECT @totalRecords = COUNT(*) FROM @ARReceivablePostData

		IF(@totalInvalid >= 1)  
			BEGIN			
				DECLARE @ErrorMessage NVARCHAR(100)				
				SELECT TOP 1 @ErrorMessage = strError FROM @ARReceivableInvalidData
				RAISERROR(@ErrorMessage, 11, 1) 
				SET @success = 0 
				GOTO Post_Exit
			END
			
		IF(@totalRecords = 0)  
			BEGIN			
				SET @success = 0 
				GOTO Post_Exit
			END	
	END

-- Get the next batch number
IF(@batchId IS NULL AND @param IS NOT NULL AND @param <> 'all')
	BEGIN
		SELECT TOP 1
			@batchId = GL.strBatchId
		FROM
			tblGLDetailRecap GL
		INNER JOIN 
			@ARReceivablePostData I
				ON GL.intTransactionId = I.intPaymentId
				AND GL.strTransactionId = I.strTransactionId
		WHERE
			GL.strTransactionType = @SCREEN_NAME
			AND	GL.strModuleName = @MODULE_NAME
	END
	
IF(@batchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @batchId OUT
	END

SET @batchIdUsed = @batchId


IF @recap = 1
BEGIN
	IF @post = 1
		BEGIN
			--+overpayment
			INSERT INTO
				@AROverpayment
			SELECT
				A.intPaymentId
			FROM
				tblARPayment A 
			INNER JOIN
				@ARReceivablePostData P
					ON A.intPaymentId = P.intPaymentId				
			WHERE
				(A.dblAmountPaid) > (SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId)
				AND EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)


			--+prepayment
			INSERT INTO
				@ARPrepayment
			SELECT
				A.intPaymentId
			FROM
				tblARPayment A 
			INNER JOIN
				@ARReceivablePostData P
					ON A.intPaymentId = P.intPaymentId				
			WHERE
				(A.dblAmountPaid) <> 0
				AND ISNULL((SELECT SUM(dblPayment) FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId), 0) = 0
				AND NOT EXISTS(SELECT NULL FROM tblARPaymentDetail WHERE intPaymentId = A.intPaymentId AND dblPayment <> 0)
		
		END
	ELSE
		BEGIN
		
			---overpayment
			INSERT INTO
				@AROverpayment
			SELECT
				A.intPaymentId
			FROM
				tblARPayment A 
			INNER JOIN
				@ARReceivablePostData P
					ON A.intPaymentId = P.intPaymentId
			INNER JOIN
				tblARInvoice I
					ON A.strRecordNumber = I.strComments 				
			WHERE
				I.strTransactionType = 'Overpayment'

			---prepayment
			INSERT INTO
				@ARPrepayment
			SELECT
				A.intPaymentId
			FROM
				tblARPayment A 
			INNER JOIN
				@ARReceivablePostData P
					ON A.intPaymentId = P.intPaymentId
			INNER JOIN
				tblARInvoice I
					ON A.strRecordNumber = I.strComments 				
			WHERE
				I.strTransactionType = 'Prepayment'			
		END
			
END


--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @post = 1  
	BEGIN
		---- Delete zero payment temporarily
		--DELETE FROM A
		--FROM @ARReceivablePostData A
		--WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)
			  		 
		INSERT INTO @GLEntries (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
		)
		--DEBIT
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= A.intAccountId
			,dblDebit					= A.dblAmountPaid
			,dblCredit					= 0
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= A.strNotes 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A 
		INNER JOIN
			tblGLAccount GLAccnt
				ON A.intAccountId = GLAccnt.intAccountId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
				
		UNION ALL
		--CREDIT Overpayment
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= @ARAccount
			,dblDebit					= 0
			,dblCredit					= A.dblUnappliedAmount 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount)  
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.intEntityCustomerId
		INNER JOIN
			@AROverpayment P
				ON A.intPaymentId = P.intPaymentId
				
		UNION ALL
		--CREDIT Prepayment
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= @ARAccount 
			,dblDebit					= 0
			,dblCredit					= A.dblAmountPaid 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.intEntityCustomerId
		INNER JOIN
			@ARPrepayment P
				ON A.intPaymentId = P.intPaymentId
				
				
		UNION ALL
		--DEBIT Discount
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= @DiscountAccount 
			,dblDebit					= SUM(B.dblDiscount)
			,dblCredit					= 0 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @DiscountAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			B.dblDiscount <> 0
			AND B.dblPayment <> 0
		GROUP BY
			A.intPaymentId
			,A.strRecordNumber
			,C.strCustomerNumber
			,A.dtmDatePaid
			,A.intCurrencyId	
			
			
		UNION ALL
		--CREDIT
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= B.intAccountId 
			,dblDebit					= 0
			,dblCredit					= SUM((CASE WHEN (B.dblAmountDue = B.dblPayment + B.dblDiscount) --add discount only if fully paid
												THEN B.dblPayment + B.dblDiscount
												ELSE B.dblPayment END)) 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = B.intAccountId) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId 
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A 
		INNER JOIN 
			tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN 
			tblARCustomer C 
				ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId 
		WHERE
			B.dblPayment <> 0
		GROUP BY
			A.intPaymentId
			,A.strRecordNumber
			,B.intAccountId
			,C.strCustomerNumber
			,A.dtmDatePaid
			,A.intCurrencyId	
			
		UNION ALL
		
		SELECT
			 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDatePaid), 0)
			,strBatchID					= @batchId
			,intAccountId				= @ARAccount
			,dblDebit					= 0
			,dblCredit					= SUM(B.dblDiscount) 
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0				
			,strDescription				= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = @ARAccount) 
			,strCode					= @CODE
			,strReference				= C.strCustomerNumber
			,intCurrencyId				= A.intCurrencyId  
			,dblExchangeRate			= 1
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= A.dtmDatePaid
			,strJournalLineDescription	= 'Posted ' + @SCREEN_NAME 
			,intJournalLineNo			= A.intPaymentId
			,ysnIsUnposted				= 0
			,intUserId					= @userId
			,intEntityId				= @UserEntityID				
			,strTransactionId			= A.strRecordNumber
			,intTransactionId			= A.intPaymentId
			,strTransactionType			= @SCREEN_NAME
			,strTransactionForm			= @SCREEN_NAME
			,strModuleName				= @MODULE_NAME
			,intConcurrencyId			= 1				 
		FROM
			tblARPayment A 
		INNER JOIN
			tblARPaymentDetail B
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN
			tblARCustomer C
				ON A.[intEntityCustomerId] = C.[intEntityCustomerId]
		INNER JOIN
			@ARReceivablePostData P
				ON A.intPaymentId = P.intPaymentId
		WHERE
			B.dblDiscount <> 0
			AND B.dblPayment <> 0
		GROUP BY
			A.intPaymentId
			,A.strRecordNumber
			,C.strCustomerNumber
			,A.dtmDatePaid
			,A.intCurrencyId						
					
			
	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @post = 0   
	BEGIN   								
		BEGIN 
			INSERT INTO @GLEntries(
				 dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
			)
			SELECT	
				 GL.dtmDate
				,@batchId
				,GL.intAccountId
				,dblDebit						= GL.dblCredit
				,dblCredit						= GL.dblDebit
				,dblDebitUnit					= GL.dblCreditUnit
				,dblCreditUnit					= GL.dblDebitUnit
				,GL.strDescription
				,GL.strCode
				,GL.strReference
				,GL.intCurrencyId
				,GL.dblExchangeRate
				,dtmDateEntered					= GETDATE()
				,GL.dtmTransactionDate
				,GL.strJournalLineDescription
				,GL.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,GL.strTransactionId
				,GL.intTransactionId
				,GL.strTransactionType
				,GL.strTransactionForm
				,GL.strModuleName
				,GL.intConcurrencyId
			FROM
				tblGLDetail GL
			INNER JOIN
				@ARReceivablePostData P
					ON GL.intTransactionId = P.intPaymentId  
					AND GL.strTransactionId = P.strTransactionId
			WHERE
				GL.ysnIsUnposted = 0
			ORDER BY
				GL.intGLDetailId		
						
		END		
	END   

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1.	Store all the GL entries in a holding table. It will be used later as data  
--		for the recap screen.
--
-- 2.	Rollback the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 1
	BEGIN 
		ROLLBACK TRAN @TransactionName
		
		DELETE tblGLDetailRecap  
		FROM 
			tblGLDetailRecap A 
		INNER JOIN @ARReceivablePostData B  
		   ON (A.strTransactionId = B.strTransactionId OR A.intTransactionId = B.intPaymentId)  
		   AND  A.strCode = @CODE  
		   
		   
		--EXEC dbo.uspCMPostRecap @GLEntries
		
		INSERT INTO tblGLDetailRecap (  
		  [dtmDate]  
		  ,[strBatchId]  
		  ,[intAccountId]  
		  ,[dblDebit]  
		  ,[dblCredit]  
		  ,[dblDebitUnit]  
		  ,[dblCreditUnit]  
		  ,[strDescription]  
		  ,[strCode]  
		  ,[strReference]  
		  ,[intCurrencyId]  
		  ,[dblExchangeRate]  
		  ,[dtmDateEntered]  
		  ,[dtmTransactionDate]  
		  ,[strJournalLineDescription]  
		  ,[intJournalLineNo]  
		  ,[ysnIsUnposted]  
		  ,[intUserId]  
		  ,[intEntityId]  
		  ,[strTransactionId]  
		  ,[intTransactionId]  
		  ,[strTransactionType]  
		  ,[strTransactionForm]  
		  ,[strModuleName]  
		  ,[intConcurrencyId]  
		)  
		-- RETRIEVE THE DATA FROM THE TABLE VARIABLE.   
		SELECT [dtmDate]  
		  ,[strBatchId]  
		  ,[intAccountId]  
		  ,[dblDebit]  
		  ,[dblCredit]  
		  ,[dblDebitUnit]  
		  ,[dblCreditUnit]  
		  ,[strDescription]  
		  ,[strCode]  
		  ,[strReference]  
		  ,[intCurrencyId]  
		  ,[dblExchangeRate]  
		  ,[dtmDateEntered]  
		  ,[dtmTransactionDate]  
		  ,[strJournalLineDescription]  
		  ,[intJournalLineNo]  
		  ,[ysnIsUnposted]  
		  ,[intUserId]  
		  ,[intEntityId]  
		  ,[strTransactionId]  
		  ,[intTransactionId]  
		  ,[strTransactionType]  
		  ,[strTransactionForm]  
		  ,[strModuleName]  
		  ,[intConcurrencyId]  
		FROM 
			@GLEntries
			
		IF(@@ERROR <> 0)  
			BEGIN			
				SET @success = 0 
				GOTO Post_Exit
			END	
		COMMIT TRAN @TransactionName
	END 

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @post
		IF(@@ERROR <> 0)  
			BEGIN			
				SET @success = 0 
				GOTO Post_Exit
			END
		 
		IF @post = 0
			BEGIN
			
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)

			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblPayment = ISNULL(tblARInvoice.dblPayment,0.00) - P.dblPayment 
				,tblARInvoice.dblDiscount = ISNULL(tblARInvoice.dblDiscount,0.00) - P.dblDiscount 
			FROM
				(
					SELECT 
						SUM(A.dblPayment * (CASE WHEN C.strTransactionType = 'Invoice' THEN 1 ELSE -1 END)) dblPayment
						,SUM(A.dblDiscount) dblDiscount
						,A.intInvoiceId 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.intPaymentId = B.intPaymentId						
					INNER JOIN tblARInvoice C
						ON A.intInvoiceId = C.intInvoiceId
					WHERE
						A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
					GROUP BY
						A.intInvoiceId
				) P
			WHERE
				tblARInvoice.intInvoiceId = P.intInvoiceId
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblAmountDue = C.dblInvoiceTotal - (C.dblPayment + C.dblDiscount)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.ysnPaid = 0,
				tblARInvoice.dtmPostDate = (CASE WHEN (C.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE C.dtmPostDate END)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
				
				
			UPDATE 
				tblARPaymentDetail
			SET 
				dblAmountDue = A.dblInvoiceTotal - (A.dblPayment + A.dblDiscount)
				,dblPayment = 0.00
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.intPaymentId = B.intPaymentId
					AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			INNER JOIN 
				tblARInvoice C
					ON A.intInvoiceId = C.intInvoiceId
					
			UPDATE tblGLDetail
				SET tblGLDetail.ysnIsUnposted = 1
			FROM tblARPayment A
				INNER JOIN tblGLDetail B
					ON A.intPaymentId = B.intTransactionId
			WHERE B.[strTransactionId] IN (SELECT strRecordNumber FROM tblARPayment WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData))					
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARReceivablePostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)						
					
			-- Creating the temp table:
			DECLARE @isSuccessful BIT
			CREATE TABLE #tmpCMBankTransaction (strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,UNIQUE (strTransactionId))

			INSERT INTO #tmpCMBankTransaction
			SELECT strRecordNumber FROM tblARPayment A
			INNER JOIN @ARReceivablePostData B ON A.intPaymentId = B.intPaymentId

			-- Calling the stored procedure
			DECLARE @ReverseDate AS DATETIME
			SET @ReverseDate = GETDATE()
			EXEC uspCMBankTransactionReversal @userId, @ReverseDate, @isSuccessful OUTPUT
			
			--update payment record based on record from tblCMBankTransaction
			UPDATE tblARPayment
				SET strPaymentInfo = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
			FROM tblARPayment A 
				INNER JOIN tblCMBankTransaction B
					ON A.strRecordNumber = B.strTransactionId
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)	
			
			--DELETE IF NOT CHECK PAYMENT AND DOESN'T HAVE CHECK NUMBER
			DELETE FROM tblCMBankTransaction
			WHERE strTransactionId IN (
			SELECT strRecordNumber 
			FROM tblARPayment
				INNER JOIN tblSMPaymentMethod ON tblARPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
			 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData) 
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
				 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData) 
			)							
				
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)			
			
			--update payment record
			UPDATE tblARPayment
				SET ysnPosted= 0
			FROM tblARPayment A 
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)

			--Insert Successfully unposted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@UnpostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			
			--DELETE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN			
					DECLARE @PaymentIdToDelete int		
					SELECT TOP 1 @PaymentIdToDelete = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToDelete
				END	
				
			--DELETE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN			
					DECLARE @PaymentIdToDeletePre int		
					SELECT TOP 1 @PaymentIdToDeletePre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToDeletePre
					
				END										

			END
		ELSE
			BEGIN
			
			--CREATE Overpayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @AROverpayment)
				BEGIN
					DECLARE @PaymentIdToAdd int
					SELECT TOP 1 @PaymentIdToAdd = intPaymentId FROM @AROverpayment
					
					EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @AROverpayment WHERE intPaymentId = @PaymentIdToAdd
				END
				
			--CREATE Prepayment
			WHILE EXISTS(SELECT TOP 1 NULL FROM @ARPrepayment)
				BEGIN
					DECLARE @PaymentIdToAddPre int
					SELECT TOP 1 @PaymentIdToAddPre = intPaymentId FROM @ARPrepayment
					
					EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @batchId ,@UserEntityID 
					
					DELETE FROM @ARPrepayment WHERE intPaymentId = @PaymentIdToAddPre
				END				

			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)		

			-- Update the posted flag in the transaction table
			UPDATE tblARPayment
			SET		ysnPosted = 1
					--,intConcurrencyId += 1 
			WHERE	intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)

			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblPayment = ISNULL(tblARInvoice.dblPayment,0.00) + P.dblPayment 
				,tblARInvoice.dblDiscount = ISNULL(tblARInvoice.dblDiscount,0.00) + P.dblDiscount 
			FROM
				(
					SELECT 
						SUM(A.dblPayment * (CASE WHEN C.strTransactionType = 'Invoice' THEN 1 ELSE -1 END)) dblPayment
						,SUM(A.dblDiscount) dblDiscount
						,A.intInvoiceId 
					FROM
						tblARPaymentDetail A
					INNER JOIN tblARPayment B
							ON A.intPaymentId = B.intPaymentId						
					INNER JOIN tblARInvoice C
						ON A.intInvoiceId = C.intInvoiceId
					WHERE
						A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
					GROUP BY
						A.intInvoiceId
				) P
			WHERE
				tblARInvoice.intInvoiceId = P.intInvoiceId
				
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.dblAmountDue = C.dblInvoiceTotal - (C.dblPayment + C.dblDiscount)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)	
					
				
			UPDATE 
				tblARInvoice
			SET 
				tblARInvoice.ysnPaid = (CASE WHEN (C.dblAmountDue) = 0 THEN 1 ELSE 0 END),
				tblARInvoice.dtmPostDate = (CASE WHEN (C.dblAmountDue) = 0 THEN A.dtmDatePaid ELSE C.dtmPostDate END)
			FROM 
				tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
			WHERE
				A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)							
								

			UPDATE 
				tblARPaymentDetail
			SET 
				dblAmountDue = 0.00
			FROM
				tblARPaymentDetail A
			INNER JOIN
				tblARPayment B
					ON A.intPaymentId = B.intPaymentId
					AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
			INNER JOIN 
				tblARInvoice C
					ON A.intInvoiceId = C.intInvoiceId
					
			-- Delete zero payment temporarily
			DELETE FROM A
			FROM @ARReceivablePostData A
			WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.intPaymentId = B.intPaymentId)						

			--Insert to bank transaction
			INSERT INTO tblCMBankTransaction(
				strTransactionId,
				intBankTransactionTypeId,
				intBankAccountId,
				intCurrencyId,
				dblExchangeRate,
				dtmDate,
				strPayee,
				intPayeeId,
				strAddress,
				strZipCode,
				strCity,
				strState,
				strCountry,
				dblAmount,
				strAmountInWords,
				strMemo,
				strReferenceNo,
				ysnCheckToBePrinted,
				ysnCheckVoid,
				ysnPosted,
				strLink,
				ysnClr,
				dtmDateReconciled,
				intCreatedUserId,
				dtmCreated,
				intLastModifiedUserId,
				dtmLastModified,
				strSourceSystem,
				intConcurrencyId
			)
			SELECT DISTINCT
				strTransactionId = A.strRecordNumber,
				intBankTransactionTypeID = (SELECT TOP 1 intBankTransactionTypeId FROM tblCMBankTransactionType WHERE strBankTransactionTypeName = 'AR Payment'),
				intBankAccountID = (SELECT TOP 1 intBankAccountId FROM tblCMBankAccount WHERE intGLAccountId = A.intAccountId),
				intCurrencyID = A.intCurrencyId,
				dblExchangeRate = 0,
				dtmDate = A.dtmDatePaid,
				strPayee = (SELECT TOP 1 strName FROM tblEntity WHERE intEntityId = B.[intEntityCustomerId]),
				intPayeeID = B.[intEntityCustomerId],
				strAddress = '',
				strZipCode = '',
				strCity = '',
				strState = '',
				strCountry = '',
				dblAmount = A.dblAmountPaid,
				strAmountInWords = dbo.fnConvertNumberToWord(A.dblAmountPaid),
				strMemo = SUBSTRING(ISNULL(A.strPaymentInfo + ' - ', '') + ISNULL(A.strNotes, ''), 1 ,255),
				strReferenceNo = CASE WHEN (SELECT strPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID = A.intPaymentMethodId) = 'Cash' THEN 'Cash' ELSE A.strPaymentInfo END,
				ysnCheckToBePrinted = 1,
				ysnCheckVoid = 0,
				ysnPosted = 1,
				strLink = @batchId,
				ysnClr = 0,
				dtmDateReconciled = NULL,
				intCreatedUserID = @userId,
				dtmCreated = GETDATE(),
				intLastModifiedUserID = NULL,
				dtmLastModified = GETDATE(),
				strSourceSystem = 'AR',
				intConcurrencyId = 1
				FROM tblARPayment A
					INNER JOIN tblARCustomer B
						ON A.[intEntityCustomerId] = B.[intEntityCustomerId]
				INNER JOIN
					tblGLAccount GL
						ON A.intAccountId = GL.intAccountId 
				INNER JOIN 
					tblGLAccountGroup AG
						ON GL.intAccountGroupId = AG.intAccountGroupId 											 
				INNER JOIN
					tblCMBankAccount BA
						ON A.intAccountId = BA.intGLAccountId 						
				WHERE
					AG.strAccountGroup = 'Cash Accounts'
					AND BA.intGLAccountId IS NOT NULL
					AND BA.ysnActive = 1
					AND A.intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)
					
			-- Insert Zero Payments for updating
			INSERT INTO @ARReceivablePostData
			SELECT Z.intPaymentId, Z.strTransactionId FROM @ZeroPayment Z
			WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE intPaymentId = Z.intPaymentId)						

			--Insert Successfully posted transactions.
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 
				@PostSuccessfulMsg,
				'Receivable',
				A.strRecordNumber,
				@batchId,
				A.intPaymentId
			FROM tblARPayment A
			WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData)				
			END						
			
		COMMIT TRAN @TransactionName
	END
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	RETURN;
	