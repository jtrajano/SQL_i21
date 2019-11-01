﻿CREATE PROCEDURE [dbo].[uspARProcessNSF]
	  @intNSFTransactionId	INT
	, @intUserId			INT
	, @strCreatedIvoices 	VARCHAR(500) = NULL OUTPUT
	, @strMessage			VARCHAR(500) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intNSFPaymentMethodId 				INT = NULL
DECLARE @intPaymentId 						INT = NULL
DECLARE @intStartingNumberId				INT = NULL
DECLARE @intNewBankTransactionId			INT = NULL
DECLARE @strErrorMsg						NVARCHAR(MAX) = NULL
DECLARE @strInvoiceNumbers					NVARCHAR(MAX) = NULL
DECLARE @strTransactionId					NVARCHAR(100) = ''
DECLARE @STARTING_NUMBER_BANK_WITHDRAWAL 	NVARCHAR(100) = 'Bank Withdrawal'
DECLARE @ysnSuccess							BIT = 0
DECLARE @GLEntries							RecapTableType
DECLARE @BankTransaction					BankTransactionTable
DECLARE @BankTransactionDetail				BankTransactionDetailTable

SELECT TOP 1 @intNSFPaymentMethodId = intPaymentMethodID
FROM dbo.tblSMPaymentMethod 
WHERE strPaymentMethod = 'NSF'

--INSERT DEFAULT NSF PAYMENT METHOD
IF ISNULL(@intNSFPaymentMethodId, 0) = 0
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		VALUES (
			  'NSF'
			, 1
			, 1
			, 0
			, 1
		)

		SET @intNSFPaymentMethodId = SCOPE_IDENTITY()
	END

IF(OBJECT_ID('tempdb..#SELECTEDPAYMENTS') IS NOT NULL)
BEGIN
    DROP TABLE #SELECTEDPAYMENTS
END

IF(OBJECT_ID('tempdb..#NSFWITHOVERPAYMENTS') IS NOT NULL)
BEGIN
    DROP TABLE #NSFWITHOVERPAYMENTS
END

CREATE TABLE #SELECTEDPAYMENTS (
	  intTransactionId		INT				NOT NULL
	, intNSFAccountId		INT				NULL
	, dtmDate				DATETIME		NOT NULL
	, dblNSFBankCharge		NUMERIC(18, 6)	NULL
	, dblAmountPaid			NUMERIC(18, 6)	NULL
	, dblUnappliedAmount	NUMERIC(18, 6)	NULL
	, ysnInvoiceToCustomer	BIT				NULL
	, ysnInvoicePrepayment	BIT				NULL
	, strTransactionNumber	NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NOT NULL
	, strTransactionType	NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NOT NULL
	, intEntityCustomerId	INT				NOT NULL
	, intCurrencyId			INT				NOT NULL
	, intCompanyLocationId	INT				NOT NULL
	, intBankDepositId		INT				NULL
	, intAccountId			INT				NULL
)

INSERT INTO #SELECTEDPAYMENTS
SELECT intTransactionId		= NSF.intTransactionId
	 , intNSFAccountId		= NSF.intNSFAccountId
	 , dtmDate				= NSF.dtmDate
	 , dblNSFBankCharge		= NSF.dblNSFBankCharge
	 , dblAmountPaid		= PAYMENTS.dblAmountPaid
	 , dblUnappliedAmount	= PAYMENTS.dblUnappliedAmount
	 , ysnInvoiceToCustomer	= NSF.ysnInvoiceToCustomer
	 , ysnInvoicePrepayment	= PAYMENTS.ysnInvoicePrepayment
	 , strTransactionNumber	= PAYMENTS.strTransactionNumber
	 , strTransactionType	= NSF.strTransactionType
	 , intEntityCustomerId	= PAYMENTS.intEntityCustomerId
	 , intCurrencyId		= PAYMENTS.intCurrencyId
	 , intCompanyLocationId	= PAYMENTS.intCompanyLocationId
	 , intBankDepositId		= UF.intBankDepositId
	 , intAccountId			= PAYMENTS.intAccountId
FROM dbo.tblARNSFStagingTableDetail NSF WITH (NOLOCK)
INNER JOIN vyuARPaymentForNSF PAYMENTS ON NSF.intTransactionId = PAYMENTS.intTransactionId AND NSF.strTransactionType = PAYMENTS.strTransactionType
LEFT JOIN (
	SELECT intSourceTransactionId
		 , intBankDepositId
		 , strSourceTransactionId
	FROM dbo.tblCMUndepositedFund WITH (NOLOCK)
) UF ON UF.intSourceTransactionId = PAYMENTS.intTransactionId
	AND UF.strSourceTransactionId = PAYMENTS.strTransactionNumber
WHERE NSF.ysnProcessed = 0
  AND NSF.intNSFTransactionId = @intNSFTransactionId

SELECT intPaymentId		= NSF.intTransactionId
	 , intInvoiceId		= I.intInvoiceId
     , strRecordNumber	= NSF.strTransactionNumber
	 , strInvoiceNumber	= I.strInvoiceNumber
     , ysnPaid			= I.ysnPaid
INTO #NSFWITHOVERPAYMENTS
FROM #SELECTEDPAYMENTS NSF
INNER JOIN tblARInvoice I ON NSF.intTransactionId = I.intPaymentId AND NSF.strTransactionType = 'Payment'
WHERE I.strTransactionType = 'Overpayment'
  AND I.ysnPosted = 1

--VALIDATIONS
IF NOT EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS)
	BEGIN
		DELETE FROM tblARNSFStagingTableDetail WHERE intNSFTransactionId = @intNSFTransactionId
		RAISERROR('There are no Payments to process to NSF.', 16, 1) 
		RETURN 0;
	END

IF ISNULL(@intUserId, 0) = 0
	BEGIN
		DELETE FROM tblARNSFStagingTableDetail WHERE intNSFTransactionId = @intNSFTransactionId
		RAISERROR('User Id is required when processing to NSF.', 16, 1) 
		RETURN 0;
	END

IF EXISTS(SELECT TOP 1 NULL FROM #NSFWITHOVERPAYMENTS WHERE ysnPaid = 1)
	BEGIN
		DECLARE @strErrorMsgOverpayment		NVARCHAR(500) = ''

		SELECT TOP 1 @strErrorMsgOverpayment = 'Cannot process ' + strRecordNumber + ' to NSF. It has Overpayment (' + strInvoiceNumber + ') that was already used.'
		FROM #NSFWITHOVERPAYMENTS WHERE ysnPaid = 1

		DELETE FROM tblARNSFStagingTableDetail WHERE intNSFTransactionId = @intNSFTransactionId
		RAISERROR(@strErrorMsgOverpayment, 16, 1) 
		RETURN 0;
	END

--REVERSE GL ENTRIES
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
	,[dblDebitForeign]
	,[dblDebitReport]
	,[dblCreditForeign]
	,[dblCreditReport]
	,[dblReportingRate]
	,[dblForeignRate]
)
SELECT
	 [dtmDate]					= GL.dtmDate
	,[strBatchID]				= GL.strBatchId
	,[intAccountId]				= GL.intAccountId
	,[dblDebit]					= GL.dblCredit
	,[dblCredit]				= GL.dblDebit
	,[dblDebitUnit]				= GL.dblCreditUnit
	,[dblCreditUnit]			= GL.dblDebitUnit
	,[strDescription]			= 'NSF: ' + GL.strDescription
	,[strCode]					= GL.strCode
	,[strReference]				= GL.strReference
	,[intCurrencyId]			= GL.intCurrencyId
	,[dblExchangeRate]			= GL.dblExchangeRate
	,[dtmDateEntered]			= P.dtmDate
	,[dtmTransactionDate]		= GL.dtmTransactionDate
	,[strJournalLineDescription]= 'NSF'
	,[intJournalLineNo]			= GL.intJournalLineNo
	,[ysnIsUnposted]			= 0
	,[intUserId]				= GL.intUserId
	,[intEntityId]				= GL.intEntityId
	,[strTransactionId]			= GL.strTransactionId
	,[intTransactionId]			= GL.intTransactionId
	,[strTransactionType]		= GL.strTransactionType
	,[strTransactionForm]		= GL.strTransactionForm
	,[strModuleName]			= GL.strModuleName
	,[intConcurrencyId]			= 1
	,[dblDebitForeign]			= GL.dblCreditForeign
	,[dblDebitReport]			= GL.dblCreditReport
	,[dblCreditForeign]			= GL.dblDebitForeign
	,[dblCreditReport]			= GL.dblDebitReport
	,[dblReportingRate]			= GL.dblReportingRate
	,[dblForeignRate]			= GL.dblForeignRate
FROM dbo.tblGLDetail GL WITH (NOLOCK)
INNER JOIN #SELECTEDPAYMENTS P ON GL.intTransactionId = P.intTransactionId
							  AND GL.strTransactionId = P.strTransactionNumber
WHERE GL.ysnIsUnposted = 0
  AND GL.strCode = 'AR'

IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN
		EXEC dbo.uspGLBookEntries @GLEntries		= @GLEntries
								, @ysnPost			= 1
	END

--UPDATE CASH INVOICE RECORDS
UPDATE I
SET ysnProcessedToNSF	= 1
  , intPaymentMethodId	= @intNSFPaymentMethodId
  , strComments			= 'NSF Processed: ' + ISNULL(strPaymentInfo, '')  
FROM tblARInvoice I
INNER JOIN #SELECTEDPAYMENTS PAYMENTS ON I.intInvoiceId = PAYMENTS.intTransactionId AND PAYMENTS.strTransactionType = 'Cash'
WHERE ysnPosted = 1

--UPDATE PAYMENT RECORDS
UPDATE P
SET ysnProcessedToNSF	= 1
  , intPaymentMethodId	= @intNSFPaymentMethodId
  , strPaymentInfo		= 'NSF: ' + ISNULL(strPaymentInfo, '')  
  , strPaymentMethod	= 'NSF'
  , intCurrentStatus 	= 5
FROM tblARPayment P
INNER JOIN #SELECTEDPAYMENTS PAYMENTS ON P.intPaymentId = PAYMENTS.intTransactionId AND PAYMENTS.strTransactionType = 'Payment'
WHERE ysnPosted = 1

UPDATE P
SET  intCurrentStatus 	= NULL
FROM tblARPayment P
INNER JOIN #SELECTEDPAYMENTS PAYMENTS ON P.intPaymentId = PAYMENTS.intTransactionId AND PAYMENTS.strTransactionType = 'Payment'
WHERE ysnPosted = 1

--UPDATE INVOICES
UPDATE I
SET I.ysnPaid			= 0
  , I.dblPayment		= I.dblPayment - ABS(ISNULL(PAYMENTS.dblPayment, 0))
  , I.dblBasePayment	= I.dblBasePayment - ABS(ISNULL(PAYMENTS.dblBasePayment, 0))
  , I.dblAmountDue		= I.dblAmountDue + ABS(ISNULL(PAYMENTS.dblPayment, 0)) + ABS(ISNULL(PAYMENTS.dblDiscount, 0))
  , I.dblBaseAmountDue	= I.dblBaseAmountDue + ABS(ISNULL(PAYMENTS.dblBasePayment, 0)) + ABS(ISNULL(PAYMENTS.dblBaseDiscount, 0))
  , I.dblDiscount		= I.dblDiscount - ABS(ISNULL(PAYMENTS.dblDiscount, 0))
  , I.dblBaseDiscount	= I.dblBaseDiscount - ABS(ISNULL(PAYMENTS.dblBaseDiscount, 0))
FROM tblARInvoice I
INNER JOIN (
	SELECT PD.intInvoiceId
		 , PD.dblPayment
		 , PD.dblBasePayment
		 , PD.dblDiscount
		 , PD.dblBaseDiscount		 
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN #SELECTEDPAYMENTS P ON PD.intPaymentId = P.intTransactionId AND P.strTransactionType = 'Payment'
) PAYMENTS ON I.intInvoiceId = PAYMENTS.intInvoiceId
WHERE I.ysnPosted = 1

--UPDATE OVERPAYMENTS
UPDATE I
SET ysnPosted 			= 0
  , ysnProcessedToNSF 	= 1
  , strComments 		= 'NSF Processed'
FROM tblARInvoice I
INNER JOIN #NSFWITHOVERPAYMENTS NSF ON I.intInvoiceId = NSF.intInvoiceId

--INVOICE BANK CHARGES TO CUSTOMER
IF EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS WHERE ysnInvoiceToCustomer = 1)
	BEGIN
		DECLARE @InvoiceEntries		InvoiceIntegrationStagingTable
				
		INSERT INTO @InvoiceEntries (
			  [strTransactionType]
			, [strType]
			, [strSourceTransaction]
			, [intSourceId]
			, [strSourceId]
			, [intEntityCustomerId]
			, [intCompanyLocationId]			
			, [intCurrencyId]
			, [intEntityId]
			, [dtmDate]
			, [dtmDueDate]
			, [dtmShipDate]
			, [dtmPostDate]
			, [strComments]
			, [ysnPost]
			--detail
			, [intSalesAccountId]
			, [ysnInventory]
			, [strItemDescription]
			, [dblQtyShipped]
			, [dblPrice]
			, [intTaxGroupId]
			, [ysnRecomputeTax]
		)
		SELECT 'Invoice' 
			 , 'Standard'
			 , 'Direct'
			 , P.intTransactionId
			 , P.strTransactionNumber
			 , P.intEntityCustomerId
			 , P.intCompanyLocationId			 
			 , P.intCurrencyId
			 , @intUserId
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , 'NSF Payment for: ' + P.strTransactionNumber
			 , 1

			 --detail
			 , P.intNSFAccountId
			 , 0
			 , 'Bank Fees'
			 , 1
			 , P.dblNSFBankCharge
			 , NULL
			 , 0
		FROM #SELECTEDPAYMENTS P
		WHERE ysnInvoiceToCustomer = 1
		  AND intNSFAccountId IS NOT NULL
		  AND dblNSFBankCharge > 0.00
		
		IF EXISTS (SELECT TOP 1 NULL FROM @InvoiceEntries)
			EXEC dbo.uspARProcessInvoices @InvoiceEntries = @InvoiceEntries, @UserId = @intUserId, @GroupingOption = 0, @CreatedIvoices = @strCreatedIvoices OUT
	END

UPDATE tblARNSFStagingTableDetail 
SET ysnProcessed = 1 
WHERE intNSFTransactionId = @intNSFTransactionId

--CREATE NSF BANK TRANSACTION FOR DEPOSITED PAYMENTS
IF EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS WHERE ISNULL(intBankDepositId, 0) <> 0)
	BEGIN
		SET @strTransactionId			= ''
		SET @intStartingNumberId		= NULL
		SET @intNewBankTransactionId	= NULL
		SET @ysnSuccess					= 0

		DELETE FROM @BankTransaction
		DELETE FROM @BankTransactionDetail

		BEGIN TRY
			SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
			FROM dbo.tblSMStartingNumber 
			WHERE strTransactionType = @STARTING_NUMBER_BANK_WITHDRAWAL

			EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT

			INSERT INTO @BankTransaction (
				  [intBankAccountId]
				, [strTransactionId]
				, [intCurrencyId]
				, [intBankTransactionTypeId] 
				, [dtmDate]
				, [dblAmount]
				, [strMemo]			
				, [intCompanyLocationId]
				, [intEntityId]
				, [intCreatedUserId]
				, [intLastModifiedUserId])
			SELECT 
				 [intBankAccountId]				= UF.intBankAccountId
				,[strTransactionId]				= @strTransactionId
				,[intCurrencyId]				= SP.intCurrencyId
				,[intBankTransactionTypeId]		= 2
				,[dtmDate]						= SP.dtmDate
				,[dblAmount]					= SUM(UF.dblAmount) * -1
				,[strMemo]						= 'Reversal for ' + SP.strTransactionNumber
				,[intCompanyLocationId]			= UF.intLocationId
				,[intEntityId]					= @intUserId
				,[intCreatedUserId]				= @intUserId
				,[intLastModifiedUserId]		= @intUserId
			FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
			INNER JOIN #SELECTEDPAYMENTS SP ON UF.intSourceTransactionId = SP.intTransactionId
	  									   AND UF.strSourceTransactionId = SP.strTransactionNumber
			WHERE SP.intBankDepositId IS NOT NULL
			GROUP BY UF.intBankAccountId, SP.intCurrencyId, UF.intLocationId, SP.strTransactionNumber, SP.dtmDate

			INSERT INTO @BankTransactionDetail(
				  [intTransactionId]
				, [intUndepositedFundId]
				, [dtmDate]
				, [intGLAccountId]
				, [strDescription]
				, [dblDebit]
				, [dblCredit]
				, [intEntityId]
			)
			SELECT 
				  [intTransactionId]	= 0
				, [intUndepositedFundId] = UF.intUndepositedFundId
				, [dtmDate]				= UF.dtmDate
				, [intGLAccountId]		= SP.intAccountId
				, [strDescription]		= GL.strDescription
				, [dblDebit]			= ABS(ISNULL(SP.dblAmountPaid, 0))
				, [dblCredit]			= 0
				, [intEntityId]			= SP.intEntityCustomerId
			FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
			INNER JOIN #SELECTEDPAYMENTS SP ON UF.intSourceTransactionId = SP.intTransactionId
	  									   AND UF.strSourceTransactionId = SP.strTransactionNumber
			LEFT JOIN tblGLAccount GL ON SP.intAccountId = GL.intAccountId
			WHERE SP.intBankDepositId IS NOT NULL

			EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransaction
													 , @BankTransactionDetailEntries	= @BankTransactionDetail
													 , @intTransactionId				= @intNewBankTransactionId OUT

			IF ISNULL(@intNewBankTransactionId, 0) > 0
				BEGIN
					EXEC dbo.uspCMPostBankTransaction @ysnPost			= 1
													, @ysnRecap			= 0
													, @strTransactionId = @strTransactionId
													, @strBatchId		= NULL
													, @intUserId		= @intUserId
													, @intEntityId		= @intUserId
													, @isSuccessful		= @ysnSuccess OUT
				END
			ELSE
				BEGIN
					RAISERROR('Failed to Create Bank Transaction Entry', 11, 1)
					RETURN;
				END
		END TRY
		BEGIN CATCH
			SELECT @strErrorMsg = ERROR_MESSAGE()
			ROLLBACK TRANSACTION
			RAISERROR(@strErrorMsg, 11, 1)
			RETURN;
		END CATCH
	END

--CREATE NSF BANK TRANSACTION FOR BANK CHARGES
IF EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS WHERE ISNULL(dblNSFBankCharge, 0) > 0 AND ysnInvoiceToCustomer = 0)
	BEGIN
		SET @strTransactionId			= ''
		SET @intStartingNumberId		= NULL
		SET @intNewBankTransactionId	= NULL
		SET @ysnSuccess					= 0

		DELETE FROM @BankTransaction
		DELETE FROM @BankTransactionDetail

		BEGIN TRY
			SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
			FROM dbo.tblSMStartingNumber 
			WHERE strTransactionType = @STARTING_NUMBER_BANK_WITHDRAWAL

			EXEC uspSMGetStartingNumber @intStartingNumberId, @strTransactionId OUT

			INSERT INTO @BankTransaction (
				  [intBankAccountId]
				, [strTransactionId]
				, [intCurrencyId]
				, [intBankTransactionTypeId] 
				, [dtmDate]
				, [dblAmount]
				, [strMemo]			
				, [intCompanyLocationId]
				, [intEntityId]
				, [intCreatedUserId]
				, [intLastModifiedUserId])
			SELECT 
				 [intBankAccountId]				= UF.intBankAccountId
				,[strTransactionId]				= @strTransactionId
				,[intCurrencyId]				= SP.intCurrencyId
				,[intBankTransactionTypeId]		= 2
				,[dtmDate]						= SP.dtmDate
				,[dblAmount]					= SUM(SP.dblNSFBankCharge) * -1
				,[strMemo]						= 'Bank Charge Fee for' + SP.strRecordNumber
				,[intCompanyLocationId]			= UF.intLocationId
				,[intEntityId]					= @intUserId
				,[intCreatedUserId]				= @intUserId
				,[intLastModifiedUserId]		= @intUserId
			FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
			INNER JOIN #SELECTEDPAYMENTS SP ON UF.intSourceTransactionId = SP.intPaymentId
	  									   AND UF.strSourceTransactionId = SP.strRecordNumber
			WHERE ISNULL(SP.dblNSFBankCharge, 0) > 0 
			  AND SP.ysnInvoiceToCustomer = 0
			GROUP BY UF.intBankAccountId, SP.intCurrencyId, UF.intLocationId, SP.strRecordNumber, SP.dtmDate

			INSERT INTO @BankTransactionDetail(
				  [intTransactionId]
				, [intUndepositedFundId]
				, [dtmDate]
				, [intGLAccountId]
				, [strDescription]
				, [dblDebit]
				, [dblCredit]
				, [intEntityId]
			)
			SELECT 
				  [intTransactionId]	= 0
				, [intUndepositedFundId] = UF.intUndepositedFundId
				, [dtmDate]				= UF.dtmDate
				, [intGLAccountId]		= SP.intNSFAccountId
				, [strDescription]		= GL.strDescription
				, [dblDebit]			= ABS(ISNULL(SP.dblNSFBankCharge, 0))
				, [dblCredit]			= 0
				, [intEntityId]			= SP.intEntityCustomerId
			FROM dbo.tblCMUndepositedFund UF WITH (NOLOCK)
			INNER JOIN #SELECTEDPAYMENTS SP ON UF.intSourceTransactionId = SP.intPaymentId
	  									   AND UF.strSourceTransactionId = SP.strRecordNumber
			LEFT JOIN tblGLAccount GL ON SP.intAccountId = GL.intAccountId
			WHERE ISNULL(SP.dblNSFBankCharge, 0) > 0 
			  AND SP.ysnInvoiceToCustomer = 0

			EXEC dbo.uspCMCreateBankTransactionEntries @BankTransactionEntries			= @BankTransaction
													 , @BankTransactionDetailEntries	= @BankTransactionDetail
													 , @intTransactionId				= @intNewBankTransactionId OUT

			IF ISNULL(@intNewBankTransactionId, 0) > 0
				BEGIN
					EXEC dbo.uspCMPostBankTransaction @ysnPost			= 1
													, @ysnRecap			= 0
													, @strTransactionId = @strTransactionId
													, @strBatchId		= NULL
													, @intUserId		= @intUserId
													, @intEntityId		= @intUserId
													, @isSuccessful		= @ysnSuccess OUT
				END
			ELSE
				BEGIN
					RAISERROR('Failed to Create Bank Transaction Entry', 11, 1)
					RETURN;
				END
		END TRY
		BEGIN CATCH
			SELECT @strErrorMsg = ERROR_MESSAGE()
			ROLLBACK TRANSACTION
			RAISERROR(@strErrorMsg, 11, 1)
			RETURN;
		END CATCH
	END

--UPDATE CUSTOMER BALANCE
UPDATE CUSTOMER
SET dblARBalance = dblARBalance + ISNULL(PAYMENT.dblTotalPayment, 0)
FROM tblARCustomer CUSTOMER
INNER JOIN (
    SELECT intEntityCustomerId
         , dblTotalPayment = SUM(ISNULL(PD.dblTotalPayment, 0) + CASE WHEN P.ysnInvoicePrepayment = 0 THEN ISNULL(P.dblUnappliedAmount, 0)ELSE 0 END)
    FROM #SELECTEDPAYMENTS P
    LEFT JOIN (
        SELECT dblTotalPayment    = (SUM(PD.dblPayment) + SUM(PD.dblDiscount)) - SUM(PD.dblInterest)
             , intPaymentId
        FROM dbo.tblARPaymentDetail PD
        GROUP BY intPaymentId
    ) PD ON PD.intPaymentId = P.intTransactionId AND P.strTransactionType = 'Payment'
    GROUP BY intEntityCustomerId
) PAYMENT ON CUSTOMER.intEntityId = PAYMENT.intEntityCustomerId

IF ISNULL(@strCreatedIvoices, '') <> ''
	BEGIN
		SELECT @strInvoiceNumbers = LEFT(strInvoiceNumber, LEN(strInvoiceNumber) - 1)
		FROM (
			SELECT DISTINCT CAST(I.strInvoiceNumber AS VARCHAR(200))  + ', '			
			FROM tblARInvoice I
			INNER JOIN (
				SELECT intID 
				FROM fnGetRowsFromDelimitedValues(@strCreatedIvoices)
			) NEWINVOICE ON I.intInvoiceId = NEWINVOICE.intID
			FOR XML PATH ('')
		) INV (strInvoiceNumber)
	END

IF EXISTS (SELECT TOP 1 NULL FROM tblARNSFStagingTableDetail WHERE intNSFTransactionId = @intNSFTransactionId AND ysnInvoiceToCustomer = 1)
	BEGIN
		SET @strMessage = 'Invoice/s created for NSF Charge : ' + @strInvoiceNumbers
		SELECT TOP 1 @intPaymentId = intTransactionId 
		FROM tblARNSFStagingTableDetail 
		WHERE intNSFTransactionId = @intNSFTransactionId
	END
ELSE
	BEGIN
		SELECT @strMessage = 'Bank Deposit: ' + vyu.strTransactionId + ' and Receive Payment: ' +  vyu.strRecordNumber + ' are reversed'
		     , @intPaymentId = NSFDetail.intTransactionId
		FROM vyuARPaymentBankTransaction vyu
		INNER JOIN tblARNSFStagingTableDetail NSFDetail
			ON vyu.intPaymentId = NSFDetail.intTransactionId AND NSFDetail.strTransactionType = 'Payment'
		WHERE intNSFTransactionId = @intNSFTransactionId
	END

EXEC dbo.uspSMAuditLog 
		 @keyValue			= @intPaymentId
		,@screenName		= 'AccountsReceivable.view.ReceivePaymentsDetail'
		,@entityId			= @intUserId	
		,@actionType		= 'Processed NSF'
		,@changeDescription	= ''			
		,@fromValue			= ''			
		,@toValue			= ''
