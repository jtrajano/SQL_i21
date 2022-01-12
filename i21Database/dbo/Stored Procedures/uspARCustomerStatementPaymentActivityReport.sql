CREATE PROCEDURE [dbo].[uspARCustomerStatementPaymentActivityReport]
	  @dtmDateTo						AS DATETIME			= NULL
	, @dtmDateFrom						AS DATETIME			= NULL
	, @ysnPrintZeroBalance				AS BIT				= 0
	, @ysnPrintCreditBalance			AS BIT				= 1
	, @ysnIncludeBudget					AS BIT				= 0
	, @ysnPrintOnlyPastDue				AS BIT				= 0
	, @ysnActiveCustomers		        AS BIT				= 0
	, @strCustomerNumber				AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode				AS NVARCHAR(MAX)	= NULL
	, @strLocationName					AS NVARCHAR(MAX)	= NULL
	, @strCustomerName					AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds					AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly						AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    	AS BIT 				= 0
	, @intEntityUserId					AS INT				= NULL
AS

SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 0
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @query								AS NVARCHAR(MAX)
	  , @filter								AS NVARCHAR(MAX)	= ''
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL
	  , @dblTotalAR							NUMERIC(18,6)		= NULL

SET @dtmDateToLocal						= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal					= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

--GET COMPANY DETAILS
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry + CHAR(13) + CHAR(10) + strPhone
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

IF(OBJECT_ID('tempdb..#ADCUSTOMERS') IS NOT NULL) DROP TABLE #ADCUSTOMERS
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL) DROP TABLE #COMPANYLOCATIONS
IF(OBJECT_ID('tempdb..#CFTABLE') IS NOT NULL) DROP TABLE #CFTABLE
IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL) DROP TABLE #GLACCOUNTS
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL) DROP TABLE #PAYMENTS
IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL) DROP TABLE #STATEMENTREPORT

--TEMP TABLES
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId			INT				NOT NULL PRIMARY KEY
	, strCustomerNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	, strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	, strSalesPersonName			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	, strStatementFormat			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	, strFullAddress				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	, dblCreditLimit				NUMERIC(18, 6)
	, dblCreditAvailable			NUMERIC(18, 6)
	, dblARBalance					NUMERIC(18, 6)
	, ysnStatementCreditLimit		BIT
	, strComment					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
)
CREATE TABLE #STATEMENTREPORT (
	   intEntityCustomerId			INT NULL
	 , intInvoiceId					INT NULL
	 , intPaymentId					INT NULL	 
	 , strCustomerNumber			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strCustomerName				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumber					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL
	 , strRecordNumber				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strPaymentInfo				NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL
	 , strFullAddress				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
	 , strStatementFooterComment	NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL
     , dtmDate						DATETIME NULL
     , dtmDueDate					DATETIME NULL
	 , dtmDatePaid					DATETIME NULL
	 , dtmShipDate					DATETIME NULL
	 , dblPayment					NUMERIC(18, 6) NULL DEFAULT 0
	 , dblInvoiceTotal				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblCreditLimit				NUMERIC(18, 6) NULL DEFAULT 0
	 , dblBalance					NUMERIC(18, 6) NULL DEFAULT 0
	 , dblARBalance					NUMERIC(18, 6) NULL DEFAULT 0
	 , strComment					NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strSalespersonName			NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL
	 , strTicketNumbers				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
	 , strLocationName				NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTREPORT_PAYMENTACTIVITY] ON [#STATEMENTREPORT]([intEntityCustomerId], [intInvoiceId], [strTransactionType])
CREATE TABLE #CFTABLE (
	  intInvoiceId				INT NOT NULL PRIMARY KEY
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strInvoiceReportNumber	NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, dtmInvoiceDate			DATETIME NULL
)
CREATE TABLE #COMPANYLOCATIONS (
	  intCompanyLocationId	INT	NOT NULL PRIMARY KEY
	, strLocationName		NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #GLACCOUNTS (intAccountId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #INVOICES (
	   intInvoiceId					INT NOT NULL PRIMARY KEY
	 , intEntityCustomerId			INT NOT NULL
	 , intPaymentId					INT NULL
	 , intCompanyLocationId			INT NOT NULL
	 , intTermId					INT NOT NULL
	 , intSourceId					INT NULL
	 , intOriginalInvoiceId			INT NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strInvoiceOriginId			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strBOLNumber					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , strType						NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL
	 , dblInvoiceTotal				NUMERIC(18, 6)	NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18, 6)	NULL DEFAULT 0
	 , dtmDate						DATETIME NULL
	 , dtmDueDate					DATETIME NULL
	 , dtmShipDate					DATETIME NULL
	 , dtmPostDate					DATETIME NULL
	 , ysnImportedFromOrigin		BIT NULL
	 , strTicketNumbers				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#INVOICES_PAYMENTACTIVITY] ON [#INVOICES]([intEntityCustomerId])
CREATE TABLE #PAYMENTS (
	   intPaymentId				INT	NOT NULL PRIMARY KEY
	 , intEntityCustomerId		INT	NOT NULL
	 , strPaymentInfo			NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
	 , strRecordNumber			NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL
	 , dtmDatePaid				DATETIME NOT NULL
	 , ysnInvoicePrepayment		BIT NULL
	 , strPaymentMethod			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#PAYMENTS_PAYMENTACTIVITY] ON [#PAYMENTS]([intEntityCustomerId])

--FILTER CUSTOMER 
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId		= C.intEntityId 
			       , strCustomerNumber			= C.strCustomerNumber
				   , strCustomerName			= EC.strName
				   , strStatementFormat			= C.strStatementFormat
				   , dblCreditLimit				= C.dblCreditLimit
				   , dblCreditAvailable			= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
				   , dblARBalance				= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Payment Activity'
		  AND EC.strEntityNo = @strCustomerNumberLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		SELECT DISTINCT intEntityCustomerId = intID
		INTO #ADCUSTOMERS
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)

		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblCreditAvailable		= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
			 , dblARBalance				= C.dblARBalance        
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #ADCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Payment Activity'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblCreditAvailable, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId		= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName			= EC.strName
			 , strStatementFormat		= C.strStatementFormat
			 , dblCreditLimit			= C.dblCreditLimit
			 , dblCreditAvailable		= CASE WHEN ISNULL(C.dblCreditLimit, 0) = 0 THEN 0 ELSE C.dblCreditLimit - ISNULL(C.dblARBalance, 0) END
			 , dblARBalance				= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND C.strStatementFormat = 'Payment Activity'
		  AND (@strCustomerNameLocal IS NULL OR EC.strName = @strCustomerNameLocal)
	END

--FILTER CUSTOMER BY ACCOUNT STATUS
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

--FILTER CUSTOMER BY EMAIL SETUP
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
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

--#COMPANYLOCATIONS
INSERT INTO #COMPANYLOCATIONS (
	   intCompanyLocationId
	 , strLocationName
)
SELECT intCompanyLocationId
	 , strLocationName
FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
WHERE @strLocationName IS NULL OR @strLocationName = strLocationName

--#GLACCOUNTS
INSERT INTO #GLACCOUNTS (intAccountId)
SELECT intAccountId
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--#INVOICES
INSERT INTO #INVOICES WITH (TABLOCK) (
	   intInvoiceId      
	 , intEntityCustomerId      
	 , intPaymentId      
	 , intCompanyLocationId      
	 , intTermId      
	 , intSourceId      
	 , intOriginalInvoiceId      
	 , strInvoiceNumber      
	 , strInvoiceOriginId      
	 , strBOLNumber      
	 , strTransactionType
	 , strType      
	 , dblInvoiceTotal      
	 , dblAmountDue      
	 , dtmDate      
	 , dtmDueDate      
	 , dtmShipDate
	 , dtmPostDate
	 , ysnImportedFromOrigin      
)
SELECT intInvoiceId				= I.intInvoiceId      
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , intPaymentId				= I.intPaymentId
	 , intCompanyLocationId		= I.intCompanyLocationId
	 , intTermId				= I.intTermId
	 , intSourceId				= I.intSourceId
	 , intOriginalInvoiceId		= I.intOriginalInvoiceId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strInvoiceOriginId		= I.strInvoiceOriginId
	 , strBOLNumber				= I.strBOLNumber
	 , strTransactionType		= I.strTransactionType
	 , strType					= I.strType
	 , dblInvoiceTotal			= I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1 ELSE 1 END
	 , dblAmountDue				= I.dblAmountDue * CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN -1 ELSE 1 END
	 , dtmDate					= I.dtmDate
	 , dtmDueDate				= I.dtmDueDate
	 , dtmShipDate				= I.dtmShipDate
	 , dtmPostDate				= I.dtmPostDate
	 , ysnImportedFromOrigin    = I.ysnImportedFromOrigin
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
WHERE I.ysnPosted = 1    
  AND I.ysnCancelled = 0   
  AND I.strType <> 'CF Tran'    
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))      
  AND I.dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
  	
--#PAYMENTS
INSERT INTO #PAYMENTS WITH (TABLOCK) (
	   intPaymentId
	 , intEntityCustomerId
	 , strRecordNumber
	 , strPaymentInfo
	 , dtmDatePaid
	 , ysnInvoicePrepayment
	 , strPaymentMethod
)
SELECT intPaymentId				= P.intPaymentId
	 , intEntityCustomerId		= P.intEntityCustomerId
	 , strRecordNumber			= P.strRecordNumber
	 , strPaymentInfo			= P.strPaymentInfo
	 , dtmDatePaid				= P.dtmDatePaid
	 , ysnInvoicePrepayment		= P.ysnInvoicePrepayment
	 , strPaymentMethod			= UPPER(PM.strPaymentMethod)
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS L ON P.intLocationId = L.intCompanyLocationId
INNER JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID
WHERE P.ysnPosted = 1
  AND P.ysnInvoicePrepayment = 0
  AND P.dtmDatePaid BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	

--@strCustomerIdsLocal
SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

--@strCompanyLocationIdsLocal
IF @strLocationNameLocal IS NOT NULL
	BEGIN
		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM #COMPANYLOCATIONS
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal

--CUSTOMER_ADDRESS
UPDATE C
SET strFullAddress		= EL.strAddress + CHAR(13) + CHAR(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry
  , strSalesPersonName	= SP.strName
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1
INNER JOIN tblEMEntity SP ON EL.intSalespersonId = SP.intEntityId

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
	  AND M.intEntityCustomerId = C.intEntityCustomerId
	  AND M.intEntityCustomerId IS NOT NULL
	ORDER BY M.intDocumentMaintenanceId DESC
		   , intEntityCustomerId DESC
) FOOTER

--FILTER WRITE OFF	
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		DELETE P
		FROM #PAYMENTS P
		WHERE strPaymentMethod = 'WRITE OFF'
	END

--#STATEMENTREPORT
INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
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
	 , strFullAddress
	 , strStatementFooterComment
	 , dblARBalance
)
SELECT intEntityCustomerId			= C.intEntityCustomerId     
	 , strCustomerNumber			= C.strCustomerNumber     
	 , strCustomerName				= C.strCustomerName     
	 , dblCreditLimit				= C.dblCreditLimit     
	 , intInvoiceId					= I.intInvoiceId     
	 , strInvoiceNumber				= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END     
	 , strBOLNumber					= CASE WHEN I.strTransactionType = 'Customer Prepayment' THEN 'Prepayment: ' + ISNULL(PCREDITS.strPaymentInfo, '') ELSE 'BOL# ' + I.strBOLNumber END        
	 , dtmDate						= I.dtmDate
	 , dtmDueDate					= I.dtmDueDate
	 , dtmShipDate					= I.dtmShipDate
	 , dblInvoiceTotal				= I.dblInvoiceTotal
	 , intPaymentId					= ISNULL(ISNULL(PD.intPaymentId, PCREDITS.intPaymentId), PRO.intInvoiceId)
	 , strRecordNumber				= ISNULL(ISNULL(PD.strRecordNumber, PCREDITS.strRecordNumber), PRO.strInvoiceNumber)
	 , strTransactionType			= I.strTransactionType     
	 , strPaymentInfo				= 'PAYMENT REF: ' + ISNULL(ISNULL(PD.strPaymentInfo, PD.strRecordNumber), PRO.strInvoiceNumber)
	 , dtmDatePaid					= ISNULL(ISNULL(PD.dtmDatePaid, PCREDITS.dtmDatePaid), PRO.dtmPostDate)
	 , dblPayment					= ISNULL(PD.dblPayment, 0) + ISNULL(PRO.dblPayment, 0)  
	 , dblBalance					= CASE WHEN I.intSourceId = 2 AND ISNULL(I.intOriginalInvoiceId, 0) <> 0 THEN I.dblAmountDue ELSE I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) END     
	 , strSalespersonName			= C.strSalesPersonName        
	 , strTicketNumbers				= I.strTicketNumbers     
	 , strFullAddress				= C.strFullAddress     
	 , strStatementFooterComment	= C.strStatementFooterComment     
	 , dblARBalance					= C.dblARBalance  
FROM #CUSTOMERS C
LEFT JOIN #INVOICES I ON I.intEntityCustomerId = C.intEntityCustomerId   
LEFT JOIN (    
	SELECT intInvoiceId			= PD.intInvoiceId      
		 , dblPayment			= PD.dblPayment + dblDiscount + PD.dblWriteOffAmount - PD.dblInterest
		 , intPaymentId			= P.intPaymentId
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)     
	INNER JOIN #PAYMENTS P ON PD.intPaymentId = P.intPaymentId
	WHERE P.ysnInvoicePrepayment = 0
) PD ON I.intInvoiceId = PD.intInvoiceId
LEFT JOIN (
	SELECT intInvoiceId			= PR.intInvoiceId
		 , dblPayment			= PR.dblInvoiceTotal
		 , strInvoiceNumber		= PR.strInvoiceNumber
		 , dtmPostDate			= PR.dtmPostDate
	FROM #INVOICES PR
	WHERE PR.strType = 'Provisional'
) PRO ON I.intOriginalInvoiceId = PRO.intInvoiceId
LEFT JOIN #PAYMENTS PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId   
LEFT JOIN (    
	SELECT intInvoiceId      
		 , dblPayment   = SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)    
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)    
	INNER JOIN #PAYMENTS P ON PD.intPaymentId = P.intPaymentId
	WHERE P.ysnInvoicePrepayment = 0    
	GROUP BY intInvoiceId    
) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId   

--#STATEMENTREPORT BUDGET
IF @ysnIncludeBudgetLocal = 1
    BEGIN        
		INSERT INTO #STATEMENTREPORT WITH (TABLOCK) (
			   intEntityCustomerId
			 , strCustomerNumber
			 , strCustomerName
			 , dblCreditLimit
			 , intInvoiceId
			 , strInvoiceNumber
			 , dtmDate
			 , dtmDueDate
			 , dblInvoiceTotal
			 , strRecordNumber
			 , strTransactionType
			 , dblPayment
			 , strFullAddress
			 , strStatementFooterComment
			 , dblARBalance
		)
		SELECT intEntityCustomerId         = C.intEntityCustomerId 
			 , strCustomerNumber           = C.strCustomerNumber
			 , strCustomerName             = C.strCustomerName
			 , dblCreditLimit              = C.dblCreditLimit
			 , intInvoiceId					= CB.intCustomerBudgetId
			 , strInvoiceNumber				= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
			 , dtmDate						= dtmBudgetDate
			 , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
			 , dblInvoiceTotal				= dblBudgetAmount
			 , strRecordNumber				= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
			 , strTransactionType			= 'Customer Budget'
			 , dblPayment					= dblAmountPaid
			 , strFullAddress				= C.strFullAddress
			 , strStatementFooterComment	= C.strStatementFooterComment
			 , dblARBalance					= C.dblARBalance
        FROM tblARCustomerBudget CB
        INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
        WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
          AND CB.dblAmountPaid < CB.dblBudgetAmount

		IF EXISTS(SELECT TOP 1 NULL FROM #STATEMENTREPORT WHERE strTransactionType = 'Customer Budget')
			BEGIN
				UPDATE STATEMENTS
				SET strLocationName	= COMPLETESTATEMENTS.strLocationName
				FROM #STATEMENTREPORT STATEMENTS
				CROSS APPLY (
					SELECT TOP 1 strLocationName
					FROM #STATEMENTREPORT
					WHERE intEntityCustomerId = STATEMENTS.intEntityCustomerId
				) COMPLETESTATEMENTS
				WHERE strTransactionType = 'Customer Budget'
			END
    END

IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN        
		DELETE FROM #STATEMENTREPORT WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) <= 0
		UPDATE tblARCustomerAgingStagingTable
		SET dbl0Days = 0
		WHERE intEntityUserId = @intEntityUserIdLocal
		  AND strAgingType = 'Summary'		
    END

SELECT @dblTotalAR = SUM(dblTotalAR) FROM tblARCustomerAgingStagingTable

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
		IF @dblTotalAR = 0 
		BEGIN
			DELETE FROM #STATEMENTREPORT WHERE ((((ABS(dblBalance) * 10000) - CONVERT(FLOAT, (ABS(dblBalance) * 10000))) <> 0) OR ISNULL(dblBalance, 0) <= 0) AND strTransactionType <> 'Customer Budget'
			DELETE FROM tblARCustomerAgingStagingTable WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) <= 0) AND intEntityUserId = @intEntityUserIdLocal AND strAgingType = 'Summary'
		END   
   END

--#CFTABLE	
INSERT INTO #CFTABLE WITH (TABLOCK) (
	  intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT cfTable.intInvoiceId
	 , cfTable.strInvoiceNumber
	 , cfTable.strInvoiceReportNumber
	 , cfTable.dtmInvoiceDate
FROM #STATEMENTREPORT statementTable
INNER JOIN (
	SELECT ARI.intInvoiceId 
		 , ARI.strInvoiceNumber
		 , CFT.strInvoiceReportNumber
		 , CFT.dtmInvoiceDate
	FROM tblARInvoice ARI WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM dbo.tblCFTransaction WITH (NOLOCK)
		WHERE strInvoiceReportNumber IS NOT NULL
		  AND strInvoiceReportNumber <> ''
	) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
	WHERE ARI.strType NOT IN ('CF Tran')
) cfTable ON statementTable.intInvoiceId = cfTable.intInvoiceId

DELETE FROM #STATEMENTREPORT
WHERE intInvoiceId IN (SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

--LOG STATEMENT HISTORY
MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateToLocal, SUM(ISNULL(dblBalance, 0))
FROM #STATEMENTREPORT GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = 'Payment Activity'
INSERT INTO tblARCustomerStatementStagingTable WITH (TABLOCK) (
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
	, strPaymentInfo
	, dtmDatePaid
	, dblPayment
	, dblBalance
	, strSalespersonName
	, strLocationName
	, strFullAddress
	, strStatementFooterComment	
	, strTicketNumbers
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
	, dtmAsOfDate
	, intEntityUserId
	, strStatementFormat
	, ysnStatementCreditLimit
	, strComment
)
SELECT MAINREPORT.*
	 , dblCreditAvailable			= CASE WHEN (MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days						= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits					= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments				= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , dtmAsOfDate					= @dtmDateToLocal
	 , intEntityUserId				= @intEntityUserIdLocal
	 , strStatementFormat			= 'Payment Activity'
	 , ysnStatementCreditLimit		= ISNULL(CUSTOMER.ysnStatementCreditLimit, 0)
	 , strComment					= CUSTOMER.strComment
FROM (
	--- Without CF Report
	SELECT intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName				= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId								 
		 , strInvoiceNumber
		 , strBOLNumber
		 , dtmDate
		 , dtmDueDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName			= STATEMENTREPORT.strSalespersonName
		 , strLocationName
		 , strFullAddress
		 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment
		 , strTicketNumbers				= STATEMENTREPORT.strTicketNumbers
	FROM #STATEMENTREPORT AS STATEMENTREPORT
	WHERE STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM #CFTABLE)

	UNION ALL

	--- With CF Report
	SELECT intEntityCustomerId			= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber			= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName				= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit				= STATEMENTREPORT.dblCreditLimit			
		 , intInvoiceId					= CF.intInvoiceId
		 , strInvoiceNumber				= CF.strInvoiceReportNumber
		 , strBOLNumber
		 , dtmDate						= CF.dtmInvoiceDate				
		 , dtmDueDate					= CF.dtmInvoiceDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName			= STATEMENTREPORT.strSalespersonName
		 , strLocationName
		 , strFullAddress
		 , strStatementFooterComment	= STATEMENTREPORT.strStatementFooterComment			
		 , strTicketNumbers				= STATEMENTREPORT.strTicketNumbers
	FROM #STATEMENTREPORT AS STATEMENTREPORT
	INNER JOIN #CFTABLE CF ON STATEMENTREPORT.intInvoiceId = CF.intInvoiceId
) MAINREPORT
LEFT JOIN tblARCustomerAgingStagingTable AS AGINGREPORT 
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	AND AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
	AND AGINGREPORT.strAgingType = 'Summary'
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId

UPDATE tblARCustomerStatementStagingTable
SET strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strStatementFormat = 'Payment Activity'
