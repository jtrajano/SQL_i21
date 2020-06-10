CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	  @dtmDateFrom					DATETIME = NULL
	, @dtmDateTo					DATETIME = NULL
	, @dtmBalanceForwardDate		DATETIME = NULL
	, @intEntityUserId				INT = NULL
	, @strSourceTransaction			NVARCHAR(100) = NULL
	, @strCustomerIds				NVARCHAR(MAX) = NULL
	, @strSalespersonIds			NVARCHAR(MAX) = NULL
	, @strCompanyLocationIds		NVARCHAR(MAX) = NULL
	, @strAccountStatusIds			NVARCHAR(MAX) = NULL
	, @strUserId					NVARCHAR(MAX) = NULL
	, @ysnIncludeCredits			BIT = 1
	, @ysnIncludeWriteOffPayment	BIT = 0
	, @ysnFromBalanceForward		BIT = 0
	, @ysnPrintFromCF				BIT = 0
	, @ysnExcludeAccountStatus		BIT = 0
AS

DECLARE @dtmDateFromLocal				DATETIME		= NULL,
	    @dtmDateToLocal					DATETIME		= NULL,
		@intEntityUserIdLocal			INT				= NULL,
		@strSourceTransactionLocal		NVARCHAR(100)	= NULL,		
		@strCustomerIdsLocal			NVARCHAR(MAX)	= NULL,
		@strSalespersonIdsLocal			NVARCHAR(MAX)	= NULL,
		@strCompanyLocationIdsLocal		NVARCHAR(MAX)	= NULL,
		@strAccountStatusIdsLocal		NVARCHAR(MAX)	= NULL,
		@strCompanyName					NVARCHAR(100)	= NULL,
		@strCompanyAddress				NVARCHAR(500)	= NULL,
		@ysnIncludeCreditsLocal			BIT				= 1,
		@ysnIncludeWriteOffPaymentLocal BIT				= 1,
		@ysnPrintFromCFLocal			BIT				= 0

DECLARE @tblSalesperson TABLE (intSalespersonId INT)
DECLARE @tblCompanyLocation TABLE (intCompanyLocationId INT)
DECLARE @tblAccountStatus TABLE (intAccountStatusId INT, intEntityCustomerId INT)
DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
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
SET @strAccountStatusIdsLocal		= NULLIF(@strAccountStatusIds, '')

SET @dtmDateFromLocal				= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateFromLocal)))
SET @dtmDateToLocal					= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDateToLocal)))

SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

--CUSTOMER FILTER
IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO @tblCustomers
		SELECT C.intEntityId 
		     , C.strCustomerNumber
		     , EC.strName
		     , C.dblCreditLimit
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
	END
ELSE
	BEGIN
		INSERT INTO @tblCustomers
		SELECT C.intEntityId 
			 , C.strCustomerNumber
			 , EC.strName
			 , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
		) EC ON C.intEntityId = EC.intEntityId
	END

--COMPANY LOCATION FILTER
IF ISNULL(@strCompanyLocationIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @tblCompanyLocation
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCompanyLocationIdsLocal)
		) COMPANYLOCATION ON CL.intCompanyLocationId = COMPANYLOCATION.intID
	END
ELSE
	BEGIN
		INSERT INTO @tblCompanyLocation
		SELECT CL.intCompanyLocationId
		FROM dbo.tblSMCompanyLocation CL WITH (NOLOCK) 
	END

--ACCOUNT STATUS FILTER
IF ISNULL(@strAccountStatusIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @tblAccountStatus (
			  intAccountStatusId
			, intEntityCustomerId
		)
		SELECT intAccountStatusId	= ACCS.intAccountStatusId
			 , intEntityCustomerId	= CAS.intEntityCustomerId
		FROM dbo.tblARAccountStatus ACCS WITH (NOLOCK) 
		INNER JOIN tblARCustomerAccountStatus CAS ON ACCS.intAccountStatusId = CAS.intAccountStatusId
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strAccountStatusIdsLocal)
		) ACCOUNTSTATUS ON ACCS.intAccountStatusId = ACCOUNTSTATUS.intID

		IF ISNULL(@ysnExcludeAccountStatus, 0) = 0
			BEGIN
				DELETE CUSTOMERS 
				FROM @tblCustomers CUSTOMERS
				LEFT JOIN @tblAccountStatus ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NULL
			END
		ELSE 
			BEGIN
				DELETE CUSTOMERS 
				FROM @tblCustomers CUSTOMERS
				INNER JOIN @tblAccountStatus ACCSTATUS ON CUSTOMERS.intEntityCustomerId = ACCSTATUS.intEntityCustomerId
				WHERE ACCSTATUS.intAccountStatusId IS NOT NULL
			END
	END

IF 1=0 BEGIN
    SET FMTONLY OFF
END

--DROP TEMP TABLES
IF(OBJECT_ID('tempdb..#ARPOSTEDPAYMENT') IS NOT NULL)
BEGIN
    DROP TABLE #ARPOSTEDPAYMENT
END

IF(OBJECT_ID('tempdb..#INVOICETOTALPREPAYMENTS') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICETOTALPREPAYMENTS
END

IF(OBJECT_ID('tempdb..#APPAYMENTDETAILS') IS NOT NULL)
BEGIN
    DROP TABLE #APPAYMENTDETAILS
END

IF(OBJECT_ID('tempdb..#POSTEDINVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #POSTEDINVOICES
END

IF(OBJECT_ID('tempdb..#CASHREFUNDS') IS NOT NULL)
BEGIN
	DROP TABLE #CASHREFUNDS
END

IF(OBJECT_ID('tempdb..#CASHRETURNS') IS NOT NULL)
BEGIN
	DROP TABLE #CASHRETURNS
END

IF(OBJECT_ID('tempdb..#FORGIVENSERVICECHARGE') IS NOT NULL)
BEGIN
	DROP TABLE #FORGIVENSERVICECHARGE
END

--#ARPOSTEDPAYMENT
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , intPaymentMethodId
INTO #ARPOSTEDPAYMENT
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN @tblCustomers C ON P.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON P.intLocationId = CL.intCompanyLocationId
LEFT JOIN dbo.tblARNSFStagingTableDetail NSF ON P.intPaymentId = NSF.intTransactionId AND NSF.strTransactionType = 'Payment'
WHERE P.ysnPosted = 1
  AND (P.ysnProcessedToNSF = 0 OR (P.ysnProcessedToNSF = 1 AND CAST(NSF.dtmDate AS DATE) > @dtmDateToLocal))
  AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
  OR intPaymentId IN (select D.intPaymentId
	from tblARPaymentDetail D
	INNER JOIN tblARInvoice I
	ON D.strTransactionNumber = I.strInvoiceNumber
	WHERE dtmDate = @dtmDateToLocal
	AND dtmDate <> dtmPostDate))

--WRITE OFF FILTER
IF (@ysnIncludeWriteOffPaymentLocal = 1)
	BEGIN
		IF(OBJECT_ID('tempdb..#WRITEOFFS') IS NOT NULL)
		BEGIN
			DROP TABLE #WRITEOFFS
		END

		SELECT intPaymentMethodID
		INTO #WRITEOFFS 
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
		WHERE UPPER(strPaymentMethod) LIKE '%WRITE OFF%'

		DELETE FROM ARP
		FROM #ARPOSTEDPAYMENT ARP 
		INNER JOIN #WRITEOFFS WO ON ARP.intPaymentMethodId = WO.intPaymentMethodID		
	END

--#INVOICETOTALPREPAYMENTS
SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
		, PD.intInvoiceId
INTO #INVOICETOTALPREPAYMENTS
FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
                             AND P.ysnInvoicePrepayment = 0
GROUP BY PD.intInvoiceId

--#APPAYMENTDETAILS
SELECT APPD.intPaymentId
	 , intInvoiceId
	 , dblDiscount
	 , dblPayment
	 , dblInterest
	 , dblAmountPaid
INTO #APPAYMENTDETAILS
FROM dbo.tblAPPaymentDetail APPD WITH (NOLOCK)
INNER JOIN (
	SELECT intPaymentId
		 , dblAmountPaid = -dblAmountPaid
	FROM dbo.tblAPPayment WITH (NOLOCK)
	WHERE ysnPosted = 1
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
) APP ON APPD.intPaymentId = APP.intPaymentId
WHERE intInvoiceId IS NOT NULL

--#FORGIVENSERVICECHARGE
SELECT SC.intInvoiceId
	 , SC.strInvoiceNumber
INTO #FORGIVENSERVICECHARGE 
FROM tblARInvoice I
INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN tblARInvoice SC ON I.strInvoiceOriginId = SC.strInvoiceNumber
WHERE I.strInvoiceOriginId IS NOT NULL 
  AND I.strTransactionType = 'Credit Memo' 
  AND I.strType = 'Standard'
  AND SC.strTransactionType = 'Invoice'
  AND SC.strType = 'Service Charge'
  AND SC.ysnForgiven = 1

--#POSTEDINVOICES
SELECT I.intInvoiceId
	 , I.intPaymentId
	 , I.intEntityCustomerId
	 , I.intEntitySalespersonId
	 , I.intCompanyLocationId
	 , I.dtmPostDate
	 , I.dtmDueDate
	 , I.strTransactionType
	 , I.strType
	 , I.strInvoiceNumber
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dblInterest
	 , I.ysnForgiven
	 , I.dtmForgiveDate
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN #FORGIVENSERVICECHARGE SC ON I.intInvoiceId = SC.intInvoiceId 
WHERE ysnPosted = 1
	AND ysnCancelled = 0	
	AND strTransactionType <> 'Cash Refund'
	AND ( 
		(SC.intInvoiceId IS NULL AND ((I.strType = 'Service Charge' AND (@ysnFromBalanceForward = 0 AND @dtmDateToLocal < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmForgiveDate))))) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0))))
		OR 
		SC.intInvoiceId IS NOT NULL
	)
	AND I.intAccountId IN (
		SELECT A.intAccountId
		FROM dbo.tblGLAccount A WITH (NOLOCK)
		INNER JOIN (SELECT intAccountSegmentId
						 , intAccountId
					FROM dbo.tblGLAccountSegmentMapping WITH (NOLOCK)
		) ASM ON A.intAccountId = ASM.intAccountId
		INNER JOIN (SELECT intAccountSegmentId
						 , intAccountCategoryId
						 , intAccountStructureId
					FROM dbo.tblGLAccountSegment WITH (NOLOCK)
		) GLAS ON ASM.intAccountSegmentId = GLAS.intAccountSegmentId
		INNER JOIN (SELECT intAccountStructureId                 
					FROM dbo.tblGLAccountStructure WITH (NOLOCK)
					WHERE strType = 'Primary'
		) AST ON GLAS.intAccountStructureId = AST.intAccountStructureId
		INNER JOIN (SELECT intAccountCategoryId
						 , strAccountCategory 
					FROM dbo.tblGLAccountCategory WITH (NOLOCK)
					WHERE (strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND strAccountCategory = 'AP Account'))
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
	)
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal		
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

IF ISNULL(@strSalespersonIdsLocal, '') <> ''
	BEGIN
		INSERT INTO @tblSalesperson
		SELECT SP.intEntityId
		FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strSalespersonIdsLocal)
		) SALESPERSON ON SP.intEntityId = SALESPERSON.intID

		DELETE INVOICES
		FROM #POSTEDINVOICES INVOICES
		LEFT JOIN @tblSalesperson SALESPERSON ON INVOICES.intEntitySalespersonId = SALESPERSON.intSalespersonId
		WHERE SALESPERSON.intSalespersonId IS NULL 
	END

IF (@ysnPrintFromCFLocal = 1)
	BEGIN
		DELETE I 
		FROM #POSTEDINVOICES I
		LEFT JOIN tblCFInvoiceStagingTable IST ON I.intInvoiceId = IST.intInvoiceId
											   AND IST.strUserId = @strUserId
											   AND LOWER(IST.strStatementType) = 'invoice'
		WHERE I.strType = 'CF Tran'
		  AND I.intInvoiceId IS NULL

		DELETE I 
		FROM #POSTEDINVOICES I
		INNER JOIN tblCFTransaction CF ON I.strInvoiceNumber = CF.strTransactionId
		WHERE I.strType = 'CF Tran'
		  AND ISNULL(CF.ysnInvoiced, 0) = 1
		  AND I.dtmPostDate <= @dtmDateToLocal
	END

--#CASHREFUNDS
SELECT strDocumentNumber	= ID.strDocumentNumber
     , dblRefundTotal		= SUM(I.dblInvoiceTotal) 
INTO #CASHREFUNDS
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.strTransactionType = 'Cash Refund'
  AND I.ysnPosted = 1
  AND ISNULL(ID.strDocumentNumber, '') <> ''
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal  
GROUP BY ID.strDocumentNumber

--#CASHRETURNS
SELECT intInvoiceId
	 , intOriginalInvoiceId
	 , dblInvoiceTotal
	 , strInvoiceOriginId
INTO #CASHRETURNS	 
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE ysnPosted = 1
  AND ysnRefundProcessed = 1
  AND strTransactionType = 'Credit Memo'
  AND intOriginalInvoiceId IS NOT NULL
  AND ISNULL(strInvoiceOriginId, '') <> ''
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--REMOVE SERVICE CHARGE THAT WAS ALREADY CAUGHT IN BALANCE FORWARD
-- IF (@ysnFromBalanceForward = 0 AND @dtmBalanceForwardDate IS NOT NULL)
-- BEGIN
-- 	DELETE FROM #POSTEDINVOICES WHERE strType = 'Service Charge' AND ysnForgiven = 1 AND @dtmBalanceForwardDate < dtmForgiveDate
-- END
	
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
)	
SELECT strCustomerName		= CUSTOMER.strCustomerName
     , strEntityNo			= CUSTOMER.strCustomerNumber
	 , strCustomerInfo		= CUSTOMER.strCustomerName + ' ' + CUSTOMER.strCustomerNumber
	 , intEntityCustomerId	= AGING.intEntityCustomerId
	 , intEntityUserId		= @intEntityUserIdLocal
	 , dblCreditLimit		= CUSTOMER.dblCreditLimit
	 , dblTotalAR			= AGING.dblTotalAR
	 , dblTotalCustomerAR	= AGING.dblTotalAR
	 , dblFuture			= AGING.dblFuture
	 , dbl0Days				= AGING.dbl0Days
	 , dbl10Days            = AGING.dbl10Days
	 , dbl30Days            = AGING.dbl30Days
	 , dbl60Days            = AGING.dbl60Days
	 , dbl90Days            = AGING.dbl90Days
	 , dbl91Days            = AGING.dbl91Days
	 , dblTotalDue          = AGING.dblTotalDue
	 , dblAmountPaid        = AGING.dblAmountPaid
	 , dblCredits           = AGING.dblCredits
	 , dblPrepayments		= AGING.dblPrepayments
	 , dblPrepaids          = AGING.dblPrepayments
	 , dtmAsOfDate          = @dtmDateToLocal
	 , strSalespersonName   = 'strSalespersonName'
	 , strSourceTransaction	= @strSourceTransactionLocal
	 , strCompanyName		= @strCompanyName
	 , strCompanyAddress	= @strCompanyAddress
	 , strAgingType			= 'Summary'
FROM
(SELECT A.intEntityCustomerId
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
FROM

(SELECT I.intInvoiceId
      , I.intEntityCustomerId
	  , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				 ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
	    			       WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	    			       WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	    			       WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	    			       WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	    			       WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 THEN 'Over 90' END
				 END
FROM #POSTEDINVOICES I WITH (NOLOCK)
WHERE ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')) OR (@ysnIncludeCreditsLocal = 1))

) AS A  


LEFT JOIN
          
(SELECT DISTINCT 
      intEntityCustomerId
    , intInvoiceId  
	, dblAmountPaid
    , dblTotalDue	= dblInvoiceTotal - dblAmountPaid
    , dblAvailableCredit
	, dblPrepayments
	, CASE WHEN strType = 'CF Tran' 
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dblFuture
    , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 0 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl0Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 10 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl10Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 30 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl30Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 60 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl60Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 90 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl90Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90 AND strType <> 'CF Tran'
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl91Days
FROM
(SELECT I.intInvoiceId
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
      , dblAmountDue		= 0    
      , I.dtmDueDate    
      , I.intEntityCustomerId
      , dblAvailableCredit	= 0
	  , dblPrepayments		= 0
	  , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= CASE WHEN I.strType = 'CF Tran' THEN (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1 ELSE 0 END
     , dblAmountDue			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit	= CASE WHEN I.strType = 'CF Tran' THEN 0 ELSE ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0) END
	 , dblPrepayments		= 0
	 , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
	LEFT JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN #CASHREFUNDS CR ON I.strInvoiceNumber = CR.strDocumentNumber AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
WHERE ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')) OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    		

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
     , dblAmountDue			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit	= 0
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
	 , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN #CASHREFUNDS CR ON I.strInvoiceNumber = CR.strDocumentNumber AND I.strTransactionType = 'Customer Prepayment'
WHERE ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    		
	                                          
UNION ALL
            
SELECT I.intInvoiceId
    , dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
    , dblInvoiceTotal		= 0
    , dblAmountDue			= 0
    , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
    , I.intEntityCustomerId
    , dblAvailableCredit	= 0
	, dblPrepayments		= 0
	, I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
LEFT JOIN (
	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) + SUM(ISNULL(dblWriteOffAmount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , dblTotalPayment		= -(SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0)))
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId

	UNION ALL

	SELECT intInvoiceId			= intOriginalInvoiceId
		 , dblTotalPayment		= dblInvoiceTotal
	FROM #CASHRETURNS
) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
WHERE ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')) OR (@ysnIncludeCreditsLocal = 1))

) AS TBL) AS B
          
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

GROUP BY A.intEntityCustomerId) AS AGING
INNER JOIN @tblCustomers CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId	
ORDER BY strCustomerName