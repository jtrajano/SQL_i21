﻿CREATE PROCEDURE [dbo].[uspARProcessNSF]
	  @intNSFTransactionId	INT
	, @intUserId			INT
	, @strCreatedIvoices VARCHAR(500) = NULL OUTPUT
	, @strMessage	VARCHAR(500)	= NULL OUTPUT


AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intNSFPaymentMethodId INT = NULL
DECLARE @intPaymentId INT = NULL

SELECT TOP 1 @intNSFPaymentMethodId = intPaymentMethodID
FROM dbo.tblSMPaymentMethod 
WHERE strPaymentMethod = 'NSF'

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
	  intPaymentId			INT				NOT NULL
	, intNSFAccountId		INT				NULL
	, dtmDate				DATETIME		NOT NULL
	, dblNSFBankCharge		NUMERIC(18, 6)	NULL
	, dblUnappliedAmount	NUMERIC(18, 6)	NULL
	, ysnInvoiceToCustomer	BIT				NULL
	, ysnInvoicePrepayment	BIT				NULL
	, strRecordNumber		NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NOT NULL
	, intEntityCustomerId	INT				NOT NULL
	, intCurrencyId			INT				NOT NULL
	, intCompanyLocationId	INT				NOT NULL
)

INSERT INTO #SELECTEDPAYMENTS
SELECT NSF.intPaymentId
	 , NSF.intNSFAccountId
	 , NSF.dtmDate
	 , NSF.dblNSFBankCharge
	 , P.dblUnappliedAmount
	 , NSF.ysnInvoiceToCustomer
	 , P.ysnInvoicePrepayment
	 , P.strRecordNumber
	 , P.intEntityCustomerId
	 , P.intCurrencyId
	 , P.intLocationId	 
FROM dbo.tblARNSFStagingTableDetail NSF WITH (NOLOCK)
INNER JOIN (
	SELECT intPaymentId
		 , intEntityCustomerId
		 , intCurrencyId
		 , intLocationId
		 , strRecordNumber
		 , dblUnappliedAmount
		 , ysnInvoicePrepayment
	FROM dbo.tblARPayment P WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentMethodID
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		WHERE strPaymentMethod IN ('Check', 'eCheck', 'ACH')
	) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	WHERE ysnPosted = 1
	  AND ysnProcessedToNSF = 0
) P ON NSF.intPaymentId = P.intPaymentId
WHERE NSF.ysnProcessed = 0

SELECT intPaymentId		= NSF.intPaymentId
	 , intInvoiceId		= I.intInvoiceId
     , strRecordNumber	= NSF.strRecordNumber
	 , strInvoiceNumber	= I.strInvoiceNumber
     , ysnPaid			= I.ysnPaid
INTO #NSFWITHOVERPAYMENTS
FROM #SELECTEDPAYMENTS NSF
INNER JOIN tblARInvoice I ON NSF.intPaymentId = I.intPaymentId
WHERE I.strTransactionType = 'Overpayment'
  AND I.ysnPosted = 1

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
INSERT INTO tblGLDetail (
		intCompanyId
	  , dtmDate
	  , strBatchId
	  , intAccountId
	  , dblDebit
	  , dblCredit
	  , dblDebitUnit
	  , dblCreditUnit
	  , strDescription
	  , strCode
	  , strReference
	  , intCurrencyId
	  , dblExchangeRate
	  , dtmDateEntered
	  , dtmTransactionDate
	  , strJournalLineDescription
	  , intJournalLineNo
	  , ysnIsUnposted
	  , intUserId
	  , intEntityId
	  , strTransactionId
	  , intTransactionId
	  , strTransactionType
	  , strTransactionForm
	  , strModuleName
	  , intConcurrencyId
	  , dblDebitForeign
	  , dblDebitReport
	  , dblCreditForeign
	  , dblCreditReport
	  , dblReportingRate
	  , dblForeignRate
	  , intReconciledId
	  , dtmReconciled
	  , ysnReconciled
	  , ysnRevalued
)
SELECT intCompanyId					= GL.intCompanyId
	 , dtmDate						= GL.dtmDate
	 , strBatchId					= GL.strBatchId
	 , intAccountId					= GL.intAccountId
	 , dblDebit						= GL.dblCredit
	 , dblCredit					= GL.dblDebit
	 , dblDebitUnit					= GL.dblCreditUnit
	 , dblCreditUnit				= GL.dblDebitUnit
	 , strDescription				= 'NSF: ' + GL.strDescription
	 , strCode						= GL.strCode
	 , strReference					= GL.strReference
	 , intCurrencyId				= GL.intCurrencyId
	 , dblExchangeRate				= GL.dblExchangeRate
	 , dtmDateEntered				= P.dtmDate
	 , dtmTransactionDate			= GL.dtmTransactionDate
	 , strJournalLineDescription	= 'NSF'
	 , intJournalLineNo				= GL.intJournalLineNo
	 , ysnIsUnposted				= 0
	 , intUserId					= GL.intUserId
	 , intEntityId					= GL.intEntityId
	 , strTransactionId				= GL.strTransactionId
	 , intTransactionId				= GL.intTransactionId
	 , strTransactionType			= GL.strTransactionType
	 , strTransactionForm			= GL.strTransactionForm
	 , strModuleName				= GL.strModuleName
	 , intConcurrencyId				= 1
	 , dblDebitForeign				= GL.dblCreditForeign
	 , dblDebitReport				= GL.dblCreditReport
	 , dblCreditForeign				= GL.dblDebitForeign
	 , dblCreditReport				= GL.dblDebitReport
	 , dblReportingRate				= GL.dblReportingRate
	 , dblForeignRate				= GL.dblForeignRate
	 , intReconciledId				= GL.intReconciledId
	 , dtmReconciled				= GL.dtmReconciled
	 , ysnReconciled				= GL.ysnReconciled
	 , ysnRevalued					= GL.ysnRevalued
FROM dbo.tblGLDetail GL WITH (NOLOCK)
INNER JOIN #SELECTEDPAYMENTS P ON GL.intTransactionId = P.intPaymentId
							  AND GL.strTransactionId = P.strRecordNumber
WHERE GL.ysnIsUnposted = 0

--UPDATE PAYMENT RECORDS
UPDATE P
SET ysnProcessedToNSF	= 1
  , intPaymentMethodId	= @intNSFPaymentMethodId
  , strPaymentInfo		= 'NSF: ' + ISNULL(strPaymentInfo, '')  
  , strPaymentMethod	= 'NSF'
  , intCurrentStatus 	= 5
FROM tblARPayment P
INNER JOIN #SELECTEDPAYMENTS PAYMENTS ON P.intPaymentId = PAYMENTS.intPaymentId
WHERE ysnPosted = 1

UPDATE P
SET  intCurrentStatus 	= NULL
FROM tblARPayment P
INNER JOIN #SELECTEDPAYMENTS PAYMENTS ON P.intPaymentId = PAYMENTS.intPaymentId
WHERE ysnPosted = 1

--UPDATE INVOICES
UPDATE I
SET I.ysnPaid			= 0
  , I.dblPayment		= I.dblPayment - ABS(ISNULL(PAYMENTS.dblPayment, 0))
  , I.dblBasePayment	= I.dblBasePayment - ABS(ISNULL(PAYMENTS.dblBasePayment, 0))
  , I.dblAmountDue		= I.dblAmountDue + ABS(ISNULL(PAYMENTS.dblPayment, 0))
  , I.dblBaseAmountDue	= I.dblBaseAmountDue + ABS(ISNULL(PAYMENTS.dblBasePayment, 0))
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
	INNER JOIN #SELECTEDPAYMENTS P ON PD.intPaymentId = P.intPaymentId
) PAYMENTS ON I.intInvoiceId = PAYMENTS.intInvoiceId
WHERE I.ysnPosted = 1

--UPDATE OVERPAYMENTS
UPDATE I
SET ysnPosted 			= 0
  , ysnProcessedToNSF 	= 1
  , strComments 		= 'NSF Processed'
FROM tblARInvoice I
INNER JOIN #NSFWITHOVERPAYMENTS NSF ON I.intInvoiceId = NSF.intInvoiceId

--INVOICE TO CUSTOMER
IF EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS WHERE ysnInvoiceToCustomer = 1)
	BEGIN
		DELETE FROM #SELECTEDPAYMENTS WHERE ysnInvoiceToCustomer = 0

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
			 , P.intPaymentId
			 , P.strRecordNumber
			 , P.intEntityCustomerId
			 , P.intCompanyLocationId			 
			 , P.intCurrencyId
			 , @intUserId
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , 'NFS Payment for: ' + P.strRecordNumber
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
    ) PD ON PD.intPaymentId = P.intPaymentId
    GROUP BY intEntityCustomerId
) PAYMENT ON CUSTOMER.intEntityId = PAYMENT.intEntityCustomerId

SELECT @strMessage = 
 CASE WHEN ysnInvoiceToCustomer = 1 THEN
			'Invoice created for NSF Charge : ' + @strCreatedIvoices
 ELSE
	'Bank Deposit: '+ vyu.strTransactionId + ' and Receive Payment: '+  vyu.strRecordNumber+' are reversed'
 END,
 @intPaymentId = NSFDetail.intPaymentId
 FROM 
vyuARPaymentBankTransaction vyu
INNER JOIN tblARNSFStagingTableDetail NSFDetail
	ON vyu.intPaymentId = NSFDetail.intPaymentId
WHERE intNSFTransactionId = @intNSFTransactionId

EXEC dbo.uspSMAuditLog 
		 @keyValue			= @intPaymentId
		,@screenName		= 'AccountsReceivable.view.ReceivePaymentsDetail'
		,@entityId			= @intUserId	
		,@actionType		= 'Processed NSF'
		,@changeDescription	= ''			
		,@fromValue			= ''			
		,@toValue			= ''
