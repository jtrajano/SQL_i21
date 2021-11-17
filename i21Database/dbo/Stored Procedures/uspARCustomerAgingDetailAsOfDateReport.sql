CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailAsOfDateReport]
	  @dtmDateFrom				DATETIME = NULL
	, @dtmDateTo				DATETIME = NULL
    , @strSourceTransaction		NVARCHAR(100) = NULL	
	, @strCustomerIds			NVARCHAR(MAX) = NULL
	, @strSalespersonIds		NVARCHAR(MAX) = NULL
	, @strCompanyLocationIds	NVARCHAR(MAX) = NULL
	, @strAccountStatusIds		NVARCHAR(MAX) = NULL	
	, @intEntityUserId			INT = NULL
	, @ysnPaidInvoice			BIT = NULL
	, @ysnInclude120Days		BIT = 0
	, @ysnExcludeAccountStatus	BIT = 0
	, @intGracePeriod			INT = 0
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @dtmDateFromLocal			DATETIME = NULL,
		@dtmDateToLocal				DATETIME = NULL,
		@strSourceTransactionLocal	NVARCHAR(100) = NULL,
		@strCustomerIdsLocal		NVARCHAR(MAX) = NULL,
		@strSalespersonIdsLocal		NVARCHAR(MAX) = NULL,		
		@strCompanyLocationIdsLocal NVARCHAR(MAX) = NULL,
		@strAccountStatusIdsLocal	NVARCHAR(MAX) = NULL,
		@strCompanyName				NVARCHAR(100) = NULL,
		@strCompanyAddress			NVARCHAR(500) = NULL,
		@intEntityUserIdLocal		INT = NULL,
		@intGracePeriodLocal		INT = 0

DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)

DECLARE @tblSalesperson TABLE (intSalespersonId INT)
DECLARE @tblCompanyLocation TABLE (intCompanyLocationId INT)
DECLARE @tblAccountStatus TABLE (intAccountStatusId INT, intEntityCustomerId INT)

SET @dtmDateFromLocal			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET	@dtmDateToLocal				= ISNULL(@dtmDateTo, GETDATE())
SET @strSourceTransactionLocal	= NULLIF(@strSourceTransaction, '')
SET @strCustomerIdsLocal		= NULLIF(@strCustomerIds, '')
SET @strSalespersonIdsLocal		= NULLIF(@strSalespersonIds, '')
SET @strCompanyLocationIdsLocal	= NULLIF(@strCompanyLocationIds, '')
SET @strAccountStatusIdsLocal	= NULLIF(@strAccountStatusIds, '')
SET @intEntityUserIdLocal		= NULLIF(@intEntityUserId, 0)
SET @intGracePeriodLocal		= ISNULL(@intGracePeriod, 0)

SELECT TOP 1 @strCompanyName	= strCompanyName
		   , @strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF ISNULL(@strCustomerIdsLocal, '') <> ''
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

--DROP TEMP TABLES
IF(OBJECT_ID('tempdb..#ARPOSTEDPAYMENT') IS NOT NULL)
BEGIN
    DROP TABLE #ARPOSTEDPAYMENT
END

IF(OBJECT_ID('tempdb..#INVOICETOTALPREPAYMENTS') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICETOTALPREPAYMENTS
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

IF(OBJECT_ID('tempdb..#AGINGSTAGING') IS NOT NULL)
BEGIN
	DROP TABLE #AGINGSTAGING
END

IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL)
BEGIN
	DROP TABLE #GLACCOUNTS
END

--#ARPOSTEDPAYMENT
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , strRecordNumber
INTO #ARPOSTEDPAYMENT
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN @tblCustomers C ON P.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN dbo.tblARNSFStagingTableDetail NSF ON P.intPaymentId = NSF.intTransactionId AND NSF.strTransactionType = 'Payment'
WHERE P.ysnPosted = 1
  AND (P.ysnProcessedToNSF = 0 OR (P.ysnProcessedToNSF = 1 AND CAST(NSF.dtmDate AS DATE) > @dtmDateToLocal))
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	

--#INVOICETOTALPREPAYMENTS
SELECT dblPayment	= SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
	 , intInvoiceId = PD.intInvoiceId
INTO #INVOICETOTALPREPAYMENTS
FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
GROUP BY PD.intInvoiceId

--#GLACCOUNTS
SELECT intAccountId
	 , strAccountCategory
INTO #GLACCOUNTS
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'AP Account')

--#POSTEDINVOICES
SELECT intInvoiceId			= I.intInvoiceId
	 , intPaymentId			= I.intPaymentId
	 , intEntityCustomerId	= I.intEntityCustomerId
	 , intCompanyLocationId	= I.intCompanyLocationId
	 , intEntitySalespersonId = I.intEntitySalespersonId
	 , dtmPostDate			= I.dtmPostDate
	 , dtmDueDate			= DATEADD(DAYOFYEAR, @intGracePeriodLocal, I.dtmDueDate)
	 , dtmDate				= CAST(I.dtmDate AS DATE)
	 , strTransactionType	= I.strTransactionType
	 , strType				= I.strType
	 , dblInvoiceTotal		= I.dblInvoiceTotal
	 , dblAmountDue			= I.dblAmountDue
	 , dblDiscount			= I.dblDiscount
	 , dblInterest			= I.dblInterest
	 , strBOLNumber			= I.strBOLNumber
	 , strInvoiceNumber		= I.strInvoiceNumber
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN #GLACCOUNTS GL ON GL.intAccountId = I.intAccountId AND (GL.strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND GL.strAccountCategory = 'AP Account'))
WHERE ysnPosted = 1
	AND (@ysnPaidInvoice is null or (ysnPaid = @ysnPaidInvoice))
	AND ysnCancelled = 0
	AND strTransactionType <> 'Cash Refund'
	AND ((strType = 'Service Charge' AND  @dtmDateToLocal < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmForgiveDate)))) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))	
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

--#CASHREFUNDS
SELECT intOriginalInvoiceId	= I.intOriginalInvoiceId
		,strDocumentNumber = ID.strDocumentNumber
		, dblRefundTotal		= SUM(ID.dblTotal)
INTO #CASHREFUNDS
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN @tblCustomers C ON I.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN @tblCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.strTransactionType = 'Cash Refund'
  AND I.ysnPosted = 1
  AND (ISNULL(I.intOriginalInvoiceId, '') <> '' OR ISNULL(ID.strDocumentNumber, '') <> '')
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal  
GROUP BY I.intOriginalInvoiceId, ID.strDocumentNumber

--#CASHRETURNS
SELECT I.intInvoiceId
	 , I.intOriginalInvoiceId
	 , I.dblInvoiceTotal
	 , I.strInvoiceOriginId
	 , I.strInvoiceNumber
	 , I.dtmPostDate
INTO #CASHRETURNS	 
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN tblARInvoice RI ON I.intOriginalInvoiceId = RI.intInvoiceId AND I.strInvoiceOriginId = RI.strInvoiceNumber
WHERE I.ysnPosted = 1
  AND I.ysnRefundProcessed = 1
  AND I.strTransactionType = 'Credit Memo'
  AND I.intOriginalInvoiceId IS NOT NULL
  AND ISNULL(I.strInvoiceOriginId, '') <> ''
  AND ISNULL(RI.ysnReturned, 0) = 0
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

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

SELECT strCustomerName		= CUSTOMER.strCustomerName
	 , strCustomerNumber	= CUSTOMER.strCustomerNumber
	 , strCustomerInfo		= CUSTOMER.strCustomerName + CHAR(13) + CUSTOMER.strCustomerNumber
     , strInvoiceNumber		= AGING.strInvoiceNumber
	 , strRecordNumber		= AGING.strRecordNumber
	 , intInvoiceId			= AGING.intInvoiceId
	 , intPaymentId			= AGING.intPaymentId
	 , strBOLNumber			= AGING.strBOLNumber
	 , intEntityCustomerId  = AGING.intEntityCustomerId
	 , intEntityUserId		= @intEntityUserIdLocal
	 , dblCreditLimit		= CUSTOMER.dblCreditLimit
	 , dblTotalAR			= AGING.dblTotalAR
	 , dblTotalCustomerAR	= AGING.dblTotalAR
	 , dblFuture			= AGING.dblFuture
	 , dbl0Days				= AGING.dbl0Days
	 , dbl10Days			= AGING.dbl10Days
	 , dbl30Days			= AGING.dbl30Days
	 , dbl60Days			= AGING.dbl60Days
	 , dbl90Days			= AGING.dbl90Days
	 , dbl120Days			= CASE WHEN @ysnInclude120Days = 0 THEN AGING.dbl120Days + AGING.dbl121Days ELSE AGING.dbl120Days END
	 , dbl121Days			= CASE WHEN @ysnInclude120Days = 0 THEN 0 ELSE AGING.dbl121Days END
	 , dblTotalDue			= AGING.dblTotalDue
	 , dblAmountPaid		= AGING.dblAmountPaid
	 , dblInvoiceTotal		= AGING.dblInvoiceTotal
	 , dblCredits			= AGING.dblCredits
	 , dblPrepayments		= AGING.dblPrepayments
	 , dblPrepaids			= AGING.dblPrepayments
	 , dtmDate				= AGING.dtmDate
	 , dtmDueDate			= AGING.dtmDueDate
	 , dtmAsOfDate			= @dtmDateToLocal
	 , strSalespersonName	= 'strSalespersonName'
	 , intCompanyLocationId	= AGING.intCompanyLocationId
	 , strSourceTransaction	= @strSourceTransactionLocal
	 , strType				= AGING.strType
	 , strTransactionType	= AGING.strTransactionType
	 , strCompanyName		= @strCompanyName
	 , strCompanyAddress	= @strCompanyAddress
	 , strAgingType			= 'Detail'
INTO #AGINGSTAGING
FROM
(SELECT A.strInvoiceNumber
     , B.strRecordNumber
     , A.intInvoiceId
	 , B.intPaymentId	 
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblFuture			= B.dblFuture
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl120Days			= B.dbl120Days
	 , dbl121Days			= B.dbl121Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments
	 , dblAmountPaid		= B.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit * -1
	 , dblPrepayments		= B.dblPrepayments * -1	 
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , intCompanyLocationId
	 , strType
	 , strTransactionType
FROM
(SELECT dtmDate				= I.dtmDate
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.strType
	 , I.strTransactionType    
	 , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
				END
FROM #POSTEDINVOICES I WITH (NOLOCK)) AS A    

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , intInvoiceId
  , intPaymentId
  , dblAmountPaid
  , dtmDatePaid
  , dblTotalDue		= dblInvoiceTotal - dblAmountPaid
  , dblAvailableCredit
  , dblPrepayments
  , strRecordNumber
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
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 120 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl120Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 120 AND strType <> 'CF Tran'
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl121Days 
FROM
(SELECT I.intInvoiceId
	  , intPaymentId			= NULL
      , dblAmountPaid			= 0
      , dblInvoiceTotal			= ISNULL(dblInvoiceTotal,0)	  
	  , I.dtmDueDate
	  , dtmDatePaid				= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit		= 0
	  , dblPrepayments			= 0
	  , I.strType
	  , strRecordNumber			= NULL
FROM #POSTEDINVOICES I WITH (NOLOCK)
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')

UNION ALL

SELECT I.intInvoiceId
	 , intPaymentId			= P.intPaymentId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , dtmDatePaid			= NULL
	 , I.intEntityCustomerId
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
	 , dblPrepayments		= 0
	 , I.strType
	 , strRecordNumber		= P.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
	LEFT JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN #CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
WHERE I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
AND  ISNULL(CR.dblRefundTotal, 0) = 0
AND I.dblAmountDue <> 0

UNION ALL

SELECT I.intInvoiceId
	 , intPaymentId			= P.intPaymentId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , dtmDatePaid			= P.dtmDatePaid
	 , I.intEntityCustomerId
	 , dblAvailableCredit	= 0
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(CR.dblRefundTotal, 0)
	 , I.strType
	 , strRecordNumber		= P.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN #CASHREFUNDS CR ON (I.intInvoiceId = CR.intOriginalInvoiceId OR I.strInvoiceNumber = CR.strDocumentNumber) AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
WHERE I.strTransactionType = 'Customer Prepayment'
AND  ISNULL(CR.dblRefundTotal, 0) = 0 

						      
UNION ALL      
      
SELECT DISTINCT
	I.intInvoiceId
  , intPaymentId		= PAYMENT.intPaymentId
  , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
  , dblInvoiceTotal		= 0
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , dtmDatePaid			= PAYMENT.dtmDatePaid
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
  , dblPrepayments		= 0
  , I.strType
  , strRecordNumber		= PAYMENT.strRecordNumber
FROM #POSTEDINVOICES I WITH (NOLOCK)
LEFT JOIN (
	SELECT PD.intInvoiceId
		 , P.intPaymentId
		 , P.strRecordNumber
		 , P.dtmDatePaid
		 , dblTotalPayment	= ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) + ISNULL(dblWriteOffAmount, 0) - ISNULL(dblInterest, 0)
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , P.intPaymentId
		 , strRecordNumber	= strPaymentRecordNum
		 , P.dtmDatePaid
		 , dblTotalPayment	= ABS((ISNULL(dblPayment, 0) + ISNULL(dblDiscount, 0) - ISNULL(dblInterest, 0)))
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strPaymentRecordNum
			 , dtmDatePaid
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	) P ON PD.intPaymentId = P.intPaymentId
	WHERE PD.intInvoiceId IS NOT NULL
	
	UNION ALL

	SELECT intInvoiceId			= intOriginalInvoiceId
	     , intPaymentId			= NULL
		 , strRecordNumber		= strInvoiceNumber
		 , dtmDatePaid			= dtmPostDate
		 , dblTotalPayment		= dblInvoiceTotal
	FROM #CASHRETURNS	
) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash Refund')
 
) AS TBL) AS B    

ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0) AS AGING
INNER JOIN @tblCustomers CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId

TRUNCATE TABLE tblARCustomerAgingStagingTable
DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
INSERT INTO tblARCustomerAgingStagingTable (
		  strCustomerName
		, strCustomerNumber
		, strCustomerInfo
		, strInvoiceNumber
		, strRecordNumber
		, intInvoiceId
		, intPaymentId
		, strBOLNumber
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
		, dbl120Days
		, dbl121Days
		, dblTotalDue
		, dblAmountPaid
		, dblInvoiceTotal
		, dblCredits
		, dblPrepayments
		, dblPrepaids
		, dtmDate
		, dtmDueDate
		, dtmAsOfDate
		, strSalespersonName
		, intCompanyLocationId
		, strSourceTransaction
		, strType
		, strTransactionType
		, strCompanyName
		, strCompanyAddress
		, strAgingType
)
SELECT AGING.*
FROM #AGINGSTAGING AGING
LEFT JOIN (
	SELECT DISTINCT intInvoiceId 
	FROM #AGINGSTAGING 
	GROUP BY intInvoiceId 
	HAVING SUM(ISNULL(dblTotalAR, 0)) <> 0
) UNPAID ON AGING.intInvoiceId = UNPAID.intInvoiceId
WHERE ISNULL(UNPAID.intInvoiceId, 0) <> 0