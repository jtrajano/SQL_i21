CREATE PROCEDURE [dbo].[uspARCustomerStatementBalanceForwardReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @dtmBalanceForwardDate		AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnActiveCustomers			AS BIT				= 0
	, @ysnPrintFromCF				AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @strUserId					AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @ysnReprintInvoice			AS BIT				= 1
	, @intEntityUserId				AS INT				= NULL
	, @dblTotalAR				    AS NUMERIC(18,6)    = 0.00
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF(OBJECT_ID('tempdb..#AGINGTABLE') IS NOT NULL) DROP TABLE #AGINGTABLE
IF(OBJECT_ID('tempdb..#BALANCEFORWARDTABLE') IS NOT NULL) DROP TABLE #BALANCEFORWARDTABLE
IF(OBJECT_ID('tempdb..#STATEMENTTABLE') IS NOT NULL) DROP TABLE #STATEMENTTABLE
IF(OBJECT_ID('tempdb..#CFTABLE') IS NOT NULL) DROP TABLE #CFTABLE
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL) DROP TABLE #GLACCOUNTS
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL) DROP TABLE #PAYMENTS
IF(OBJECT_ID('tempdb..#PAYMENTSFORCF') IS NOT NULL) DROP TABLE #PAYMENTSFORCF
IF(OBJECT_ID('tempdb..#DELCUSTOMERS') IS NOT NULL) DROP TABLE #DELCUSTOMERS

--LOCAL VARIABLES
DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @dtmBalanceForwardDateLocal			AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 0
	  , @ysnPrintFromCFLocal				AS BIT				= 0
	  , @ysnReprintInvoiceLocal				AS BIT				= 1
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @ysnStretchLogo						AS BIT				= 0
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL

SET @dtmDateToLocal						= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal					= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @dtmBalanceForwardDateLocal			= ISNULL(@dtmBalanceForwardDate, @dtmDateFromLocal)
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @ysnPrintFromCFLocal				= ISNULL(@ysnPrintFromCF, 0)
SET @ysnReprintInvoiceLocal				= ISNULL(@ysnReprintInvoice, 1)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @dtmDateFromLocal					= DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

--TEMP TABLES
CREATE TABLE #AGINGTABLE (
	  intEntityCustomerId		INT	NOT NULL PRIMARY KEY
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , strEntityNo				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerInfo			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalAR				NUMERIC(18,6) NULL DEFAULT 0
    , dblFuture					NUMERIC(18,6) NULL DEFAULT 0
    , dbl0Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl10Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl30Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl60Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl90Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl91Days					NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalDue				NUMERIC(18,6) NULL DEFAULT 0
    , dblAmountPaid				NUMERIC(18,6) NULL DEFAULT 0
    , dblCredits				NUMERIC(18,6) NULL DEFAULT 0
	, dblPrepayments			NUMERIC(18,6) NULL DEFAULT 0
    , dblPrepaids				NUMERIC(18,6) NULL DEFAULT 0
	, dblTempFuture				NUMERIC(18,6) NULL DEFAULT 0
	, dblUnInvoiced				NUMERIC(18,6) NULL DEFAULT 0
    , dtmAsOfDate				DATETIME NULL
    , strSalespersonName		NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSourceTransaction		NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
CREATE TABLE #BALANCEFORWARDTABLE (
	  intEntityCustomerId		INT	NOT NULL PRIMARY KEY
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , strEntityNo				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCustomerInfo			NVARCHAR(200) COLLATE Latin1_General_CI_AS
    , dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalAR				NUMERIC(18,6) NULL DEFAULT 0
    , dblFuture					NUMERIC(18,6) NULL DEFAULT 0
    , dbl0Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl10Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl30Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl60Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl90Days					NUMERIC(18,6) NULL DEFAULT 0
    , dbl91Days					NUMERIC(18,6) NULL DEFAULT 0
    , dblTotalDue				NUMERIC(18,6) NULL DEFAULT 0
    , dblAmountPaid				NUMERIC(18,6) NULL DEFAULT 0
    , dblCredits				NUMERIC(18,6) NULL DEFAULT 0
	, dblPrepayments			NUMERIC(18,6) NULL DEFAULT 0
    , dblPrepaids				NUMERIC(18,6) NULL DEFAULT 0
	, dblTempFuture				NUMERIC(18,6) NULL DEFAULT 0
	, dblUnInvoiced				NUMERIC(18,6) NULL DEFAULT 0
    , dtmAsOfDate				DATETIME NULL
    , strSalespersonName		NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSourceTransaction		NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
CREATE TABLE #STATEMENTTABLE (
	  intEntityCustomerId		INT	NOT NULL
	, intInvoiceId				INT NULL
	, intPaymentId				INT NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
    , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL    
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strRecordNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strType					NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strPaymentInfo			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strSalespersonName		NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, strTicketNumbers			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL	
	, strLocationName			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
    , strFullAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strComment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFooterComment	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, dtmDate					DATETIME NULL
	, dtmDueDate				DATETIME NULL
	, dtmShipDate				DATETIME NULL
	, dtmDatePaid				DATETIME NULL
	, dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0	
    , dblInvoiceTotal			NUMERIC(18,6) NULL DEFAULT 0
	, dblPayment				NUMERIC(18,6) NULL DEFAULT 0
	, dblBalance				NUMERIC(18,6) NULL DEFAULT 0
	, dblARBalance				NUMERIC(18,6) NULL DEFAULT 0
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTTABLE_A1] ON [#STATEMENTTABLE]([intEntityCustomerId], [intInvoiceId], [strTransactionType], [strType])
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTTABLE_A2] ON [#STATEMENTTABLE]([strTransactionType]) INCLUDE ([dblPayment])
CREATE TABLE #CFTABLE (
	  intInvoiceId				INT NOT NULL PRIMARY KEY
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strInvoiceReportNumber	NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, dtmInvoiceDate			DATETIME NULL
)
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL PRIMARY KEY	  
    , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFormat        NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strFullAddress			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strSalesPersonName		NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0	
	, dblARBalance				NUMERIC(18,6) NULL DEFAULT 0
	, ysnStatementCreditLimit	BIT NULL
)
CREATE TABLE #GLACCOUNTS (intAccountId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #INVOICES (
	  intInvoiceId				INT NOT NULL PRIMARY KEY
	, intEntityCustomerId		INT NOT NULL      
	, intPaymentId				INT NULL     
	, intCompanyLocationId		INT NOT NULL 
	, intTermId					INT NOT NULL 
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strRecordNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strInvoiceOriginId		NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strPaymentInfo			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL   
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS   NOT	NULL
	, dblInvoiceTotal			NUMERIC(18, 6)	NULL DEFAULT 0
	, dblBalance				NUMERIC(18, 6)	NULL DEFAULT 0
	, dblPayment				NUMERIC(18, 6)	NULL DEFAULT 0
	, dtmDate					DATETIME NULL  
	, dtmDueDate				DATETIME NULL     
	, dtmShipDate				DATETIME NULL      
	, dtmDatePaid				DATETIME NULL
	, dtmPostDate				DATETIME NULL
	, strType					NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' 
	, strComment				NVARCHAR(500) COLLATE Latin1_General_CI_AS  NULL
	, strTicketNumbers			NVARCHAR(500) COLLATE Latin1_General_CI_AS  NULL
	, ysnServiceChargeCredit	BIT NULL 
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTINVOICE_A1] ON [#INVOICES]([intEntityCustomerId]) INCLUDE ([strTransactionType])
CREATE TABLE #PAYMENTS (
	  intPaymentId				INT NOT NULL PRIMARY KEY
	, intEntityCustomerId		INT NOT NULL
	, intCompanyLocationId		INT NOT NULL
	, intPaymentMethodId		INT NULL
	, strRecordNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strPaymentInfo			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strNotes					NVARCHAR(250) COLLATE Latin1_General_CI_AS	NULL
	, dblAmountPaid				NUMERIC(18, 6)	NULL DEFAULT 0
	, dtmDatePaid				DATETIME NOT NULL
	, ysnInvoicePrepayment		BIT NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTPAYMENT_A1] ON [#PAYMENTS]([intEntityCustomerId])
CREATE TABLE #PAYMENTSFORCF (
	  intPaymentId				INT NOT NULL
	, intEntityCustomerId		INT NOT NULL
	, intCompanyLocationId		INT NOT NULL
	, strRecordNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strPaymentInfo			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS   NOT	NULL
	, strComment				NVARCHAR(500) COLLATE Latin1_General_CI_AS  NULL
	, dblInvoiceTotal			NUMERIC(18, 6)	NULL DEFAULT 0   
	, dblBalance				NUMERIC(18, 6)	NULL DEFAULT 0   
	, dblPayment				NUMERIC(18, 6)	NULL DEFAULT 0   
	, dtmDate					DATETIME NULL   
	, dtmDatePaid				DATETIME NULL	
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTPAYMENTFORCF_A1] ON [#PAYMENTSFORCF]([intPaymentId],[intEntityCustomerId])
CREATE TABLE #DELCUSTOMERS (intEntityCustomerId	INT NOT NULL PRIMARY KEY)

SELECT TOP 1 @ysnStretchLogo	= ysnStretchLogo
FROM tblARCompanyPreference WITH (NOLOCK)

--COMPANY INFO
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--FILTER CUSTOMERS
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId		= C.intEntityId 
			       , strCustomerNumber			= C.strCustomerNumber
				   , strCustomerName			= EC.strName
				   , strStatementFormat			= C.strStatementFormat
				   , dblCreditLimit				= C.dblCreditLimit
				   , dblARBalance				= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Balance Forward'
		  AND strEntityNo = @strCustomerNumberLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #DELCUSTOMERS
		SELECT DISTINCT intEntityCustomerId =  intID
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)

		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit        
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #DELCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Balance Forward'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName			= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit			= C.dblCreditLimit
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Balance Forward'
		  AND (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
	END

IF @strAccountStatusCodeLocal IS NOT NULL
    BEGIN
        DELETE FROM #CUSTOMERS
        WHERE intEntityCustomerId NOT IN (
            SELECT DISTINCT intEntityCustomerId
            FROM dbo.tblARCustomerAccountStatus CAS WITH (NOLOCK)
            INNER JOIN tblARAccountStatus AAS WITH (NOLOCK) ON CAS.intAccountStatusId = AAS.intAccountStatusId
            WHERE AAS.strAccountStatusCode = @strAccountStatusCodeLocal
        )
    END

IF @ysnEmailOnly IS NOT NULL
	BEGIN
		DELETE C
		FROM #CUSTOMERS C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM tblARCustomer CC
			INNER JOIN tblEMEntityToContact CONT ON CC.intEntityId = CONT.intEntityId 
			INNER JOIN tblEMEntity E ON CONT.intEntityContactId = E.intEntityId 
			WHERE E.strEmail <> '' 
			  AND E.strEmail IS NOT NULL
			  AND E.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN EMAILSETUP.intEmailSetupCount > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

--CUSTOMER_SALESPERSON
UPDATE C
SET strSalesPersonName = E.strName
FROM #CUSTOMERS C
INNER JOIN tblARCustomer CUS ON C.intEntityCustomerId = CUS.intEntityId
INNER JOIN tblEMEntity E ON CUS.intSalespersonId = E.intEntityId
WHERE CUS.intSalespersonId IS NOT NULL

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress	= EL.strAddress + CHAR(13) + char(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1

--CUSTOMER_FOOTERCOMMENT
UPDATE C
SET strStatementFooterComment	= FOOTER.strMessage
FROM #CUSTOMERS C
CROSS APPLY (
	SELECT TOP 1 strMessage	= '<html>' + CAST(blbMessage AS VARCHAR(MAX)) + '</html>'
	FROM tblSMDocumentMaintenanceMessage H
	INNER JOIN tblSMDocumentMaintenance M ON H.intDocumentMaintenanceId = M.intDocumentMaintenanceId
	WHERE H.strHeaderFooter = 'Footer'
	  AND M.strSource = 'Statement Report'
	  AND (M.intEntityCustomerId IS NULL OR (M.intEntityCustomerId IS NOT NULL AND M.intEntityCustomerId = C.intEntityCustomerId))
	ORDER BY M.[intDocumentMaintenanceId] DESC
		   , intEntityCustomerId DESC
) FOOTER

SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

--#GLACCOUNTS
INSERT INTO #GLACCOUNTS (intAccountId)
SELECT intAccountId
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--#PAYMENTS
INSERT INTO #PAYMENTS (
	   intPaymentId
	 , intEntityCustomerId
	 , intCompanyLocationId
	 , intPaymentMethodId
	 , strPaymentInfo
	 , strNotes
	 , strRecordNumber
	 , dblAmountPaid
	 , dtmDatePaid
	 , ysnInvoicePrepayment
)
SELECT intPaymentId			= P.intPaymentId
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , intCompanyLocationId	= P.intLocationId
	 , intPaymentMethodId	= P.intPaymentMethodId
	 , strPaymentInfo		= P.strPaymentInfo
	 , strNotes				= P.strNotes
	 , strRecordNumber		= P.strRecordNumber
	 , dblAmountPaid		= P.dblAmountPaid
	 , dtmDatePaid			= P.dtmDatePaid
	 , ysnInvoicePrepayment	= P.ysnInvoicePrepayment
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
WHERE P.ysnPosted = 1       
  AND P.ysnProcessedToNSF = 0       
  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--FILTER WRITE OFF
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		SELECT TOP 1 @intWriteOffPaymentMethodId = intPaymentMethodID 
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
		WHERE UPPER(strPaymentMethod) = 'WRITE OFF'

		DELETE FROM #PAYMENTS WHERE intPaymentMethodId = @intWriteOffPaymentMethodId
	END

--#INVOICES
INSERT INTO #INVOICES (
	  intInvoiceId
	, intEntityCustomerId
	, intPaymentId
	, intCompanyLocationId
	, intTermId
	, strInvoiceNumber
	, strInvoiceOriginId
	, strBOLNumber
	, strTransactionType
	, dblInvoiceTotal
	, dblBalance
	, dblPayment
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dtmPostDate
	, strType
	, strComment
	, ysnServiceChargeCredit
)
SELECT intInvoiceId			= I.intInvoiceId      
	, intEntityCustomerId	= I.intEntityCustomerId      
	, intPaymentId			= I.intPaymentId     
	, intCompanyLocationId	= I.intCompanyLocationId      
	, intTermId				= I.intTermId      
	, strInvoiceNumber		= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END      
	, strInvoiceOriginId	= I.strInvoiceOriginId      
	, strBOLNumber			= I.strBOLNumber      
	, strTransactionType	= I.strTransactionType      
	, dblInvoiceTotal		= CASE WHEN strTransactionType IN ('Credit Memo', 'Overpayment') THEN I.dblInvoiceTotal * -1          
		 						   WHEN strTransactionType = 'Customer Prepayment' THEN 0.00
		 						   ELSE I.dblInvoiceTotal
		 					  END      
	, dblBalance			= CASE WHEN strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN I.dblInvoiceTotal * -1               
								   ELSE I.dblInvoiceTotal
							  END - CASE WHEN strTransactionType = 'Customer Prepayment' THEN 0.00 ELSE 0.00 END      
    , dblPayment			= CASE WHEN strTransactionType = 'Customer Prepayment' THEN I.dblInvoiceTotal 
								   ELSE 0.00
							  END
	, dtmDate				= I.dtmDate      
	, dtmDueDate			= I.dtmDueDate      
	, dtmShipDate			= I.dtmShipDate
	, dtmPostDate			= I.dtmPostDate
	, strType				= I.strType      
	, strComment			= dbo.fnEliminateHTMLTags(I.strComments, 0)      
	, ysnServiceChargeCredit = I.ysnServiceChargeCredit    
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
WHERE I.ysnPosted = 1       
  AND I.strType <> 'CF Tran'
  AND I.ysnProcessedToNSF = 0

--INVOICE_COP/CPP
UPDATE I
SET strRecordNumber = P.strRecordNumber
  , strPaymentInfo	= P.strPaymentInfo
  , dtmDatePaid		= P.dtmDatePaid
FROM #INVOICES I
INNER JOIN #PAYMENTS P ON I.intPaymentId = P.intPaymentId	  
WHERE I.intPaymentId IS NOT NULL
  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--INVOICE_SCALETICKET
UPDATE I
SET strTicketNumbers = SCALETICKETS.strTicketNumbers
FROM #INVOICES I
CROSS APPLY (     
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)     
	FROM (      
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '      
		FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)        
		INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId	
		WHERE ID.intInvoiceId = I.intInvoiceId
		  AND ID.intTicketId IS NOT NULL
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber      
		FOR XML PATH ('')     
	) INV (strTicketNumber)
) SCALETICKETS

--LOCATION FILTER
IF @strLocationNameLocal IS NOT NULL
	BEGIN
		DECLARE @intCompanyLocationId	INT = NULL

		SELECT TOP 1 @strCompanyLocationIdsLocal	= CAST(intCompanyLocationId AS NVARCHAR(10))
			      , @intCompanyLocationId			= intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strLocationNameLocal

		DELETE FROM #PAYMENTS WHERE intCompanyLocationId <> @intCompanyLocationId
		DELETE FROM #INVOICES WHERE intCompanyLocationId <> @intCompanyLocationId
	END
	
--AGING SUMMARY
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmDateToLocal
										  , @dtmBalanceForwardDate		= @dtmBalanceForwardDateLocal
										  , @intEntityUserId			= @intEntityUserIdLocal										  
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @strUserId					= @strUserId
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  
										  , @ysnFromBalanceForward		= 0										  
										  , @ysnPrintFromCF				= @ysnPrintFromCFLocal

INSERT INTO #AGINGTABLE WITH (TABLOCK) (
	  intEntityCustomerId
	, strCustomerName
    , strEntityNo
	, strCustomerInfo
    , dblCreditLimit
    , dblTotalAR
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
	, dblTempFuture
	, dblUnInvoiced
    , dtmAsOfDate
    , strSalespersonName
	, strSourceTransaction
)
SELECT intEntityCustomerId	= intEntityCustomerId
	, strCustomerName		= strCustomerName
    , strEntityNo           = strCustomerNumber
    , strCustomerInfo       = strCustomerInfo
    , dblCreditLimit        = dblCreditLimit
    , dblTotalAR            = dblTotalAR
    , dblFuture             = dblFuture
    , dbl0Days              = dbl0Days
    , dbl10Days             = dbl10Days
    , dbl30Days             = dbl30Days
    , dbl60Days             = dbl60Days
    , dbl90Days             = dbl90Days
    , dbl91Days             = dbl91Days
    , dblTotalDue           = dblTotalDue
    , dblAmountPaid         = dblAmountPaid
    , dblCredits            = dblCredits
    , dblPrepayments        = dblPrepayments
    , dblPrepaids           = dblPrepaids
    , dblTempFuture         = 0
    , dblUnInvoiced         = 0
    , dtmAsOfDate           = dtmAsOfDate
    , strSalespersonName    = strSalespersonName
    , strSourceTransaction  = strSourceTransaction
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--BALANCE FORWARD AGING SUMMARY
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmBalanceForwardDateLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  
										  , @ysnFromBalanceForward		= 1

INSERT INTO #BALANCEFORWARDTABLE WITH (TABLOCK)  (
	  intEntityCustomerId
	, strCustomerName
    , strEntityNo
	, strCustomerInfo
    , dblCreditLimit
    , dblTotalAR
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
	, dblTempFuture
	, dblUnInvoiced
    , dtmAsOfDate
    , strSalespersonName
	, strSourceTransaction
)
SELECT intEntityCustomerId	= intEntityCustomerId
	, strCustomerName		= strCustomerName
    , strEntityNo           = strCustomerNumber
    , strCustomerInfo       = strCustomerInfo
    , dblCreditLimit        = dblCreditLimit
    , dblTotalAR            = dblTotalAR
    , dblFuture             = dblFuture
    , dbl0Days              = dbl0Days
    , dbl10Days             = dbl10Days
    , dbl30Days             = dbl30Days
    , dbl60Days             = dbl60Days
    , dbl90Days             = dbl90Days
    , dbl91Days             = dbl91Days
    , dblTotalDue           = dblTotalDue
    , dblAmountPaid         = dblAmountPaid
    , dblCredits            = dblCredits
    , dblPrepayments        = dblPrepayments
    , dblPrepaids           = dblPrepaids
    , dblTempFuture         = 0
    , dblUnInvoiced         = 0
    , dtmAsOfDate           = dtmAsOfDate
    , strSalespersonName    = strSalespersonName
    , strSourceTransaction  = strSourceTransaction
FROM tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--SUBPAYMENTS
IF @ysnPrintFromCF = 0
BEGIN
	INSERT INTO #PAYMENTSFORCF (
		  intEntityCustomerId
		, intPaymentId
		, intCompanyLocationId
		, strRecordNumber
		, strPaymentInfo
		, strTransactionType
		, dblPayment
		, dtmDate
		, dtmDatePaid
		, strComment
	)
	SELECT intEntityCustomerId		= P.intEntityCustomerId    
		, intPaymentId				= P.intPaymentId    
		, intCompanyLocationId		= P.intCompanyLocationId    
		, strRecordNumber			= P.strRecordNumber + ' - ' + ISNULL(PD.strInvoiceNumber , '')    
		, strPaymentInfo			= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')    
		, strTransactionType		= 'Payment'    
		, dblPayment				= SUM(PD.dblPayment)    
		, dtmDate					= P.dtmDatePaid    
		, dtmDatePaid				= P.dtmDatePaid    
		, strComment				= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END
	FROM #PAYMENTS P WITH (NOLOCK)  
	INNER JOIN (   
		SELECT intPaymentId		= PD.intPaymentId        
			 , intInvoiceId		= PD.intInvoiceId
			 , strInvoiceNumber	= I.strInvoiceNumber
			 , dblPayment		= SUM(PD.dblPayment) + SUM(PD.dblDiscount) + SUM(PD.dblWriteOffAmount) - SUM(PD.dblInterest)      
			 , dblInvoiceTotal	= I.dblInvoiceTotal   
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)   
		INNER JOIN (    
			SELECT intInvoiceId			= intInvoiceId
				 , strInvoiceNumber		= strInvoiceNumber
				 , dblInvoiceTotal		= CASE WHEN dtmDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal THEN dblInvoiceTotal ELSE 0 END     
			FROM #INVOICES
		) I ON I.intInvoiceId = PD.intInvoiceId    
		GROUP BY intPaymentId, PD.intInvoiceId, I.strInvoiceNumber, I.dblInvoiceTotal   
	) PD ON P.intPaymentId = PD.intPaymentId  
	LEFT JOIN (   
		SELECT dblPayment		= ABS(SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest))
			 , intInvoiceId		= intInvoiceId
		FROM tblARPaymentDetail PD WITH (NOLOCK)    
		INNER JOIN (    
			SELECT intPaymentId    
			FROM #PAYMENTS WITH (NOLOCK)    
			WHERE ysnInvoicePrepayment = 0      
			 AND dtmDatePaid <= @dtmDateToLocal   
		) P ON PD.intPaymentId = P.intPaymentId   
		GROUP BY intInvoiceId  
	) TOTALPAYMENT ON PD.intInvoiceId = TOTALPAYMENT.intInvoiceId  
	WHERE P.ysnInvoicePrepayment = 0    
	 AND ((PD.dblInvoiceTotal - TOTALPAYMENT.dblPayment <> 0 OR PD.dblInvoiceTotal - TOTALPAYMENT.dblPayment = 0))
	GROUP BY P.intPaymentId, intEntityCustomerId, intCompanyLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid, PD.intInvoiceId, strInvoiceNumber, strNotes
END
ELSE
BEGIN
	INSERT INTO #PAYMENTSFORCF (
		  intEntityCustomerId
		, intPaymentId
		, intCompanyLocationId
		, strRecordNumber
		, strPaymentInfo
		, strTransactionType
		, dblPayment
		, dtmDate
		, dtmDatePaid
		, strComment
	)
	SELECT intEntityCustomerId		= P.intEntityCustomerId    
		 , intPaymentId				= P.intPaymentId    
		 , intCompanyLocationId		= P.intCompanyLocationId    
		 , strRecordNumber			= P.strRecordNumber    
		 , strPaymentInfo			= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')    
		 , strTransactionType		= 'Payment'    
		 , dblPayment				= P.dblAmountPaid    
		 , dtmDate					= P.dtmDatePaid    
		 , dtmDatePaid				= P.dtmDatePaid    
		 , strComment				= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END    
	FROM #PAYMENTS P WITH (NOLOCK)
	INNER JOIN (   
		SELECT PD.intPaymentId   
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)   
		INNER JOIN #INVOICES I ON I.intInvoiceId = PD.intInvoiceId  
	) PD ON P.intPaymentId = PD.intPaymentId  
	WHERE P.ysnInvoicePrepayment = 0    
	GROUP BY P.intPaymentId, intEntityCustomerId, intCompanyLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid, strNotes    

	UNION ALL    

	SELECT intEntityCustomerId		= P.intEntityCustomerId    
		 , intPaymentId				= P.intPaymentId    
		 , intCompanyLocationId		= P.intCompanyLocationId    
		 , strRecordNumber			= P.strRecordNumber    
		 , strPaymentInfo			= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')    
		 , strTransactionType		= 'Discount Taken'    
		 , dblPayment				= ISNULL(PD.dblDiscountTaken, 0)    
		 , dtmDate					= P.dtmDatePaid   
		 , dtmDatePaid				= P.dtmDatePaid    
		 , strComment				= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END    
	FROM #PAYMENTS P WITH (NOLOCK)  
	INNER JOIN (   
		SELECT intPaymentId		= PD.intPaymentId
			 , dblDiscountTaken = SUM(PD.dblDiscount)   
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)   
		INNER JOIN #INVOICES I ON I.intInvoiceId = PD.intInvoiceId   
		WHERE dblDiscount <> 0   
		GROUP BY PD.intPaymentId  
	) PD ON P.intPaymentId = PD.intPaymentId  
	WHERE P.ysnInvoicePrepayment = 0    
	GROUP BY P.intPaymentId, intEntityCustomerId, intCompanyLocationId, strRecordNumber, strPaymentInfo, dtmDatePaid, PD.dblDiscountTaken, strNotes    
  
	UNION ALL   

	SELECT intEntityCustomerId		= P.intEntityCustomerId    
		, intPaymentId				= P.intPaymentId    
		, intCompanyLocationId		= P.intCompanyLocationId    
		, strRecordNumber			= P.strRecordNumber + ' - ' + 'Write Off'    
		, strPaymentInfo			= 'PAYMENT REF: ' + ISNULL(P.strPaymentInfo, '')    
		, strTransactionType		= 'Payment'    
		, dblPayment				= ISNULL(PD.dblWriteOffAmount, 0)    
		, dtmDate					= P.dtmDatePaid    
		, dtmDatePaid				= P.dtmDatePaid    
		, strComment				= ISNULL(P.strPaymentInfo, '') + CASE WHEN ISNULL(P.strNotes, '') <> '' THEN ' - ' + P.strNotes ELSE '' END    
	FROM #PAYMENTS P WITH (NOLOCK)  
	INNER JOIN (   
		SELECT intPaymentId			= PD.intPaymentId
			 , dblWriteOffAmount	= SUM(PD.dblWriteOffAmount)   
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)   
		INNER JOIN #INVOICES I ON I.intInvoiceId = PD.intInvoiceId   
		WHERE PD.dblWriteOffAmount <> 0   
		GROUP BY PD.intPaymentId  
	) PD ON P.intPaymentId = PD.intPaymentId  
	WHERE P.ysnInvoicePrepayment = 0    
	GROUP BY P.intPaymentId, intEntityCustomerId, intCompanyLocationId, strRecordNumber, strPaymentInfo, dtmDatePaid, PD.dblWriteOffAmount, strNotes
END

--MAIN QUERY
INSERT INTO #STATEMENTTABLE WITH (TABLOCK)(
	  intEntityCustomerId
	, strCustomerNumber
	, strCustomerName
	, dblCreditLimit
	, intInvoiceId
	, strInvoiceNumber
	, strBOLNumber
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dblInvoiceTotal
	, intPaymentId
	, strRecordNumber
	, strTransactionType
	, strPaymentInfo
	, dtmDatePaid
	, dblPayment
	, dblBalance
	, strSalespersonName
	, strTicketNumbers
	, strLocationName
	, strFullAddress
	, strComment
	, strStatementFooterComment
	, dblARBalance
	, strType
)
SELECT intEntityCustomerId			= C.intEntityCustomerId     
	, strCustomerNumber			= C.strCustomerNumber     
	, strCustomerName				= C.strCustomerName     
	, dblCreditLimit				= C.dblCreditLimit     
	, intInvoiceId					= TRANSACTIONS.intInvoiceId     
	, strInvoiceNumber				= TRANSACTIONS.strInvoiceNumber     
	, strBOLNumber					= CASE WHEN TRANSACTIONS.strTransactionType = 'Customer Prepayment' THEN 'Prepayment: ' + ISNULL(TRANSACTIONS.strPaymentInfo, '') ELSE 'BOL# ' + TRANSACTIONS.strBOLNumber END        
	, dtmDate						= TRANSACTIONS.dtmDate        
	, dtmDueDate					= TRANSACTIONS.dtmDueDate     
	, dtmShipDate					= TRANSACTIONS.dtmShipDate     
	, dblInvoiceTotal				= TRANSACTIONS.dblInvoiceTotal     
	, intPaymentId					= TRANSACTIONS.intPaymentId     
	, strRecordNumber				= TRANSACTIONS.strRecordNumber     
	, strTransactionType			= CASE WHEN ISNULL(TRANSACTIONS.ysnServiceChargeCredit, 0) = 1 THEN 'Forgiven Service Charge' ELSE TRANSACTIONS.strTransactionType END     
	, strPaymentInfo				= TRANSACTIONS.strPaymentInfo     
	, dtmDatePaid					= ISNULL(TRANSACTIONS.dtmDatePaid, '01/01/1900')     
	, dblPayment					= ISNULL(TRANSACTIONS.dblPayment, 0)    
	, dblBalance					= TRANSACTIONS.dblBalance     
	, strSalespersonName			= C.strSalesPersonName        
	, strTicketNumbers				= TRANSACTIONS.strTicketNumbers     
	, strLocationName				= CL.strLocationName     
	, strFullAddress				= C.strFullAddress     
	, strComment					= TRANSACTIONS.strComment     
	, strStatementFooterComment	= C.strStatementFooterComment     
	, dblARBalance					= C.dblARBalance     
	, strType						= TRANSACTIONS.strType  
FROM #CUSTOMERS C
LEFT JOIN (    
	SELECT intInvoiceId
		, intEntityCustomerId
		, intCompanyLocationId
		, strInvoiceNumber
		, strBOLNumber
		, dtmDate
		, dtmDueDate
		, dtmShipDate
		, dblInvoiceTotal
		, intPaymentId
		, strRecordNumber
		, strTransactionType
		, strPaymentInfo
		, dtmDatePaid
		, dblPayment
		, dblBalance
		, strTicketNumbers
		, strComment
		, strType
		, ysnServiceChargeCredit
	FROM #INVOICES
	WHERE dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

	UNION ALL   

	SELECT intInvoiceId				= NULL
		, intEntityCustomerId
		, intCompanyLocationId
		, strInvoiceNumber			= NULL
		, strBOLNumber				= NULL
		, dtmDate
		, dtmDueDate				= NULL
		, dtmShipDate				= NULL
		, dblInvoiceTotal
		, intPaymentId
		, strRecordNumber
		, strTransactionType
		, strPaymentInfo
		, dtmDatePaid
		, dblPayment
		, dblBalance
		, strTicketNumbers			= NULL
		, strComment
		, strType					= NULL
		, ysnServiceChargeCredit	= 0
	FROM #PAYMENTSFORCF
) TRANSACTIONS ON TRANSACTIONS.intEntityCustomerId = C.intEntityCustomerId   
INNER JOIN tblSMCompanyLocation CL ON TRANSACTIONS.intCompanyLocationId = CL.intCompanyLocationId  

--BUDGET RECORDS
IF @ysnIncludeBudgetLocal = 1
    BEGIN
		INSERT INTO #STATEMENTTABLE (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblCreditLimit
			, intInvoiceId
			, strInvoiceNumber
			, dtmDate
			, dtmDueDate
			, dblInvoiceTotal
			, intPaymentId
			, strRecordNumber
			, strTransactionType
			, strFullAddress
			, strStatementFooterComment
			, dblARBalance
		)
        SELECT intEntityCustomerId      = C.intEntityCustomerId 
			, strCustomerNumber         = C.strCustomerNumber
			, strCustomerName           = C.strCustomerName
			, dblCreditLimit            = C.dblCreditLimit
			, intInvoiceId				= CB.intCustomerBudgetId
			, strInvoiceNumber			= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
			, dtmDate					= dtmBudgetDate
			, dtmDueDate				= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
			, dblInvoiceTotal			= dblBudgetAmount - dblAmountPaid
			, intPaymentId				= CB.intCustomerBudgetId
			, strRecordNumber			= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			, strTransactionType		= 'Customer Budget'
			, strFullAddress			= C.strFullAddress
			, strStatementFooterComment	= C.strStatementFooterComment
			, dblARBalance				= C.dblARBalance
        FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
		INNER JOIN tblARCustomer CUST ON CB.intEntityCustomerId = CUST.intEntityId				
        WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
          AND CB.dblAmountPaid < CB.dblBudgetAmount

		IF EXISTS(SELECT TOP 1 NULL FROM #STATEMENTTABLE WHERE strTransactionType = 'Customer Budget')
			BEGIN
				UPDATE STATEMENTS
				SET strLocationName	= COMPLETESTATEMENTS.strLocationName
				FROM #STATEMENTTABLE STATEMENTS
				CROSS APPLY (
					SELECT TOP 1 strLocationName
					FROM #STATEMENTTABLE
					WHERE intEntityCustomerId = STATEMENTS.intEntityCustomerId
				) COMPLETESTATEMENTS
				WHERE strTransactionType = 'Customer Budget'
			END
    END

IF @ysnPrintFromCFLocal = 1
	BEGIN
		UPDATE #BALANCEFORWARDTABLE SET dblTotalAR = dblTotalAR - dblFuture

		UPDATE AGINGREPORT
		SET AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days + ISNULL(CF.dblTotalFuture, 0)
		  , AGINGREPORT.dblFuture = AGINGREPORT.dblFuture - ISNULL(CF.dblTotalFuture, 0)
		  , AGINGREPORT.dblTempFuture = ISNULL(CF.dblTotalFuture, 0)
		  , AGINGREPORT.dblUnInvoiced = ISNULL(CFDT.dblUnInvoiced, 0)
		FROM #AGINGTABLE AGINGREPORT
		LEFT JOIN (
			SELECT intEntityCustomerId
				 , dblTotalFuture = SUM(CASE WHEN strTransactionType NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN 1 ELSE -1 END * dblAmountDue)
			FROM tblARInvoice WITH (NOLOCK)
			WHERE strType = 'CF Tran'
			AND ysnPaid = 0
			AND ysnPosted = 1
			AND intInvoiceId IN (SELECT intInvoiceId FROM tblCFInvoiceStagingTable WHERE strUserId = @strUserId and LOWER(strStatementType) = 'invoice')
			GROUP BY intEntityCustomerId
		) CF ON AGINGREPORT.intEntityCustomerId = CF.intEntityCustomerId
		LEFT JOIN (
			SELECT I.intEntityCustomerId
				 , dblUnInvoiced = SUM(CASE WHEN I.strTransactionType NOT IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN 1 ELSE -1 END * I.dblAmountDue)
			FROM tblARInvoice I WITH (NOLOCK)
			INNER JOIN tblCFTransaction CF ON I.strInvoiceNumber = CF.strTransactionId
			WHERE I.strType = 'CF Tran'
			AND I.ysnPaid = 0
			AND I.ysnPosted = 1
			AND CF.ysnInvoiced = 0
			AND I.intInvoiceId NOT IN (SELECT intInvoiceId FROM tblCFInvoiceStagingTable WHERE strUserId = @strUserId and LOWER(strStatementType) = 'invoice')
			AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY I.intEntityCustomerId
		) CFDT ON AGINGREPORT.intEntityCustomerId = CFDT.intEntityCustomerId
		
		IF @ysnReprintInvoiceLocal = 0
			BEGIN
				UPDATE AGINGREPORT
				SET AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days + ISNULL(CF.dblTotalFee, 0)
				  , AGINGREPORT.dblTotalAR = AGINGREPORT.dblTotalAR - ISNULL(AGINGREPORT.dblUnInvoiced, 0) + ISNULL(CF.dblTotalFee, 0)
				FROM #AGINGTABLE AGINGREPORT
				LEFT JOIN (
					SELECT intCustomerId
						 , dblTotalFee = SUM(ISNULL(dblFeeAmount, 0))
					FROM dbo.tblCFInvoiceFeeStagingTable WITH (NOLOCK)
					WHERE strUserId = @strUserId
					GROUP BY intCustomerId
				) CF ON AGINGREPORT.intEntityCustomerId = CF.intCustomerId
			END
		ELSE
			BEGIN
				UPDATE AGINGREPORT
				SET AGINGREPORT.dblFuture = 0.000000
				  , AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days - ISNULL(AGINGREPORT.dblTempFuture, 0)
				  , AGINGREPORT.dblTotalAR = AGINGREPORT.dblTotalAR - (ISNULL(AGINGREPORT.dblTempFuture, 0) + ISNULL(AGINGREPORT.dblUnInvoiced, 0))
				FROM #AGINGTABLE AGINGREPORT
			END
	END
ELSE 
	BEGIN
		UPDATE #STATEMENTTABLE SET dblBalance = dblPayment * -1 WHERE strTransactionType = 'Payment'
		
		UPDATE #STATEMENTTABLE SET dblBalance = dblInvoiceTotal WHERE strTransactionType IN ('Invoice', 'Debit Memo') AND dblBalance <> 0
	END

--BALANCE FORWARD LINE ITEM
INSERT INTO #STATEMENTTABLE (
	  intEntityCustomerId
	, strCustomerName
	, strCustomerNumber
	, strTransactionType
	, dblCreditLimit
	, dtmDate
	, dtmDatePaid
	, intInvoiceId
	, dblBalance
	, dblPayment
	, strFullAddress
	, strStatementFooterComment
	, dblInvoiceTotal
)
SELECT intEntityCustomerId		= ISNULL(BALANCEFORWARD.intEntityCustomerId, C.intEntityCustomerId)
	, strCustomerName			= ISNULL(BALANCEFORWARD.strCustomerName, C.strCustomerName)
	, strCustomerNumber			= ISNULL(BALANCEFORWARD.strEntityNo, C.strCustomerNumber)
	, strTransactionType		= 'Balance Forward'
	, dblCreditLimit			= ISNULL(BALANCEFORWARD.dblCreditLimit, C.dblCreditLimit)
	, dtmDate					= @dtmBalanceForwardDateLocal
	, dtmDatePaid				= '01/01/1900'
	, intInvoiceId				= 1
	, dblBalance				= ISNULL(BALANCEFORWARD.dblTotalAR, 0)
	, dblPayment				= 0
	, strFullAddress			= C.strFullAddress
	, strStatementFooterComment	= C.strStatementFooterComment
	, dblInvoiceTotal			= ISNULL(BALANCEFORWARD.dblTotalAR, 0)
FROM #BALANCEFORWARDTABLE BALANCEFORWARD
INNER JOIN #CUSTOMERS C ON C.intEntityCustomerId = BALANCEFORWARD.intEntityCustomerId    

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateToLocal, SUM(ISNULL(dblBalance, 0))
FROM #STATEMENTTABLE GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN
        DELETE FROM #STATEMENTTABLE WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) <= 0 AND strTransactionType <> 'Balance Forward'
		UPDATE #AGINGTABLE
		SET dblFuture 	= 0
		  , dbl0Days 	= 0
		  , dblTotalAR 	= ISNULL(dblTotalAR, 0) - ISNULL(dbl0Days, 0) - ISNULL(dblFuture, 0)
    END

SET @dblTotalAR = (SELECT SUM(dblTotalAR) FROM #AGINGTABLE)

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
		IF @dblTotalAR = 0 
		BEGIN
			DELETE FROM #STATEMENTTABLE WHERE ((((ABS(dblBalance) * 10000) - CONVERT(FLOAT, (ABS(dblBalance) * 10000))) <> 0) OR ISNULL(dblBalance, 0) <= 0) AND strTransactionType NOT IN ('Balance Forward', 'Customer Budget')
			DELETE FROM #AGINGTABLE WHERE (((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) <= 0
		END
	END

INSERT INTO #CFTABLE (
	  intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT intInvoiceId				= CF.intInvoiceId
	, strInvoiceNumber			= CF.strInvoiceNumber
	, strInvoiceReportNumber	= CF.strInvoiceReportNumber
	, dtmInvoiceDate			= CF.dtmInvoiceDate
FROM #STATEMENTTABLE statementTable
INNER JOIN (
	SELECT ARI.intInvoiceId 
		 , ARI.strInvoiceNumber
		 , CFT.strInvoiceReportNumber
		 , CFT.dtmInvoiceDate
	FROM (
		SELECT intInvoiceId
			 , strInvoiceNumber
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE strType NOT IN ('CF Tran')
	) ARI
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM dbo.tblCFTransaction WITH (NOLOCK)
		WHERE strInvoiceReportNumber IS NOT NULL
	) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
) CF ON statementTable.intInvoiceId = CF.intInvoiceId

DELETE FROM #STATEMENTTABLE WHERE strTransactionType IS NULL

DELETE FROM #STATEMENTTABLE
WHERE intInvoiceId IN (SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

IF @ysnPrintFromCFLocal = 1
	BEGIN
		DELETE FROM #STATEMENTTABLE WHERE strTransactionType = 'Overpayment'
		DELETE FROM #STATEMENTTABLE WHERE strTransactionType = 'Payment' AND dblPayment = 0
		UPDATE #STATEMENTTABLE SET strTransactionType = 'Payment' WHERE strTransactionType = 'Customer Prepayment' AND strType <> 'CF Tran'
		UPDATE #STATEMENTTABLE SET strTransactionType = 'Invoice' WHERE strTransactionType = 'Debit Memo' AND strType <> 'CF Tran'
		UPDATE #STATEMENTTABLE SET strTransactionType = 'Service Charge' WHERE strType = 'Service Charge'
		DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND (strStatementFormat IS NULL OR strStatementFormat = 'Balance Forward')
	END
ELSE
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Balance Forward'
	END

INSERT INTO tblARCustomerStatementStagingTable WITH (TABLOCK) (
	  intEntityCustomerId
	, intInvoiceId
	, intPaymentId
	, intEntityUserId
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dtmDatePaid
	, dtmAsOfDate
	, strCustomerNumber
	, strCustomerName
	, strInvoiceNumber		
	, strBOLNumber
	, strRecordNumber
	, strTransactionType
	, strPaymentInfo
	, strSalespersonName
	, strLocationName
	, strFullAddress
	, strComment
	, strStatementFooterComment
	, strStatementFormat
	, dblCreditLimit
	, dblInvoiceTotal
	, dblPayment
	, dblBalance
	, dblTotalAR
	, dblCreditAvailable
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblCredits
	, dblPrepayments
	, ysnStatementCreditLimit
	, strTicketNumbers
	, strCompanyName
	, strCompanyAddress
	, ysnStretchLogo
)
SELECT intEntityCustomerId		= MAINREPORT.intEntityCustomerId
	, intInvoiceId				= MAINREPORT.intInvoiceId
	, intPaymentId				= MAINREPORT.intPaymentId
	, intEntityUserId			= @intEntityUserId
	, dtmDate					= MAINREPORT.dtmDate
	, dtmDueDate				= MAINREPORT.dtmDueDate
	, dtmShipDate				= MAINREPORT.dtmShipDate
	, dtmDatePaid				= MAINREPORT.dtmDatePaid
	, dtmAsOfDate				= @dtmDateToLocal
	, strCustomerNumber			= MAINREPORT.strCustomerNumber
	, strCustomerName			= MAINREPORT.strCustomerName
	, strInvoiceNumber			= MAINREPORT.strInvoiceNumber
	, strBOLNumber				= MAINREPORT.strBOLNumber
	, strRecordNumber			= MAINREPORT.strRecordNumber
	, strTransactionType		= MAINREPORT.strTransactionType
	, strPaymentInfo			= MAINREPORT.strPaymentInfo
	, strSalespersonName		= MAINREPORT.strSalespersonName
	, strLocationName			= MAINREPORT.strLocationName
	, strFullAddress			= MAINREPORT.strFullAddress
	, strComment				= MAINREPORT.strComment
	, strStatementFooterComment	= MAINREPORT.strStatementFooterComment
	, strStatementFormat		= 'Balance Forward'
	, dblCreditLimit			= MAINREPORT.dblCreditLimit
	, dblInvoiceTotal			= MAINREPORT.dblInvoiceTotal
	, dblPayment				= MAINREPORT.dblPayment
	, dblBalance				= MAINREPORT.dblBalance
	, dblTotalAR				= ISNULL(AGINGREPORT.dblTotalAR, 0)
	, dblCreditAvailable		= CASE WHEN (MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	, dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	, dbl0Days					= ISNULL(AGINGREPORT.dbl0Days, 0)
	, dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	, dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	, dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	, dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	, dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	, dblCredits				= ISNULL(AGINGREPORT.dblCredits, 0)
	, dblPrepayments			= ISNULL(AGINGREPORT.dblPrepayments, 0)	
	, ysnStatementCreditLimit	= ISNULL(CUSTOMER.ysnStatementCreditLimit, 0)
	, strTicketNumbers			= MAINREPORT.strTicketNumbers
	, strCompanyName			= @strCompanyName
	, strCompanyAddress			= @strCompanyAddress
	, ysnStretchLogo			= ISNULL(@ysnStretchLogo, 0)
FROM (
	--- Without CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= STATEMENTREPORT.intInvoiceId   
		 , strInvoiceNumber
		 , strBOLNumber
		 , dtmDate
		 , dtmDueDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType					= STATEMENTREPORT.strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strLocationName
		 , strFullAddress
		 , strComment							= STATEMENTREPORT.strComment
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strTicketNumbers		 
	FROM #STATEMENTTABLE AS STATEMENTREPORT	
	WHERE STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM #CFTABLE)

	UNION ALL

	--- With CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= CFReportTable.intInvoiceId	 
		 , strInvoiceNumber						= CFReportTable.strInvoiceReportNumber
		 , strBOLNumber
		 , dtmDate								= CFReportTable.dtmInvoiceDate     
		 , dtmDueDate							= CFReportTable.dtmInvoiceDate  
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strLocationName   
		 , strFullAddress
		 , strComment							= STATEMENTREPORT.strComment
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strTicketNumbers
	FROM #STATEMENTTABLE AS STATEMENTREPORT
	INNER JOIN #CFTABLE CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
) MAINREPORT
LEFT JOIN #AGINGTABLE AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
ORDER BY MAINREPORT.dtmDate,MAINREPORT.strTransactionType DESC

IF @ysnPrintFromCFLocal = 0
	BEGIN
		UPDATE STAGING
		SET strComment = EM.strMessage
		FROM tblARCustomerStatementStagingTable STAGING
		INNER JOIN tblEMEntityMessage EM ON STAGING.intEntityCustomerId = EM.intEntityId
		WHERE STAGING.intEntityUserId = @intEntityUserIdLocal
		  AND STAGING.strStatementFormat = 'Balance Forward'
		  AND EM.strMessageType = 'Statement'

		IF @ysnPrintZeroBalanceLocal = 0
			BEGIN
				DELETE ORIG
				FROM tblARCustomerStatementStagingTable ORIG
				INNER JOIN (
					SELECT DISTINCT intEntityCustomerId 
					FROM tblARCustomerStatementStagingTable 
					WHERE dblTotalAR = 0
					 AND intEntityUserId = @intEntityUserIdLocal
					 AND strStatementFormat = 'Balance Forward'
				) ZERO ON ORIG.intEntityCustomerId = ZERO.intEntityCustomerId
				AND intEntityUserId = @intEntityUserIdLocal
				AND strStatementFormat = 'Balance Forward'
			END
	END

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = 'Balance Forward'
		  AND intEntityCustomerId IN (
			  SELECT DISTINCT intEntityCustomerId
			  FROM tblARCustomerAgingStagingTable AGINGREPORT
			  WHERE AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
				AND AGINGREPORT.strAgingType = 'Summary'
				AND AGINGREPORT.dblTotalAR < 0
		  )
	END