CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	  @dtmDateFrom					DATETIME = NULL
	, @dtmDateTo					DATETIME = NULL
	, @dtmBalanceForwardDate		DATETIME = NULL
	, @intEntityUserId				INT = NULL
	, @strSourceTransaction			NVARCHAR(100) = NULL
	, @strCustomerIds				NVARCHAR(MAX) = NULL
	, @strSalespersonIds			NVARCHAR(MAX) = NULL
	, @strCompanyLocationIds		NVARCHAR(MAX) = NULL
	, @strCompanyNameIds			NVARCHAR(MAX) = NULL
	, @strAccountStatusIds			NVARCHAR(MAX) = NULL
	, @strUserId					NVARCHAR(MAX) = NULL
	, @ysnIncludeCredits			BIT = 1
	, @ysnIncludeWriteOffPayment	BIT = 0
	, @ysnFromBalanceForward		BIT = 0
	, @ysnPrintFromCF				BIT = 0
	, @ysnExcludeAccountStatus		BIT = 0
	, @ysnOverrideCashFlow  		BIT = 0
	, @strReportLogId				NVARCHAR(MAX) = NULL
AS

DECLARE @dtmDateFromLocal				DATETIME		= NULL,
	    @dtmDateToLocal					DATETIME		= NULL,
		@intEntityUserIdLocal			INT				= NULL,
		@strSourceTransactionLocal		NVARCHAR(100)	= NULL,		
		@strCustomerIdsLocal			NVARCHAR(MAX)	= NULL,
		@strSalespersonIdsLocal			NVARCHAR(MAX)	= NULL,
		@strCompanyLocationIdsLocal		NVARCHAR(MAX)	= NULL,
		@strCompanyNameIdsLocal			NVARCHAR(MAX)	= NULL,
		@strAccountStatusIdsLocal		NVARCHAR(MAX)	= NULL,
		@strCompanyName					NVARCHAR(100)	= NULL,
		@strCompanyAddress				NVARCHAR(500)	= NULL,
		@ysnIncludeCreditsLocal			BIT				= 1,
		@ysnIncludeWriteOffPaymentLocal BIT				= 1,
		@ysnPrintFromCFLocal			BIT				= 0,
		@ysnOverrideCashFlowLocal  		BIT    			= 0,
		@strCustomerAgingBy			    NVARCHAR(250)	= NULL

--DROP TEMP TABLES
IF(OBJECT_ID('tempdb..#ARPOSTEDPAYMENT') IS NOT NULL) DROP TABLE #ARPOSTEDPAYMENT
IF(OBJECT_ID('tempdb..#INVOICETOTALPREPAYMENTS') IS NOT NULL) DROP TABLE #INVOICETOTALPREPAYMENTS
IF(OBJECT_ID('tempdb..#AGINGPOSTEDINVOICES') IS NOT NULL) DROP TABLE #AGINGPOSTEDINVOICES
IF(OBJECT_ID('tempdb..#CASHREFUNDS') IS NOT NULL) DROP TABLE #CASHREFUNDS
IF(OBJECT_ID('tempdb..#CASHRETURNS') IS NOT NULL) DROP TABLE #CASHRETURNS
IF(OBJECT_ID('tempdb..#FORGIVENSERVICECHARGE') IS NOT NULL) DROP TABLE #FORGIVENSERVICECHARGE
IF(OBJECT_ID('tempdb..#AGINGSTAGING') IS NOT NULL) DROP TABLE #AGINGSTAGING
IF(OBJECT_ID('tempdb..#AGINGGLACCOUNTS') IS NOT NULL) DROP TABLE #AGINGGLACCOUNTS
IF(OBJECT_ID('tempdb..#ADSALESPERSON') IS NOT NULL) DROP TABLE #ADSALESPERSON
IF(OBJECT_ID('tempdb..#ADLOCATION') IS NOT NULL) DROP TABLE #ADLOCATION
IF(OBJECT_ID('tempdb..#COMPANY') IS NOT NULL) DROP TABLE #COMPANY
IF(OBJECT_ID('tempdb..#ADACCOUNTSTATUS') IS NOT NULL) DROP TABLE #ADACCOUNTSTATUS
IF(OBJECT_ID('tempdb..#DELCUSTOMERS') IS NOT NULL) DROP TABLE #DELCUSTOMERS
IF(OBJECT_ID('tempdb..#DELLOCATION') IS NOT NULL) DROP TABLE #DELLOCATION
IF(OBJECT_ID('tempdb..#DECOMPANY') IS NOT NULL) DROP TABLE #DECOMPANY
IF(OBJECT_ID('tempdb..#DELACCOUNTSTATUS') IS NOT NULL) DROP TABLE #DELACCOUNTSTATUS
IF(OBJECT_ID('tempdb..#CREDITMEMOPAIDREFUNDED') IS NOT NULL) DROP TABLE #CREDITMEMOPAIDREFUNDED 

CREATE TABLE #DELCUSTOMERS (intEntityCustomerId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #DELLOCATION (intCompanyLocationId INT NOT NULL PRIMARY KEY)
CREATE TABLE #DECOMPANY (intAccountId INT NOT NULL PRIMARY KEY)
CREATE TABLE #DELACCOUNTSTATUS (intAccountStatusId INT NOT NULL PRIMARY KEY)
CREATE TABLE #ADSALESPERSON (intSalespersonId INT NOT NULL PRIMARY KEY)
CREATE TABLE #ADLOCATION (intCompanyLocationId INT NOT NULL PRIMARY KEY)
CREATE TABLE #COMPANY (intAccountId INT NOT NULL PRIMARY KEY)
CREATE TABLE #ADACCOUNTSTATUS (intAccountStatusId INT, intEntityCustomerId INT)
CREATE TABLE #AGINGPOSTEDINVOICES (
	   intInvoiceId					INT												NOT NULL PRIMARY KEY
	 , intEntityCustomerId			INT												NOT NULL
	 , intPaymentId					INT												NULL	 
	 , intCompanyLocationId			INT												NULL
	 , intEntitySalespersonId		INT												NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL
	 , strType						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' 
     , strBOLNumber					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	 , dblInvoiceTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblDiscount					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblInterest					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dtmPostDate					DATETIME										NULL
	 , dtmDueDate					DATETIME										NULL
	 , dtmDate						DATETIME										NULL
	 , dtmForgiveDate				DATETIME										NULL
	 , ysnForgiven					BIT												NULL
	 , ysnPaid						BIT												NULL
	 , dblBaseInvoiceTotal			NUMERIC(18, 6)									NULL DEFAULT 0
	 , intCurrencyId				INT												NULL
	 , strCurrency					NVARCHAR(40)									NULL
	 , dblCurrencyExchangeRate		NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblCurrencyRevalueRate		NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblCurrencyRevalueAmount		NUMERIC(18, 6)									NULL DEFAULT 0
	 , intAccountId					INT												NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#POSTEDINVOICES_intEntityCustomerId] ON [#AGINGPOSTEDINVOICES]([intEntityCustomerId])
CREATE NONCLUSTERED INDEX [NC_Index_#POSTEDINVOICES_strTransactionType] ON [#AGINGPOSTEDINVOICES]([strTransactionType])
CREATE NONCLUSTERED INDEX [NC_Index_#POSTEDINVOICES_dtmPostDate] ON [#AGINGPOSTEDINVOICES]([dtmPostDate])
CREATE TABLE #ARPOSTEDPAYMENT (
	   intPaymentId					INT												NOT NULL PRIMARY KEY
	 , dtmDatePaid					DATETIME										NULL
	 , dblAmountPaid				NUMERIC(18, 6)									NULL DEFAULT 0
	 , ysnInvoicePrepayment			BIT												NULL
	 , intPaymentMethodId			INT												NULL
     , strRecordNumber				NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#ARPOSTEDPAYMENT] ON [#ARPOSTEDPAYMENT]([ysnInvoicePrepayment])
CREATE TABLE #AGINGGLACCOUNTS (	
	  intAccountId					INT												NOT NULL PRIMARY KEY
	, strAccountCategory			NVARCHAR (100)   COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #INVOICETOTALPREPAYMENTS (
	  intInvoiceId					INT												NULL
	, dblPayment					NUMERIC(18, 6)									NULL DEFAULT 0
	, dblBasePayment				NUMERIC(18, 6)									NULL DEFAULT 0
)
CREATE TABLE #CASHREFUNDS (
	   intOriginalInvoiceId			INT												NULL
	 , strDocumentNumber			NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
	 , dblRefundTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblBaseRefundTotal			NUMERIC(18, 6)									NULL DEFAULT 0
)
CREATE TABLE #CASHRETURNS (
      intInvoiceId					INT												NOT NULL PRIMARY KEY
	, intOriginalInvoiceId			INT												NULL
	, dblInvoiceTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	, dblBaseInvoiceTotal			NUMERIC(18, 6)									NULL DEFAULT 0
	, strInvoiceOriginId			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, dtmPostDate					DATETIME										NULL
)
CREATE TABLE #FORGIVENSERVICECHARGE (
	   intInvoiceId					INT												NOT NULL PRIMARY KEY
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #CREDITMEMOPAIDREFUNDED (
	   intInvoiceId					INT												NOT NULL PRIMARY KEY
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	 , strDocumentNumber			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)

DECLARE @ADCUSTOMERS TABLE (
	    intEntityCustomerId			INT	NOT NULL PRIMARY KEY
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)

DECLARE @CANCELLEDINVOICE TABLE (
	 intInvoiceId		INT												NOT NULL PRIMARY KEY
	,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,ysnPaid			BIT												NULL
)
DECLARE @CANCELLEDCMINVOICE TABLE (
	 intInvoiceId		INT												NOT NULL PRIMARY KEY
	,strInvoiceNumber	NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)

SET @dtmDateFromLocal				= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET	@dtmDateToLocal					= ISNULL(@dtmDateTo, GETDATE())
SET @strSalespersonIdsLocal			= NULLIF(@strSalespersonIds, '')
SET @intEntityUserIdLocal			= NULLIF(@intEntityUserId, 0)
SET @strSourceTransactionLocal		= NULLIF(@strSourceTransaction, '')
SET @ysnIncludeCreditsLocal			= @ysnIncludeCredits
SET @ysnIncludeWriteOffPaymentLocal	= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @ysnPrintFromCFLocal			= ISNULL(@ysnPrintFromCF, 0)
SET @strCustomerIdsLocal			= NULLIF(@strCustomerIds, '')
SET @strSalespersonIdsLocal			= NULLIF(@strSalespersonIds, '')
SET @strCompanyLocationIdsLocal		= NULLIF(@strCompanyLocationIds, '')
SET @strCompanyNameIdsLocal			= NULLIF(@strCompanyNameIds, '')
SET @strAccountStatusIdsLocal		= NULLIF(@strAccountStatusIds, '')
SET @ysnOverrideCashFlowLocal  		= ISNULL(@ysnOverrideCashFlow, 0)
SET @dtmDateFromLocal				= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateFromLocal)))
SET @dtmDateToLocal					= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateToLocal)))
SET @strReportLogId					= NULLIF(@strReportLogId, CAST(NEWID() AS NVARCHAR(100)))

SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + CHAR(10) + ISNULL(NULLIF(strCity, ''), '') + ISNULL(', ' + NULLIF(strState, ''), '') + ISNULL(', ' + NULLIF(strZip, ''), '') + ISNULL(', ' + NULLIF(strCountry, ''), '')
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

SELECT TOP 1 @strCustomerAgingBy = strCustomerAgingBy
FROM tblARCompanyPreference WITH (NOLOCK)

--CUSTOMER FILTER
IF ISNULL(@strCustomerIdsLocal, '') <> ''
	BEGIN		
		INSERT INTO #DELCUSTOMERS
		SELECT DISTINCT intEntityCustomerId =  intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)		

		INSERT INTO @ADCUSTOMERS (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
		)
		SELECT intEntityCustomerId	= C.intEntityId 
		     , strCustomerNumber	= C.strCustomerNumber
		     , strCustomerName		= EC.strName
		     , dblCreditLimit		= C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #DELCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
	END
ELSE
	BEGIN
		INSERT INTO @ADCUSTOMERS (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
		)
		SELECT intEntityCustomerId	= C.intEntityId 
		     , strCustomerNumber	= C.strCustomerNumber
		     , strCustomerName		= EC.strName
		     , dblCreditLimit		= C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
	END

--COMPANY LOCATION FILTER
IF ISNULL(@strCompanyLocationIdsLocal, '') <> ''
	BEGIN
		INSERT INTO #DELLOCATION
		SELECT DISTINCT intCompanyLocationId =  intID		
		FROM dbo.fnGetRowsFromDelimitedValues(@strCompanyLocationIdsLocal)

		INSERT INTO #ADLOCATION
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
		INNER JOIN #DELLOCATION COMPANYLOCATION ON CL.intCompanyLocationId = COMPANYLOCATION.intCompanyLocationId
	END
ELSE
	BEGIN
		INSERT INTO #ADLOCATION
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
	END

--COMPANY FILTER
IF ISNULL(@strCompanyNameIdsLocal, '') <> ''
	BEGIN
		INSERT INTO #DECOMPANY
		SELECT DISTINCT intAccountId =  intID		
		FROM dbo.fnGetRowsFromDelimitedValues(@strCompanyNameIdsLocal)

		INSERT INTO #COMPANY
		SELECT GL.intAccountId
		FROM dbo.vyuARDistinctGLCompanyAccountIds GL WITH (NOLOCK) 
		INNER JOIN #DECOMPANY COMPANY ON GL.intAccountId = COMPANY.intAccountId
	END
ELSE
	BEGIN
		INSERT INTO #COMPANY
		SELECT GL.intAccountId
		FROM dbo.vyuARDistinctGLCompanyAccountIds GL WITH (NOLOCK) 
	END

--ACCOUNT STATUS FILTER
IF ISNULL(@strAccountStatusIdsLocal, '') <> ''
	BEGIN
		INSERT INTO #DELACCOUNTSTATUS
		SELECT DISTINCT intAccountStatusId =  intID		
		FROM dbo.fnGetRowsFromDelimitedValues(@strAccountStatusIdsLocal)

		INSERT INTO #ADACCOUNTSTATUS (
			  intAccountStatusId
			, intEntityCustomerId
		)
		SELECT intAccountStatusId	= ACCS.intAccountStatusId
			 , intEntityCustomerId	= CAS.intEntityCustomerId
		FROM dbo.tblARAccountStatus ACCS WITH (NOLOCK) 
		INNER JOIN tblARCustomerAccountStatus CAS ON ACCS.intAccountStatusId = CAS.intAccountStatusId
		INNER JOIN #DELACCOUNTSTATUS ACCOUNTSTATUS ON ACCS.intAccountStatusId = ACCOUNTSTATUS.intAccountStatusId

		IF ISNULL(@ysnExcludeAccountStatus, 0) = 0
			BEGIN
				DELETE CUSTOMERS 
				FROM @ADCUSTOMERS CUSTOMERS
				LEFT JOIN #ADACCOUNTSTATUS ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NULL
			END
		ELSE 
			BEGIN
				DELETE CUSTOMERS 
				FROM @ADCUSTOMERS CUSTOMERS
				INNER JOIN #ADACCOUNTSTATUS ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NOT NULL
			END
	END

IF 1=0 BEGIN
    SET FMTONLY OFF
END

--#ARPOSTEDPAYMENT
INSERT INTO #ARPOSTEDPAYMENT WITH (TABLOCK) (
	   intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , intPaymentMethodId
)
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , intPaymentMethodId
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN @ADCUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN (
	SELECT intTransactionId, dtmDate, strTransactionType
	FROM dbo.tblARNSFStagingTableDetail
	GROUP BY intTransactionId, dtmDate, strTransactionType
) NSF ON P.intPaymentId = NSF.intTransactionId AND NSF.strTransactionType = 'Payment'
WHERE P.ysnPosted = 1
  AND (P.ysnProcessedToNSF = 0 OR (P.ysnProcessedToNSF = 1 AND NSF.dtmDate > @dtmDateToLocal))
  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--#INVOICETOTALPREPAYMENTS
INSERT INTO #INVOICETOTALPREPAYMENTS (
	  intInvoiceId
	, dblPayment
)
SELECT intInvoiceId	= PD.intInvoiceId
	 , dblPayment	= SUM(PD.dblPayment) + SUM(PD.dblWriteOffAmount)
FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
WHERE PD.intInvoiceId IS NOT NULL
  AND I.strTransactionType = 'Customer Prepayment'
  AND I.ysnProcessedToNSF = 0
GROUP BY PD.intInvoiceId

--#AGINGGLACCOUNTS
INSERT INTO #AGINGGLACCOUNTS (
	   intAccountId
	 , strAccountCategory
)
SELECT intAccountId
	 , strAccountCategory
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'AP Account')
GROUP BY intAccountId,
		 strAccountCategory

--#FORGIVENSERVICECHARGE
INSERT INTO #FORGIVENSERVICECHARGE (
	   intInvoiceId
	 , strInvoiceNumber
)
SELECT SC.intInvoiceId
	 , SC.strInvoiceNumber
FROM tblARInvoice I
INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #ADLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
--INNER JOIN #COMPANY CO ON I.intAccountId = CO.intAccountId
INNER JOIN tblARInvoice SC ON I.strInvoiceOriginId = SC.strInvoiceNumber
WHERE I.strInvoiceOriginId IS NOT NULL 
  AND I.strTransactionType = 'Credit Memo' 
  AND I.strType = 'Standard'
  AND SC.strTransactionType = 'Invoice'
  AND SC.strType = 'Service Charge'
  AND SC.ysnForgiven = 1

--#CREDITMEMOPAIDREFUNDED
INSERT INTO #CREDITMEMOPAIDREFUNDED (
	   intInvoiceId
	 , strInvoiceNumber
	 , strDocumentNumber
)
SELECT 
	 I.intInvoiceId
	,I.strInvoiceNumber
	,REFUND.strDocumentNumber
FROM tblARInvoice I WITH (NOLOCK)
INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #ADLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
--INNER JOIN #COMPANY CO ON I.intAccountId = CO.intAccountId
INNER JOIN(
	SELECT ID.strDocumentNumber from tblARInvoice INV
	INNER JOIN tblARInvoiceDetail ID ON INV.intInvoiceId=ID.intInvoiceId
	WHERE   strTransactionType='Cash Refund' and ysnPosted = 1
) REFUND ON REFUND.strDocumentNumber = I.strInvoiceNumber
WHERE I.ysnPosted = 1 
AND I.ysnPaid = 1
AND I.ysnProcessedToNSF = 0
AND I.strTransactionType <> 'Cash Refund'
AND I.strTransactionType = 'Credit Memo'
AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

--#AGINGPOSTEDINVOICES
INSERT INTO #AGINGPOSTEDINVOICES WITH (TABLOCK) (
	   intInvoiceId
	 , intPaymentId
	 , intEntityCustomerId	 
	 , intEntitySalespersonId
	 , intCompanyLocationId
	 , dtmPostDate
	 , dtmDueDate
	 , dtmDate
	 , dtmForgiveDate
	 , strTransactionType
	 , strType
	 , strInvoiceNumber
	 , dblInvoiceTotal
	 , dblAmountDue
	 , dblDiscount
	 , dblInterest
	 , ysnForgiven
)
SELECT I.intInvoiceId
	 , I.intPaymentId
	 , I.intEntityCustomerId
	 , I.intEntitySalespersonId
	 , I.intCompanyLocationId
	 , I.dtmPostDate
	 , dtmDueDate = CASE WHEN I.ysnOverrideCashFlow = 1 AND @ysnOverrideCashFlowLocal = 1 THEN I.dtmCashFlowDate ELSE I.dtmDueDate END
	 , I.dtmDate
	 , I.dtmForgiveDate
	 , I.strTransactionType
	 , I.strType
	 , I.strInvoiceNumber
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dblInterest
	 , I.ysnForgiven
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #ADLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
--INNER JOIN #COMPANY CO ON I.intAccountId = CO.intAccountId
LEFT JOIN #FORGIVENSERVICECHARGE SC ON I.intInvoiceId = SC.intInvoiceId 
INNER JOIN #AGINGGLACCOUNTS GL ON GL.intAccountId = I.intAccountId AND (GL.strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND GL.strAccountCategory = 'AP Account'))
WHERE ysnPosted = 1
  AND ysnProcessedToNSF = 0	
  AND strTransactionType <> 'Cash Refund'
  AND ( 
		(SC.intInvoiceId IS NULL AND ((I.strType = 'Service Charge' AND (@ysnFromBalanceForward = 0 AND @dtmDateToLocal < I.dtmForgiveDate)) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0))))
		OR 
		SC.intInvoiceId IS NOT NULL
	)
	AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal		
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

INSERT INTO @CANCELLEDINVOICE (
	 intInvoiceId
	,strInvoiceNumber
	,ysnPaid
)
SELECT  INVCANCELLED.intInvoiceId,INVCANCELLED.strInvoiceNumber,INVCANCELLED.ysnPaid 
FROM tblARInvoice INVCANCELLED
WHERE ysnCancelled =1 
AND ysnPosted =1
AND INVCANCELLED.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	

INSERT INTO @CANCELLEDCMINVOICE (
	 intInvoiceId
	,strInvoiceNumber
)
SELECT CM.intInvoiceId,CM.strInvoiceNumber 
FROM tblARInvoice CM
WHERE CM.intOriginalInvoiceId IN (
	SELECT intInvoiceId 
	FROM @CANCELLEDINVOICE 
	WHERE ISNULL(ysnPaid, 0) = 0
)
AND CM.ysnPosted =1
AND CM.strTransactionType = 'Credit Memo'
AND CM.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

IF ISNULL(@strSalespersonIdsLocal, '') <> ''
BEGIN
	INSERT INTO #ADSALESPERSON
	SELECT SP.intEntityId
	FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
	INNER JOIN (
		SELECT intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strSalespersonIdsLocal)
	) SALESPERSON ON SP.intEntityId = SALESPERSON.intID

	DELETE INVOICES
	FROM #AGINGPOSTEDINVOICES INVOICES
	LEFT JOIN #ADSALESPERSON SALESPERSON ON INVOICES.intEntitySalespersonId = SALESPERSON.intSalespersonId
	WHERE SALESPERSON.intSalespersonId IS NULL 
END

IF (@ysnPrintFromCFLocal = 1)
BEGIN
	DELETE I 
	FROM #AGINGPOSTEDINVOICES I
	LEFT JOIN tblCFInvoiceStagingTable IST ON I.intInvoiceId = IST.intInvoiceId
											AND IST.strUserId = @strUserId
											AND LOWER(IST.strStatementType) = 'invoice'
	WHERE I.strType = 'CF Tran'
		AND I.intInvoiceId IS NULL

	DELETE I 
	FROM #AGINGPOSTEDINVOICES I
	INNER JOIN tblCFTransaction CF ON I.strInvoiceNumber = CF.strTransactionId
	WHERE I.strType = 'CF Tran'
		AND CF.ysnInvoiced = 1
		AND I.dtmPostDate <= @dtmDateToLocal

	IF (@ysnFromBalanceForward = 0 AND @dtmBalanceForwardDate IS NOT NULL)
	BEGIN
 		DELETE FROM #AGINGPOSTEDINVOICES WHERE strType = 'Service Charge' AND ysnForgiven = 1 AND dtmForgiveDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	END
END

--#CASHREFUNDS
INSERT INTO #CASHREFUNDS (
	   intOriginalInvoiceId
	 , strDocumentNumber
	 , dblRefundTotal
)
SELECT intOriginalInvoiceId	= I.intOriginalInvoiceId
	, strDocumentNumber		= ID.strDocumentNumber
	, dblRefundTotal		= SUM(ID.dblTotal)
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN @ADCUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #ADLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
--INNER JOIN #COMPANY CO ON I.intAccountId = CO.intAccountId
WHERE I.strTransactionType = 'Cash Refund'
  AND I.ysnPosted = 1
  AND (I.intOriginalInvoiceId IS NOT NULL OR (ID.strDocumentNumber IS NOT NULL AND ID.strDocumentNumber <> ''))
  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal  
GROUP BY I.intOriginalInvoiceId, ID.strDocumentNumber

DELETE FROM #AGINGPOSTEDINVOICES
WHERE strInvoiceNumber IN (SELECT CF.strDocumentNumber FROM #CASHREFUNDS CF INNER  JOIN #CREDITMEMOPAIDREFUNDED CMPF ON CF.strDocumentNumber = CMPF.strDocumentNumber)

DELETE FROM #AGINGPOSTEDINVOICES
WHERE intInvoiceId IN (SELECT intInvoiceId FROM @CANCELLEDINVOICE)

DELETE FROM #AGINGPOSTEDINVOICES
WHERE intInvoiceId IN (SELECT intInvoiceId FROM @CANCELLEDCMINVOICE)

--#CASHRETURNS
INSERT INTO #CASHRETURNS (
      intInvoiceId
	, intOriginalInvoiceId
	, dblInvoiceTotal
	, strInvoiceOriginId
)
SELECT I.intInvoiceId
	 , I.intOriginalInvoiceId
	 , I.dblInvoiceTotal
	 , I.strInvoiceOriginId
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN tblARInvoice RI ON I.intOriginalInvoiceId = RI.intInvoiceId AND I.strInvoiceOriginId = RI.strInvoiceNumber
WHERE I.ysnPosted = 1
  AND I.ysnRefundProcessed = 1
  AND I.strTransactionType = 'Credit Memo'
  AND I.intOriginalInvoiceId IS NOT NULL
  AND (I.strInvoiceOriginId IS NOT NULL AND I.strInvoiceOriginId <> '')
  AND (RI.ysnReturned IS NULL OR RI.ysnReturned = 0)
  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	
DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary'
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
	 , intEntityUserId
	 , dblCreditLimit
	 , dblTotalAR
	 , dblTotalCustomerAR
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblTotalDue
	 , dblAmountPaid
	 , dblCredits
	 , dblPrepayments
	 , dblPrepaids
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
	 , strAgingType
	 , strReportLogId
)	
SELECT strCustomerName		= CUSTOMER.strCustomerName
     , strEntityNo			= CUSTOMER.strCustomerNumber
	 , strCustomerInfo		= CUSTOMER.strCustomerName + ' ' + CUSTOMER.strCustomerNumber
	 , intEntityCustomerId	= AGING.intEntityCustomerId
	 , intEntityUserId		= @intEntityUserIdLocal
	 , dblCreditLimit		= ISNULL(CUSTOMER.dblCreditLimit, 0)
	 , dblTotalAR			= ISNULL(AGING.dblTotalAR, 0)
	 , dblTotalCustomerAR	= ISNULL(AGING.dblTotalAR, 0)
	 , dblFuture			= ISNULL(AGING.dblFuture, 0)
	 , dbl0Days				= ISNULL(AGING.dbl0Days, 0)
	 , dbl10Days            = ISNULL(AGING.dbl10Days, 0)
	 , dbl30Days            = ISNULL(AGING.dbl30Days, 0)
	 , dbl60Days            = ISNULL(AGING.dbl60Days, 0)
	 , dbl90Days            = ISNULL(AGING.dbl90Days, 0)
	 , dbl91Days            = ISNULL(AGING.dbl91Days, 0)
	 , dblTotalDue          = ISNULL(AGING.dblTotalDue, 0)
	 , dblAmountPaid        = ISNULL(AGING.dblAmountPaid, 0)
	 , dblCredits           = ISNULL(AGING.dblCredits, 0)
	 , dblPrepayments		= ISNULL(AGING.dblPrepayments, 0)
	 , dblPrepaids          = ISNULL(AGING.dblPrepayments, 0)
	 , dtmAsOfDate          = @dtmDateToLocal
	 , strSalespersonName   = 'strSalespersonName'
	 , strSourceTransaction	= @strSourceTransactionLocal
	 , strCompanyName		= @strCompanyName
	 , strCompanyAddress	= @strCompanyAddress
	 , strAgingType			= 'Summary'
	 , strReportLogId		= @strReportLogId
FROM (
SELECT intEntityCustomerId	= B.intEntityCustomerId
     , dblTotalAR           = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
     , dblFuture            = SUM(B.dblFuture)
	 , dbl0Days				= SUM(B.dbl0Days)
     , dbl10Days            = SUM(B.dbl10Days)
     , dbl30Days            = SUM(B.dbl30Days)
     , dbl60Days            = SUM(B.dbl60Days)
     , dbl90Days            = SUM(B.dbl90Days)
     , dbl91Days            = SUM(B.dbl91Days)
     , dblTotalDue          = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
     , dblAmountPaid        = SUM(B.dblAmountPaid)
     , dblCredits           = SUM(B.dblAvailableCredit) * -1
	 , dblPrepayments		= SUM(B.dblPrepayments) * -1     
FROM (
	SELECT intEntityCustomerId		= TBL.intEntityCustomerId
		, intInvoiceId				= TBL.intInvoiceId
		, dblAmountPaid				= TBL.dblAmountPaid
		, dblTotalDue				= CASE WHEN strType = 'CF Tran' AND @ysnPrintFromCFLocal = 0 AND @dtmBalanceForwardDate IS NOT NULL THEN 0 ELSE dblInvoiceTotal - dblAmountPaid END
		, dblAvailableCredit		= TBL.dblAvailableCredit
		, dblPrepayments			= TBL.dblPrepayments
		, dblFuture					= CASE WHEN strType = 'CF Tran' 
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END
		, dbl0Days					= CASE WHEN DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 0 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END
		, dbl10Days					= CASE WHEN DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 0 AND DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) <= 10 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
										   END
		, dbl30Days					= CASE WHEN DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) <= 30 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END 
		, dbl60Days					= CASE WHEN DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) <= 60 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END 
		, dbl90Days					= CASE WHEN DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, (CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END), @dtmDateToLocal) <= 90 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END 
		, dbl91Days					= CASE WHEN DATEDIFF(DAYOFYEAR, ( CASE WHEN @strCustomerAgingBy = 'Invoice Create Date' THEN TBL.dtmDate ELSE TBL.dtmDueDate END ), @dtmDateToLocal) > 90 AND strType <> 'CF Tran'
										   THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 
									  END
	FROM (
		--INVOICES
		SELECT I.intInvoiceId
			  , dblAmountPaid		= 0
			  , dblInvoiceTotal		= ISNULL(dblInvoiceTotal, 0)
			  , dblAmountDue		= 0    
			  , I.dtmDueDate    
			  , I.dtmDate  
			  , I.intEntityCustomerId
			  , dblAvailableCredit	= 0
			  , dblPrepayments		= 0
			  , I.strType
		FROM #AGINGPOSTEDINVOICES I WITH (NOLOCK)
		WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')

		UNION ALL

		--CREDIT MEMOS/OVERPAYMENTS
		SELECT I.intInvoiceId
			 , dblAmountPaid		= 0
			 , dblInvoiceTotal		= CASE WHEN I.strType = 'CF Tran' THEN (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1 ELSE 0 END
			 , dblAmountDue			= 0    
			 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
			 , dtmDate				= ISNULL(P.dtmDatePaid, I.dtmDate)
			 , I.intEntityCustomerId
			 , dblAvailableCredit	= CASE WHEN I.strType = 'CF Tran' THEN 0 ELSE ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) + ISNULL(APD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0) END
			 , dblPrepayments		= 0
			 , I.strType
		FROM #AGINGPOSTEDINVOICES I WITH (NOLOCK)
		LEFT JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
		LEFT JOIN (
			SELECT dblPayment = SUM(dblPayment) + SUM(dblWriteOffAmount)
				 , PD.intInvoiceId
			FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
			INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
			GROUP BY PD.intInvoiceId
		) PD ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN (
			SELECT dblPayment = SUM(dblPayment) * -1
				 , APD.intInvoiceId
			FROM dbo.tblAPPaymentDetail APD WITH (NOLOCK)
			INNER JOIN tblAPPayment P ON APD.intPaymentId = P.intPaymentId
			WHERE P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY APD.intInvoiceId
		) APD ON I.intInvoiceId = APD.intInvoiceId
		LEFT JOIN #CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
		WHERE ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')) OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))

		UNION ALL

		--PREPAYMENTS
		SELECT I.intInvoiceId
			 , dblAmountPaid		= 0
			 , dblInvoiceTotal		= 0
			 , dblAmountDue			= 0    
			 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
			 , dtmDate				= ISNULL(P.dtmDatePaid, I.dtmDate)
			 , I.intEntityCustomerId
			 , dblAvailableCredit	= 0
			 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
			 , I.strType
		FROM #AGINGPOSTEDINVOICES I WITH (NOLOCK)
		INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
		LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN #CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
		WHERE ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
	                                          
		UNION ALL
        
		--AR/AP PAYMENTS AND CASH REFUND
		SELECT I.intInvoiceId
			, dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
			, dblInvoiceTotal		= 0
			, dblAmountDue			= 0
			, dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
			, dtmDate				= ISNULL(I.dtmDate, GETDATE())
			, I.intEntityCustomerId
			, dblAvailableCredit	= 0
			, dblPrepayments		= 0
			, I.strType
		FROM #AGINGPOSTEDINVOICES I WITH (NOLOCK)
		INNER JOIN (
			SELECT PD.intInvoiceId
				 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) + SUM(ISNULL(dblWriteOffAmount, 0)) - SUM(ISNULL(dblInterest, 0)) - SUM(ISNULL(dblCreditCardFee, 0))
			FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
			INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
			GROUP BY PD.intInvoiceId

			UNION ALL 

			SELECT PD.intInvoiceId
				 , dblTotalPayment		= ABS((SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))))
			FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
			INNER JOIN (
				SELECT intPaymentId
				FROM dbo.tblAPPayment WITH (NOLOCK)
				WHERE ysnPosted = 1
				  AND dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			) P ON PD.intPaymentId = P.intPaymentId
			WHERE PD.intInvoiceId IS NOT NULL
			GROUP BY PD.intInvoiceId

			UNION ALL

			SELECT intInvoiceId			= intOriginalInvoiceId
				 , dblTotalPayment		= dblInvoiceTotal
			FROM #CASHRETURNS
		) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
		WHERE ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')) OR (@ysnIncludeCreditsLocal = 1))
	) AS TBL
) AS B
GROUP BY B.intEntityCustomerId) AS AGING
INNER JOIN @ADCUSTOMERS CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId