CREATE PROCEDURE [dbo].[uspARCreateRCVForCreditMemo]
	@intUserId 		INT
AS

SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT OFF  

DECLARE @tblPaymentEntries	PaymentIntegrationStagingTable
DECLARE @intPaymentMethodId		INT = NULL
	  , @strPaymentMethod		NVARCHAR(100) = 'Cash'

IF(OBJECT_ID('tempdb..#CRCINVOICEPROCESS') IS NOT NULL) DROP TABLE #CRCINVOICEPROCESS
IF(OBJECT_ID('tempdb..#CRCPREPAIDS') IS NOT NULL) DROP TABLE #CRCPREPAIDS

CREATE TABLE #CRCPREPAIDS (
	  intPrepaymentId		INT	NOT NULL
	, intInvoiceId			INT NOT NULL
	, intEntityCustomerId	INT NOT NULL
	, intCompanyLocationId	INT NOT NULL
	, intCurrencyId			INT NOT NULL
	, intTermId				INT NULL
	, intAccountId			INT NULL
	, dblAmountDue			NUMERIC(18,6) DEFAULT 0
	, dblInvoiceTotal		NUMERIC(18,6) DEFAULT 0
	, dblBaseInvoiceTotal	NUMERIC(18,6) DEFAULT 0
	, dtmPostDate			DATETIME NULL
	, strInvoiceNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType	NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, dblAppliedAmount		NUMERIC(18,6) DEFAULT 0
)
CREATE TABLE #CRCINVOICEPROCESS (
	  intInvoiceId			INT PRIMARY KEY
	, intEntityCustomerId	INT NOT NULL
	, intCompanyLocationId	INT NOT NULL
	, intCurrencyId			INT NOT NULL
	, intTermId				INT NULL
	, intAccountId			INT NULL
	, dblAmountDue			NUMERIC(18,6) DEFAULT 0
	, dblInvoiceTotal		NUMERIC(18,6) DEFAULT 0
	, dblBaseInvoiceTotal	NUMERIC(18,6) DEFAULT 0
	, dtmPostDate			DATETIME NULL
	, strInvoiceNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType	NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
)

--GET PREPAID/CREDITS
INSERT INTO #CRCPREPAIDS (
	  intPrepaymentId
	, intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intCurrencyId
	, intTermId
	, intAccountId
	, dblAmountDue
	, dblInvoiceTotal
	, dblBaseInvoiceTotal
	, dtmPostDate
	, strInvoiceNumber
	, strTransactionType
	, dblAppliedAmount
)
SELECT intPrepaymentId		= PC.intPrepaymentId
	, intInvoiceId			= PC.intInvoiceId
	, intEntityCustomerId	= PCI.intEntityCustomerId
	, intCompanyLocationId	= PCI.intCompanyLocationId
	, intCurrencyId			= PCI.intCurrencyId
	, intTermId				= PCI.intTermId
	, intAccountId			= PCI.intAccountId
	, dblAmountDue			= PCI.dblAmountDue
	, dblInvoiceTotal		= PCI.dblInvoiceTotal
	, dblBaseInvoiceTotal	= PCI.dblBaseInvoiceTotal
	, dtmPostDate			= PCI.dtmPostDate
	, strInvoiceNumber		= PCI.strInvoiceNumber
	, strTransactionType	= PCI.strTransactionType
	, dblAppliedAmount		= PC.dblAppliedInvoiceDetailAmount
FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK)
INNER JOIN ##ARPostInvoiceHeader I ON PC.intInvoiceId = I.intInvoiceId
INNER JOIN tblARInvoice PCI ON PC.intPrepaymentId = PCI.intInvoiceId
WHERE PC.ysnApplied = 1
  AND PC.dblAppliedInvoiceDetailAmount > 0

IF NOT EXISTS(SELECT TOP 1 1 FROM #CRCPREPAIDS)
	RETURN 0;

--GET INVOICES TO PROCESS
INSERT INTO #CRCINVOICEPROCESS (
	  intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intCurrencyId
	, intTermId
	, intAccountId
	, dblAmountDue
	, dblInvoiceTotal
	, dblBaseInvoiceTotal
	, dtmPostDate
	, strInvoiceNumber
	, strTransactionType
)
SELECT intInvoiceId				= IH.intInvoiceId
	, intEntityCustomerId		= IH.intEntityCustomerId
	, intCompanyLocationId		= IH.intCompanyLocationId
	, intCurrencyId				= IH.intCurrencyId
	, intTermId					= IH.intTermId
	, intAccountId				= IH.intAccountId
	, dblAmountDue				= IH.dblAmountDue
	, dblInvoiceTotal			= IH.dblInvoiceTotal
	, dblBaseInvoiceTotal		= IH.dblBaseInvoiceTotal
	, dtmPostDate				= IH.dtmPostDate
	, strInvoiceNumber			= IH.strInvoiceNumber
	, strTransactionType		= IH.strTransactionType
FROM ##ARPostInvoiceHeader IH
INNER JOIN (
	SELECT DISTINCT intInvoiceId
	FROM #CRCPREPAIDS
) P ON P.intInvoiceId = IH.intInvoiceId
WHERE IH.dblAmountDue > 0  
  AND IH.strTransactionType <> 'Cash Refund'

--CREATE CASH PAYMENT METHOD IF MISSING
SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
		   , @strPaymentMethod		= strPaymentMethod
FROM tblSMPaymentMethod 
WHERE strPaymentMethod = @strPaymentMethod

IF @intPaymentMethodId IS NULL
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = @strPaymentMethod
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1

		SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
					, @strPaymentMethod		= strPaymentMethod
		FROM tblSMPaymentMethod 
		WHERE strPaymentMethod = @strPaymentMethod
	END

--INSERT INVOICE
INSERT INTO @tblPaymentEntries (
	  intId
	, strSourceTransaction
	, intSourceId
	, strSourceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intCurrencyId
	, dtmDatePaid
	, intPaymentMethodId
	, strPaymentMethod
	, strNotes
	, strPaymentInfo
	, intBankAccountId
	, dblAmountPaid
	, intEntityId
	, intInvoiceId
	, strTransactionType
	, strTransactionNumber
	, intTermId
	, intInvoiceAccountId
	, dblInvoiceTotal
	, dblBaseInvoiceTotal
	, dblPayment
	, dblAmountDue
	, strInvoiceReportNumber
	, ysnPost
)
SELECT intId						= I.intInvoiceId
	, strSourceTransaction			= 'Direct'
	, intSourceId					= I.intInvoiceId
	, strSourceId					= I.strInvoiceNumber
	, intEntityCustomerId			= I.intEntityCustomerId
	, intCompanyLocationId			= I.intCompanyLocationId
	, intCurrencyId					= I.intCurrencyId
	, dtmDatePaid					= I.dtmPostDate
	, intPaymentMethodId			= @intPaymentMethodId
	, strPaymentMethod				= @strPaymentMethod
	, strNotes						= 'Prepaids and Credit Memos'
	, strPaymentInfo				= NULL
	, intBankAccountId				= NULL
	, dblAmountPaid					= 0
	, intEntityId					= @intUserId
	, intInvoiceId					= I.intInvoiceId
	, strTransactionType			= I.strTransactionType
	, strTransactionNumber			= I.strInvoiceNumber
	, intTermId						= I.intTermId
	, intInvoiceAccountId			= I.intAccountId
	, dblInvoiceTotal				= I.dblInvoiceTotal
	, dblBaseInvoiceTotal			= I.dblBaseInvoiceTotal
	, dblPayment					= P.dblAppliedAmount
	, dblAmountDue					= I.dblAmountDue
	, strInvoiceReportNumber		= I.strInvoiceNumber
	, ysnPost						= 1
FROM #CRCINVOICEPROCESS I
INNER JOIN (
	SELECT intInvoiceId		= P.intInvoiceId
		 , dblAppliedAmount	= SUM(dblAppliedAmount)
	FROM #CRCPREPAIDS P
	GROUP BY P.intInvoiceId
) P ON I.intInvoiceId = P.intInvoiceId

UNION ALL

--INSERT CREDITS
SELECT intId						= P.intPrepaymentId
	, strSourceTransaction			= 'Direct'
	, intSourceId					= I.intInvoiceId
	, strSourceId					= I.strInvoiceNumber
	, intEntityCustomerId			= P.intEntityCustomerId
	, intCompanyLocationId			= P.intCompanyLocationId
	, intCurrencyId					= P.intCurrencyId
	, dtmDatePaid					= I.dtmPostDate
	, intPaymentMethodId			= @intPaymentMethodId
	, strPaymentMethod				= @strPaymentMethod
	, strNotes						= 'Prepaids and Credit Memos'
	, strPaymentInfo				= NULL
	, intBankAccountId				= NULL
	, dblAmountPaid					= 0
	, intEntityId					= @intUserId
	, intInvoiceId					= P.intPrepaymentId
	, strTransactionType			= P.strTransactionType
	, strTransactionNumber			= P.strInvoiceNumber
	, intTermId						= P.intTermId
	, intInvoiceAccountId			= P.intAccountId
	, dblInvoiceTotal				= -P.dblInvoiceTotal
	, dblBaseInvoiceTotal			= -P.dblBaseInvoiceTotal
	, dblPayment					= -P.dblAppliedAmount
	, dblAmountDue					= -P.dblAmountDue
	, strInvoiceReportNumber		= P.strInvoiceNumber
	, ysnPost						= 1
FROM #CRCPREPAIDS P
INNER JOIN #CRCINVOICEPROCESS I ON P.intInvoiceId = I.intInvoiceId

--CREATE AND POST PAYMENTS
EXEC dbo.uspARProcessPayments @PaymentEntries	= @tblPaymentEntries
							, @UserId			= @intUserId
							, @GroupingOption	= 10
							, @RaiseError		= 0

RETURN 0