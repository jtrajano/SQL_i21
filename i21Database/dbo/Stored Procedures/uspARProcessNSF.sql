﻿CREATE PROCEDURE [dbo].[uspARProcessNSF]
	@intNSFTransactionId	INT
AS

DECLARE @intNSFPaymentMethodId INT = NULL

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

CREATE TABLE #SELECTEDPAYMENTS (
	  intPaymentId			INT				NOT NULL
	, intNSFAccountId		INT				NULL
	, dtmDate				DATETIME		NOT NULL
	, dblNSFBankCharge		NUMERIC(18, 6)	NULL
	, ysnInvoiceToCustomer	BIT				NULL
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
	 , NSF.ysnInvoiceToCustomer
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
	FROM dbo.tblARPayment P WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentMethodID
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		WHERE strPaymentMethod IN ('Check', 'eCheck')
	) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	WHERE ysnPosted = 1
) P ON NSF.intPaymentId = P.intPaymentId

IF NOT EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS)
	BEGIN
		RAISERROR('There are no Payments to process to NSF.', 16, 1) 
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

--INVOICE TO CUSTOMER
IF EXISTS (SELECT TOP 1 NULL FROM #SELECTEDPAYMENTS WHERE ysnInvoiceToCustomer = 1)
	BEGIN
		DELETE FROM #SELECTEDPAYMENTS WHERE ysnInvoiceToCustomer = 0

		DECLARE @InvoiceEntries		InvoiceIntegrationStagingTable
			  , @UserId				INT
			  , @GroupingOption		INT = 0

		INSERT INTO @InvoiceEntries (
			  [strTransactionType]
			, [strType]
			, [strSourceTransaction]
			, [intSourceId]
			, [strSourceId]
			, [intEntityCustomerId]
			, [intCompanyLocationId]
			, [intAccountId]
			, [intCurrencyId]
			, [dtmDate]
			, [dtmDueDate]
			, [dtmShipDate]
			, [dtmPostDate]
			, [strComments]
			, [ysnPost]
			--detail
			
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
			 , P.intNSFAccountId
			 , P.intCurrencyId
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , P.dtmDate
			 , 'NFS Payment for: ' + P.strRecordNumber
			 , 1

			 --detail
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
		
	END

UPDATE tblARNSFStagingTableDetail 
SET ysnProcessed = 1 
WHERE intNSFTransactionId = @intNSFTransactionId