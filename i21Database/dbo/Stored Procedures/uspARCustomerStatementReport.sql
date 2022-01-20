CREATE PROCEDURE [dbo].[uspARCustomerStatementReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnActiveCustomers			AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strStatementFormat			AS NVARCHAR(MAX)	= 'Open Item'
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @intEntityUserId				AS INT				= NULL
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
	  , @strStatementFormatLocal			AS NVARCHAR(MAX)	= 'Open Item'
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)	  
	  , @filter								AS NVARCHAR(MAX)	= ''
	  , @query								AS NVARCHAR(MAX)	= ''
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= ''
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @ysnStretchLogo						AS BIT				= 0
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL
	  , @dblTotalAR							NUMERIC(18,6)		= NULL

IF(OBJECT_ID('tempdb..#ADCUSTOMERS') IS NOT NULL) DROP TABLE #ADCUSTOMERS	  
IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL) DROP TABLE #CUSTOMERS
IF(OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL) DROP TABLE #LOCATIONS
IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL) DROP TABLE #GLACCOUNTS
IF(OBJECT_ID('tempdb..#STATEMENTTABLE') IS NOT NULL) DROP TABLE #STATEMENTTABLE
IF(OBJECT_ID('tempdb..#CFTABLE') IS NOT NULL) DROP TABLE #CFTABLE
IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL) DROP TABLE #INVOICES
IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL) DROP TABLE #PAYMENTS

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
SET @strStatementFormatLocal			= ISNULL(@strStatementFormat, 'Open Item')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

--LOGO
SELECT TOP 1 @ysnStretchLogo = ysnStretchLogo
FROM tblARCompanyPreference WITH (NOLOCK)

--RUNNING BALANCE QUERY
IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY I.dtmPostDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
	END
ELSE  
	BEGIN
		SET @queryRunningBalance = ' , I.intInvoiceId '
	END

--COMPANY INFO
SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = strAddress + CHAR(13) + char(10) + strCity + ', ' + strState + ', ' + strZip + ', ' + strCountry + CHAR(13) + CHAR(10) + strPhone
FROM tblSMCompanySetup WITH (NOLOCK)
ORDER BY intCompanySetupID DESC

--TEMP TABLES
CREATE TABLE #CUSTOMERS (
	  intEntityCustomerId		INT NOT NULL PRIMARY KEY	  
    , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strCustomerName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFormat        NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strFullAddress			NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	, strStatementFooterComment	NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, strComment				NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
	, dblCreditLimit			NUMERIC(18,6) NULL DEFAULT 0	
	, dblARBalance				NUMERIC(18,6) NULL DEFAULT 0
	, ysnStatementCreditLimit	BIT NULL
)
CREATE TABLE #GLACCOUNTS (intAccountId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE #LOCATIONS (
	  intCompanyLocationId		INT NOT NULL PRIMARY KEY
	, strLocationName			NVARCHAR(200) COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE #STATEMENTTABLE (
	  intTempId						INT IDENTITY(1,1)		
	, strReferenceNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, strTransactionType			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, intEntityCustomerId			INT NOT NULL
	, dtmDueDate					DATETIME NULL
	, dtmDate						DATETIME NULL
	, intDaysDue					INT NULL DEFAULT 0
	, dblTotalAmount				NUMERIC(18,6) NULL DEFAULT 0
	, dblAmountPaid					NUMERIC(18,6) NULL DEFAULT 0
	, dblAmountDue					NUMERIC(18,6) NULL DEFAULT 0
	, dblPastDue					NUMERIC(18,6) NULL DEFAULT 0
	, dblMonthlyBudget				NUMERIC(18,6) NULL DEFAULT 0
	, dblRunningBalance				NUMERIC(18,6) NULL DEFAULT 0
	, strCustomerNumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strDisplayName				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, strName						NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, strBOLNumber					NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, dblCreditLimit				NUMERIC(18,6) NULL DEFAULT 0
	, strTicketNumbers				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strLocationName				NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
	, strFullAddress				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, strStatementFooterComment		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL
	, dblARBalance					NUMERIC(18,6) NULL DEFAULT 0
	, strComment					NVARCHAR(500) COLLATE Latin1_General_CI_AS	NULL
) 
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTTABLE_OPENITEM_A1] ON [#STATEMENTTABLE]([intEntityCustomerId], [strTransactionType])
CREATE TABLE #CFTABLE (
	  intInvoiceId				INT NOT NULL PRIMARY KEY
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strInvoiceReportNumber	NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, dtmInvoiceDate			DATETIME NULL
)
CREATE TABLE #INVOICES (
	  intEntityCustomerId		INT NULL
	, intInvoiceId				INT NOT NULL PRIMARY KEY
	, intCompanyLocationId		INT NOT NULL
	, intDaysDue				INT NULL DEFAULT 0
	, strTransactionType		NVARCHAR(25) COLLATE Latin1_General_CI_AS   NOT	NULL
	, strType					NVARCHAR(25) COLLATE Latin1_General_CI_AS   NULL DEFAULT 'Standard' 
	, strInvoiceNumber			NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, strBOLNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, dblInvoiceTotal			NUMERIC(18, 6)	NULL DEFAULT 0
	, dblMonthlyBudget			NUMERIC(18, 6)	NULL DEFAULT 0
	, dtmDate					DATETIME NOT NULL
	, dtmPostDate				DATETIME NOT NULL
	, dtmDueDate				DATETIME NULL
	, ysnImportedFromOrigin		BIT NULL
	, ysnPastDue				BIT NULL
	, strLocationName			NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	, strTicketNumbers			NVARCHAR(500) COLLATE Latin1_General_CI_AS  NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#STATEMENTINVOICE_OPENITEM_A1] ON [#INVOICES]([intEntityCustomerId])
CREATE TABLE #PAYMENTS (
	  intPaymentId			INT NOT NULL PRIMARY KEY
	, strPaymentMethod		NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL
)

--FILTER CUSTOMERS
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId    	= C.intEntityId 
				   , strCustomerNumber      	= C.strCustomerNumber
				   , strCustomerName        	= EC.strName
				   , strStatementFormat			= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
				   , dblCreditLimit         	= C.dblCreditLimit
				   , dblARBalance           	= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE strEntityNo = @strCustomerNumberLocal
		  AND ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 OR C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		SELECT DISTINCT intEntityCustomerId = intID
		INTO #ADCUSTOMERS
		FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)

		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
		     , strCustomerNumber    	= C.strCustomerNumber
		     , strCustomerName      	= EC.strName
		     , strStatementFormat		= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
		     , dblCreditLimit       	= C.dblCreditLimit
		     , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN #ADCUSTOMERS CUSTOMERS ON C.intEntityId = CUSTOMERS.intEntityCustomerId
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 OR C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
		  AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN tblEMEntity EC WITH (NOLOCK) ON C.intEntityId = EC.intEntityId
		WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		  AND ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 OR C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
		  AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
END

--FILTER CUSTOMERS BY STATUS CODE
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

--FILTER CUSTOMERS BY EMAIL SETUP
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

SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

--FILTER LOCATIONS
INSERT INTO #LOCATIONS
SELECT intCompanyLocationId
	 , strLocationName
FROM tblSMCompanyLocation

IF @strLocationNameLocal IS NOT NULL
	BEGIN 
		DELETE FROM #LOCATIONS WHERE strLocationName <> @strLocationName

		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM #LOCATIONS
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

--CUSTOMER ADDRESS
UPDATE C
SET strFullAddress		= CASE WHEN C.strStatementFormat <> 'Running Balance' THEN EL.strLocationName ELSE '' END + CHAR(13) + CHAR(10) + EL.strAddress + CHAR(13) + char(10) + EL.strCity + ', ' + EL.strState + ', ' + EL.strZipCode + ', ' + EL.strCountry 
  , strCustomerName		= CASE WHEN C.strStatementFormat <> 'Running Balance' THEN C.strCustomerName ELSE ISNULL(NULLIF(EL.strCheckPayeeName, ''), C.strCustomerName) END
FROM #CUSTOMERS C
INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityCustomerId AND EL.ysnDefaultLocation = 1

--CUSTOMER FOOTERCOMMENT
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
	ORDER BY M.intDocumentMaintenanceId DESC
		   , intEntityCustomerId DESC
) FOOTER

--CUSTOMER STATEMENT COMMENT
UPDATE C
SET strComment = strMessage
FROM #CUSTOMERS C
INNER JOIN tblEMEntityMessage EM ON C.intEntityCustomerId = EM.intEntityId
WHERE strMessageType = 'Statement'

--GL ACCOUNTS
INSERT INTO #GLACCOUNTS
SELECT DISTINCT intAccountId
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

--#INVOICES
INSERT INTO #INVOICES WITH (TABLOCK) (
	  intEntityCustomerId
	, intInvoiceId
	, intCompanyLocationId
	, intDaysDue
	, strTransactionType
	, strType
	, strInvoiceNumber
	, strBOLNumber
	, dblInvoiceTotal
	, dtmDate
	, dtmPostDate
	, dtmDueDate
	, ysnImportedFromOrigin
	, ysnPastDue
	, strLocationName
)
SELECT intEntityCustomerId		= I.intEntityCustomerId
	, intInvoiceId				= I.intInvoiceId
	, intCompanyLocationId		= L.intCompanyLocationId
	, intDaysDue				= DATEDIFF(DAY, I.dtmDueDate, @dtmDateToLocal)
	, strTransactionType		= CASE WHEN I.strType = 'Service Charge' THEN 'Service Charge' ELSE I.strTransactionType END
	, strType					= I.strType
	, strInvoiceNumber			= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
	, strBOLNumber				= I.strBOLNumber
	, dblInvoiceTotal			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
	, dtmDate					= I.dtmDate
	, dtmPostDate				= I.dtmPostDate
	, dtmDueDate				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo') THEN NULL ELSE I.dtmDueDate END
	, ysnImportedFromOrigin		= I.ysnImportedFromOrigin
	, ysnPastDue				= CASE WHEN @dtmDateToLocal > I.dtmDueDate AND I.strTransactionType IN ('Invoice', 'Debit Memo') THEN 1 ELSE 0 END
	, strLocationName			= L.strLocationName
FROM tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
INNER JOIN #LOCATIONS L ON I.intCompanyLocationId = L.intCompanyLocationId
WHERE ysnPosted  = 1        
  AND ysnCancelled = 0      
  AND ((I.strType = 'Service Charge' AND ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND ysnForgiven = 0)))      
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

--MONTHLY BUDGET
UPDATE I
SET dblMonthlyBudget = dblBudgetAmount
FROM #INVOICES I
INNER JOIN tblARCustomerBudget CB ON I.intEntityCustomerId = CB.intEntityCustomerId
WHERE I.dtmDate BETWEEN CB.dtmBudgetDate AND DATEADD(MONTH, 1, CB.dtmBudgetDate)

--#PAYMENTS
INSERT INTO #PAYMENTS WITH (TABLOCK) (
	  intPaymentId
	, strPaymentMethod
)
SELECT intPaymentId		= P.intPaymentId
	 , strPaymentMethod	= UPPER(SM.strPaymentMethod)
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON C.intEntityCustomerId = P.intEntityCustomerId
INNER JOIN tblSMPaymentMethod SM ON P.intPaymentMethodId = SM.intPaymentMethodID
WHERE ysnPosted = 1
  AND ysnInvoicePrepayment = 0
  AND ysnProcessedToNSF = 0
  AND dtmDatePaid <= @dtmDateToLocal

--WRITE OFF	
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		DELETE P
		FROM #PAYMENTS P
		WHERE strPaymentMethod = 'WRITE OFF'
	END

--AGING REPORT
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateFrom				= @dtmDateFromLocal
										  , @dtmDateTo					= @dtmDateToLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal

--MAIN STATEMENT
SET @query = CAST('' AS NVARCHAR(MAX)) + '
INSERT INTO #STATEMENTTABLE WITH (TABLOCK) (
	   strReferenceNumber
	 , strTransactionType
	 , intEntityCustomerId
	 , dtmDueDate
	 , dtmDate
	 , intDaysDue
	 , dblTotalAmount
	 , dblAmountPaid
	 , dblAmountDue
	 , dblPastDue
	 , dblMonthlyBudget
	 , dblRunningBalance
	 , strCustomerNumber
	 , strDisplayName
	 , strName
	 , strBOLNumber
	 , dblCreditLimit
	 , strTicketNumbers
	 , strLocationName
	 , strFullAddress
	 , strStatementFooterComment
	 , dblARBalance
	 , strComment
)
SELECT strReferenceNumber			= I.strInvoiceNumber
	 , strTransactionType			= I.strTransactionType
	 , intEntityCustomerId			= C.intEntityCustomerId     
	 , dtmDueDate					= I.dtmDueDate
	 , dtmDate						= I.dtmDate     
	 , intDaysDue					= I.intDaysDue
	 , dblTotalAmount				= I.dblInvoiceTotal
	 , dblAmountPaid				= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END     
	 , dblAmountDue					= I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)     
	 , dblPastDue					= CASE WHEN I.ysnPastDue = 1 THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) ELSE 0 END     
	 , dblMonthlyBudget				= I.dblMonthlyBudget   
	 , dblRunningBalance			= SUM(CASE WHEN I.strType = ''CF Tran'' THEN 0 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)) OVER (PARTITION BY I.intEntityCustomerId' + ISNULL(@queryRunningBalance, '') +')
	 , strCustomerNumber			= C.strCustomerNumber     
	 , strDisplayName				= C.strCustomerName
	 , strName						= C.strCustomerName
	 , strBOLNumber					= I.strBOLNumber
	 , dblCreditLimit				= C.dblCreditLimit
	 , strTicketNumbers				= I.strTicketNumbers
	 , strLocationName				= I.strLocationName
	 , strFullAddress				= C.strFullAddress
	 , strStatementFooterComment	= C.strStatementFooterComment     
	 , dblARBalance					= C.dblARBalance 
	 , strComment					= C.strComment
FROM #CUSTOMERS C
INNER JOIN #INVOICES I ON I.intEntityCustomerId = C.intEntityCustomerId     
LEFT JOIN (    
	SELECT dblPayment	= SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)      
		 , intInvoiceId	= PD.intInvoiceId    
	FROM tblARPaymentDetail PD WITH (NOLOCK)     
	INNER JOIN #PAYMENTS P ON PD.intPaymentId = P.intPaymentId    
	GROUP BY intInvoiceId   
) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId   
LEFT JOIN (    
	SELECT intPrepaymentId      
		 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)    
	FROM tblARPrepaidAndCredit WITH (NOLOCK)    
	WHERE ysnApplied = 1    
	GROUP BY intPrepaymentId   
) PC ON I.intInvoiceId = PC.intPrepaymentId   
WHERE I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0'

EXEC sp_executesql @query

--BUDGET STATEMENT
IF @ysnIncludeBudgetLocal = 1
	BEGIN
		INSERT INTO #STATEMENTTABLE WITH (TABLOCK) (
			  strReferenceNumber
			, strTransactionType
			, intEntityCustomerId
			, dtmDueDate
			, dtmDate
			, intDaysDue
			, dblTotalAmount
			, dblAmountPaid
			, dblMonthlyBudget
			, strCustomerNumber
			, strDisplayName
			, strName
			, dblCreditLimit
			, strFullAddress
			, strStatementFooterComment
			, dblARBalance
		)
		SELECT strReferenceNumber		= 'Budget due for: ' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
			, strTransactionType		= 'Customer Budget'
			, intEntityCustomerId		= C.intEntityCustomerId
			, dtmDueDate				= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
			, dtmDate					= dtmBudgetDate
			, intDaysDue				= DATEDIFF(DAY, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal)
			, dblTotalAmount			= dblBudgetAmount
			, dblAmountPaid				= dblAmountPaid
			, dblMonthlyBudget			= dblBudgetAmount
			, strCustomerNumber			= C.strCustomerNumber
			, strDisplayName			= C.strCustomerName
			, strName					= C.strCustomerName
			, dblCreditLimit			= C.dblCreditLimit
			, strFullAddress			= C.strFullAddress
			, strStatementFooterComment	= C.strStatementFooterComment
			, dblARBalance				= C.dblARBalance
		FROM tblARCustomerBudget CB
		INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId	
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

IF @ysnPrintOnlyPastDueLocal = 1
	BEGIN
		DELETE FROM #STATEMENTTABLE WHERE strTransactionType = 'Invoice' AND dblPastDue <= 0

		UPDATE tblARCustomerAgingStagingTable
		SET dbl0Days = 0
		WHERE intEntityUserId = @intEntityUserIdLocal
		  AND strAgingType = 'Summary'
	END

SELECT @dblTotalAR = SUM(dblTotalAR) 
FROM tblARCustomerAgingStagingTable 
WHERE intEntityUserId = @intEntityUserIdLocal 
  AND strAgingType = 'Summary'

IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		IF @dblTotalAR = 0 
		BEGIN
			DELETE FROM #STATEMENTTABLE WHERE ((((ABS(dblAmountDue) * 10000) - CONVERT(FLOAT, (ABS(dblAmountDue) * 10000))) <> 0) OR dblAmountDue <= 0) AND strTransactionType <> 'Customer Budget'
			DELETE FROM tblARCustomerAgingStagingTable WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR dblTotalAR <= 0) AND intEntityUserId = @intEntityUserIdLocal AND strAgingType = 'Summary'

			DELETE FROM #CUSTOMERS 
			WHERE intEntityCustomerId NOT IN (
				SELECT DISTINCT intEntityCustomerId 
				FROM tblARCustomerAgingStagingTable 
				WHERE intEntityUserId = @intEntityUserIdLocal 
					AND strAgingType = 'Summary'
			)
		END
	END

INSERT INTO #CFTABLE (
	  intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT cfTable.intInvoiceId
	 , cfTable.strInvoiceNumber
	 , cfTable.strInvoiceReportNumber
	 , cfTable.dtmInvoiceDate
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
		WHERE ISNULL(strInvoiceReportNumber,'') <> ''
	) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
) cfTable ON statementTable.strReferenceNumber = cfTable.strInvoiceNumber

DELETE FROM #STATEMENTTABLE
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblAmountDue, 0))
FROM #STATEMENTTABLE GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

IF (@@version LIKE '%2008%')
BEGIN
    UPDATE STATEMENTREPORT
    SET dblRunningBalance = STATEMENTREPORT2.dblRunningBalance
    FROM #STATEMENTTABLE STATEMENTREPORT
    INNER JOIN (
        SELECT STATEMENTREPORT.intTempId
			 , SUM(STATEMENTREPORT2.dblRunningBalance) [dblRunningBalance]
        FROM #STATEMENTTABLE AS STATEMENTREPORT
        INNER JOIN #STATEMENTTABLE AS STATEMENTREPORT2 ON STATEMENTREPORT2.intTempId <= STATEMENTREPORT.intTempId
        WHERE STATEMENTREPORT.strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM #CFTABLE)
        GROUP BY STATEMENTREPORT.intTempId
    ) STATEMENTREPORT2 ON STATEMENTREPORT2.intTempId = STATEMENTREPORT.intTempId;
END;

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = @strStatementFormatLocal
INSERT INTO tblARCustomerStatementStagingTable WITH (TABLOCK) (
	  strReferenceNumber
	, intEntityCustomerId
	, strTransactionType
	, dtmDueDate
	, dtmDate
	, intDaysDue
	, dblTotalAmount
	, dblAmountPaid
	, dblAmountDue
	, dblPastDue
	, dblMonthlyBudget
	, dblRunningBalance
	, strCustomerNumber
	, strDisplayName
	, strCustomerName
	, strBOLNumber
	, dblCreditLimit
	, strFullAddress
	, strStatementFooterComment
	, strTicketNumbers
	, strComment
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
)
SELECT MAINREPORT.* 
	 , dblCreditAvailable	= CASE WHEN (MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture			= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days				= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days			= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days			= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days			= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days			= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days			= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits			= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments		= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , dtmAsOfDate			= @dtmDateToLocal
	 , intEntityUserId		= @intEntityUserIdLocal
	 , strStatementFormat	= @strStatementFormatLocal
	 , ysnStatementCreditLimit	= CUSTOMER.ysnStatementCreditLimit
FROM (
	SELECT STATEMENTREPORT.strReferenceNumber
		 , STATEMENTREPORT.intEntityCustomerId
		 , STATEMENTREPORT.strTransactionType
		 , STATEMENTREPORT.dtmDueDate
		 , STATEMENTREPORT.dtmDate
		 , STATEMENTREPORT.intDaysDue
		 , STATEMENTREPORT.dblTotalAmount
		 , STATEMENTREPORT.dblAmountPaid
		 , STATEMENTREPORT.dblAmountDue
		 , STATEMENTREPORT.dblPastDue
		 , STATEMENTREPORT.dblMonthlyBudget
		 , STATEMENTREPORT.dblRunningBalance
		 , STATEMENTREPORT.strCustomerNumber
		 , STATEMENTREPORT.strDisplayName
		 , STATEMENTREPORT.strName
		 , STATEMENTREPORT.strBOLNumber
		 , STATEMENTREPORT.dblCreditLimit	  
		 , STATEMENTREPORT.strFullAddress
		 , STATEMENTREPORT.strStatementFooterComment	  
		 , STATEMENTREPORT.strTicketNumbers
		 , STATEMENTREPORT.strComment
	FROM #STATEMENTTABLE AS STATEMENTREPORT
	WHERE strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM #CFTABLE)

	UNION ALL

	--- With CF Report
	SELECT strReferenceNumber						= CFReportTable.strInvoiceReportNumber
		 , STATEMENTREPORT.intEntityCustomerId
		 , STATEMENTREPORT.strTransactionType
		 , dtmDueDate								= CFReportTable.dtmInvoiceDate
		 , dtmDate									= CFReportTable.dtmInvoiceDate
		 , intDaysDue								= (SELECT TOP 1 intDaysDue FROM #STATEMENTTABLE ORDER BY intDaysDue DESC)
		 , dblTotalAmount							= SUM(STATEMENTREPORT.dblTotalAmount)
		 , dblAmountPaid							= SUM(STATEMENTREPORT.dblAmountPaid)
		 , dblAmountDue								= SUM(STATEMENTREPORT.dblAmountDue)
		 , dblPastDue								= SUM(STATEMENTREPORT.dblPastDue)
		 , dblMonthlyBudget							= SUM(STATEMENTREPORT.dblMonthlyBudget)
		 , dblRunningBalance						= SUM(STATEMENTREPORT.dblRunningBalance)
		 , STATEMENTREPORT.strCustomerNumber
		 , STATEMENTREPORT.strDisplayName
		 , STATEMENTREPORT.strName
		 , STATEMENTREPORT.strBOLNumber
		 , STATEMENTREPORT.dblCreditLimit	  
		 , STATEMENTREPORT.strFullAddress
		 , STATEMENTREPORT.strStatementFooterComment	  
		 , STATEMENTREPORT.strTicketNumbers
		 , STATEMENTREPORT.strComment
	FROM #STATEMENTTABLE AS STATEMENTREPORT
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM #CFTABLE
	) CFReportTable ON STATEMENTREPORT.strReferenceNumber = CFReportTable.strInvoiceNumber
	GROUP BY CFReportTable.strInvoiceReportNumber
			, CFReportTable.dtmInvoiceDate
			, STATEMENTREPORT.strTransactionType	  
			, STATEMENTREPORT.strCustomerNumber
			, STATEMENTREPORT.strDisplayName
			, STATEMENTREPORT.strName
			, STATEMENTREPORT.strBOLNumber
			, STATEMENTREPORT.dblCreditLimit	  
			, STATEMENTREPORT.strFullAddress
			, STATEMENTREPORT.strStatementFooterComment
			, STATEMENTREPORT.intEntityCustomerId
			, STATEMENTREPORT.strTicketNumbers
			, STATEMENTREPORT.strComment
) MAINREPORT
LEFT JOIN tblARCustomerAgingStagingTable AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	AND AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
	AND AGINGREPORT.strAgingType = 'Summary'
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId

UPDATE tblARCustomerStatementStagingTable
SET strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
  , ysnStretchLogo 		= ISNULL(@ysnStretchLogo, 0)
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strStatementFormat = @strStatementFormatLocal

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = @strStatementFormatLocal
		  AND intEntityCustomerId IN (
			  SELECT DISTINCT intEntityCustomerId
			  FROM tblARCustomerAgingStagingTable AGINGREPORT
			  WHERE AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
				AND AGINGREPORT.strAgingType = 'Summary'
				AND (AGINGREPORT.dblTotalAR IS NULL OR AGINGREPORT.dblTotalAR < 0)
		  )
	END