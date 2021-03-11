CREATE PROCEDURE [dbo].[uspARCustomerStatementHonsteinReport]
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
	, @strStatementFormat			AS NVARCHAR(MAX)	= 'Honstein Oil'
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @intEntityUserId				AS INT				= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	  , @strStatementFormatLocal			AS NVARCHAR(MAX)	= 'Honstein Oil'
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @strFinalQuery						AS NVARCHAR(MAX)	  
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= ''	  
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @ysnStretchLogo						AS BIT				= 0
	  , @blbLogo							AS VARBINARY(MAX)	= NULL
	  , @blbStretchedLogo					AS VARBINARY(MAX)	= NULL
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

IF(OBJECT_ID('tempdb..#WRITEOFFSPAYMENTMETHODS') IS NOT NULL)
BEGIN
	DROP TABLE #WRITEOFFSPAYMENTMETHODS
END

IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
BEGIN
	DROP TABLE #COMPANYLOCATIONS
END

IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
BEGIN
	DROP TABLE #INVOICES
END

IF(OBJECT_ID('tempdb..#PAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #PAYMENTS
END

IF(OBJECT_ID('tempdb..#INVOICEPAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #INVOICEPAYMENTS
END

IF(OBJECT_ID('tempdb..#STATEMENTREPORT') IS NOT NULL)
BEGIN
	DROP TABLE #STATEMENTREPORT
END

IF(OBJECT_ID('tempdb..#AGINGSUMMARY') IS NOT NULL)
BEGIN
	DROP TABLE #AGINGSUMMARY
END

SELECT intEntityCustomerId			= intEntityId
	 , strCustomerNumber			= CAST(strCustomerNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strCustomerName				= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strStatementFormat			= CAST(strStatementFormat COLLATE Latin1_General_CI_AS AS NVARCHAR(100))
	 , strFullAddress				= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(MAX))
	 , strStatementFooterComment	= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(MAX))
	 , strCheckPayeeName			= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(MAX))
	 , dblCreditLimit				= dblCreditLimit
	 , dblARBalance					= dblARBalance
	 , ysnStatementCreditLimit		= ISNULL(ysnStatementCreditLimit, CAST(0 AS BIT))
INTO #CUSTOMERS
FROM tblARCustomer
WHERE 1 = 0

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

--VERSION COMPATIBILITY
IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY STATEMENTREPORT.dtmDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'		
	END

--GET COMPANY LOGO
SELECT TOP 1 @ysnStretchLogo = ysnStretchLogo FROM tblARCompanyPreference WITH (NOLOCK)
SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')
SELECT @blbStretchedLogo = dbo.fnSMGetCompanyLogo('Stretched Header')

--GET COMPANY DETAILS
SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

--FILTER CUSTOMERS
IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId    	= C.intEntityId 
				   , strCustomerNumber      	= C.strCustomerNumber
				   , strCustomerName        	= EC.strName
				   , strStatementFormat			= 'Honstein Oil'
				   , dblCreditLimit         	= C.dblCreditLimit
				   , dblARBalance           	= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  	AND C.strStatementFormat = 'Honstein Oil'
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
		     , strCustomerNumber    	= C.strCustomerNumber
		     , strCustomerName      	= EC.strName
		     , strStatementFormat		= 'Honstein Oil'
		     , dblCreditLimit       	= C.dblCreditLimit
		     , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)			
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Honstein Oil'
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= 'Honstein Oil'
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND C.strStatementFormat = 'Honstein Oil'
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
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = C.intEntityCustomerId 
				AND ISNULL(CC.strEmail, '') <> '' 
				AND CC.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

--GET WRITE OFF PAYMENT METHODS
SELECT intPaymentMethodID
INTO #WRITEOFFSPAYMENTMETHODS 
FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
WHERE UPPER(strPaymentMethod) LIKE '%WRITE OFF%'

--GET COMPANY LOCATIONS
SELECT intCompanyLocationId
     , strLocationName
INTO #COMPANYLOCATIONS 
FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
WHERE @strLocationNameLocal IS NULL OR @strLocationNameLocal = strLocationName

IF @strLocationNameLocal IS NOT NULL
	BEGIN
		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM #COMPANYLOCATIONS
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

--GET PAYMENTS
SELECT intPaymentId
	 , intPaymentMethodId
	 , strRecordNumber
	 , strPaymentMethod
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
INTO #PAYMENTS
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON P.intLocationId = CL.intCompanyLocationId
WHERE P.ysnPosted = 1
  AND ISNULL(P.ysnProcessedToNSF, 0) = 0
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal

--FILTER OUT WRITE OFF PAYMENTS
IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		DELETE P
		FROM #PAYMENTS P
		LEFT JOIN #WRITEOFFSPAYMENTMETHODS WO ON P.intPaymentMethodId = WO.intPaymentMethodID
		WHERE WO.intPaymentMethodID IS NOT NULL
	END

--GET INVOICE PAYMENT TOTALS
SELECT intInvoiceId	= PD.intInvoiceId
	 , dblPayment	= SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)
INTO #INVOICEPAYMENTS
FROM tblARPaymentDetail PD
INNER JOIN #PAYMENTS P ON PD.intPaymentId = P.intPaymentId
WHERE ISNULL(P.ysnInvoicePrepayment, 0) = 0
GROUP BY PD.intInvoiceId

--AGING REPORT
EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateTo					= @dtmDateToLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  

SELECT *
INTO #AGINGSUMMARY
FROM dbo.tblARCustomerAgingStagingTable
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strAgingType = 'Summary'

--UPDATE CUSTOMER ADDRESS
UPDATE C
SET strFullAddress				= dbo.fnARFormatCustomerAddress(NULL, NULL, CASE WHEN C.strStatementFormat <> 'Running Balance' THEN CS.strBillToLocationName ELSE NULL END, CS.strBillToAddress, CS.strBillToCity, CS.strBillToState, CS.strBillToZipCode, CS.strBillToCountry, NULL, NULL)
  , strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, C.intEntityCustomerId, 'Statement Report', NULL, 'Footer', NULL, 1)
  , strCheckPayeeName			= CS.strCheckPayeeName
FROM #CUSTOMERS C
INNER JOIN vyuARCustomerSearch CS ON C.intEntityCustomerId = CS.intEntityCustomerId

--GET INVOICES
SELECT intEntityCustomerId		= I.intEntityCustomerId
	 , intInvoiceId				= I.intInvoiceId
	 , intTermId				= I.intTermId
	 , intCompanyLocationId		= I.intCompanyLocationId
	 , strTransactionType		= I.strTransactionType
	 , strType					= I.strType
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strInvoiceOriginId		= I.strInvoiceOriginId
	 , strBOLNumber				= I.strBOLNumber
	 , dblInvoiceTotal			= I.dblInvoiceTotal
	 , dtmDate					= I.dtmDate
	 , dtmPostDate				= I.dtmPostDate
	 , dtmDueDate				= I.dtmDueDate
	 , ysnImportedFromOrigin	= I.ysnImportedFromOrigin
	 , strLocationName			= CL.strLocationName
	 , strPONumber				= I.strPONumber
INTO #INVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN #CUSTOMERS C ON C.intEntityCustomerId = I.intEntityCustomerId
INNER JOIN #COMPANYLOCATIONS CL ON CL.intCompanyLocationId = I.intCompanyLocationId
WHERE I.ysnPosted  = 1		
  AND I.ysnCancelled = 0
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= @dtmDateToLocal
  AND I.intAccountId IN (SELECT intAccountId FROM dbo.vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

--MAIN STATEMENT
SELECT strReferenceNumber			= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
	 , strTransactionType			= CASE WHEN I.strType = 'Service Charge' THEN 'Service Charge'
	 									   WHEN I.strTransactionType = 'Customer Prepayment' THEN 'Prepayment' 
	 									   ELSE I.strTransactionType 
									  END
	 , strPONumber					= I.strPONumber
	 , intEntityCustomerId			= C.intEntityCustomerId
	 , dtmDueDate					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Credit Memo', 'Debit Memo') THEN NULL ELSE I.dtmDueDate END
	 , dtmDate						= I.dtmDate
	 , intDaysDue					= DATEDIFF(DAY, I.[dtmDueDate], @dtmDateToLocal)
	 , dblTotalAmount				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid				= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END
	 , dblAmountDue					= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 , dblPastDue					= CASE WHEN @dtmDateToLocal > I.[dtmDueDate] AND I.strTransactionType IN ('Invoice', 'Debit Memo')
	 										THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)
	 									ELSE 0
	 								END
	 , strCustomerNumber			= C.strCustomerNumber
	 , strDisplayName				= CASE WHEN @strStatementFormat <> 'Running Balance' THEN C.strCustomerName ELSE ISNULL(NULLIF(C.strCheckPayeeName, ''), C.strCustomerName) END
	 , strName						= C.strCustomerName
	 , strBOLNumber					= I.strBOLNumber
	 , dblCreditLimit				= C.dblCreditLimit		 
	 , strLocationName				= I.strLocationName
	 , strFullAddress				= C.strFullAddress 
	 , strStatementFooterComment	= C.strStatementFooterComment
	 --, dblARBalance					= C.dblARBalance
	 , dtmAsOfDate					= @dtmDateToLocal
	 , intEntityUserId				= @intEntityUserIdLocal
	 , strStatementFormat			= @strStatementFormatLocal
INTO #STATEMENTREPORT
FROM #CUSTOMERS C WITH (NOLOCK)
LEFT JOIN #INVOICES I ON C.intEntityCustomerId = I.intEntityCustomerId
LEFT JOIN #INVOICEPAYMENTS TOTALPAYMENT ON TOTALPAYMENT.intInvoiceId = I.intInvoiceId

--FILTER OUT PAST DUE 
IF @ysnPrintOnlyPastDueLocal = 1
	BEGIN
		DELETE FROM #STATEMENTREPORT WHERE strTransactionType = 'Invoice' AND dblPastDue <= 0
		UPDATE #AGINGSUMMARY SET dbl0Days = 0
	END

--FILTER OUT ZERO BALANCE
IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		DELETE FROM #STATEMENTREPORT WHERE ((((ABS(dblAmountDue) * 10000) - CONVERT(FLOAT, (ABS(dblAmountDue) * 10000))) <> 0) OR ISNULL(dblAmountDue, 0) = 0) AND strTransactionType <> 'Customer Budget'
		DELETE FROM #AGINGSUMMARY WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) = 0)

		DELETE C
		FROM #CUSTOMERS C
		LEFT JOIN (
			SELECT DISTINCT intEntityCustomerId 
			FROM #AGINGSUMMARY 
		) AGING ON AGING.intEntityCustomerId = C.intEntityCustomerId
		WHERE AGING.intEntityCustomerId IS NULL					
	END

DELETE FROM #STATEMENTREPORT
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

--UPDATE STATEMENT DATE GENERATED
MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblAmountDue, 0))
FROM #STATEMENTREPORT GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber
WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement
WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = @strStatementFormatLocal

SET @strFinalQuery = CAST('' AS NVARCHAR(MAX)) + '
INSERT INTO tblARCustomerStatementStagingTable (
	   strReferenceNumber
	 , strTransactionType
	 , strPONumber
	 , intEntityCustomerId
	 , dtmDueDate
	 , dtmDate
	 , intDaysDue
	 , dblTotalAmount
	 , dblAmountPaid
	 , dblAmountDue
	 , dblPastDue
	 , strCustomerNumber
	 , strDisplayName
	 , strCustomerName
	 , strBOLNumber
	 , dblCreditLimit
	 , strLocationName
	 , strFullAddress
	 , strStatementFooterComment
	 , dtmAsOfDate
	 , intEntityUserId
	 , strStatementFormat
	 , dblRunningBalance
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
)
SELECT STATEMENTREPORT.* 
	 , dblRunningBalance		= SUM(STATEMENTREPORT.dblAmountDue) OVER (PARTITION BY STATEMENTREPORT.intEntityCustomerId' + ISNULL(@queryRunningBalance, '') + ')
	 , dblCreditAvailable		= CASE WHEN (STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE STATEMENTREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture				= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days					= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days				= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days				= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days				= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days				= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days				= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits				= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments			= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , ysnStatementCreditLimit	= CUSTOMER.ysnStatementCreditLimit
FROM #STATEMENTREPORT STATEMENTREPORT
INNER JOIN #CUSTOMERS CUSTOMER ON STATEMENTREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN #AGINGSUMMARY AGINGREPORT ON STATEMENTREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId'

EXEC sp_executesql @strFinalQuery

UPDATE tblARCustomerStatementStagingTable
SET strComment			= dbo.fnEMEntityMessage(intEntityCustomerId, 'Statement')
  , blbLogo				= CASE WHEN ISNULL(@ysnStretchLogo, 0) = 1 THEN ISNULL(@blbStretchedLogo, @blbLogo) ELSE @blbLogo END
  , strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
  , ysnStretchLogo 		= ISNULL(@ysnStretchLogo, 0)
WHERE intEntityUserId = @intEntityUserIdLocal
  AND strStatementFormat = 'Honstein Oil'

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = 'Honstein Oil'
		  AND intEntityCustomerId IN (
			  SELECT DISTINCT intEntityCustomerId
			  FROM #AGINGSUMMARY AGINGREPORT
			  WHERE ISNULL(AGINGREPORT.dblTotalAR, 0) < 0
		  )
	END