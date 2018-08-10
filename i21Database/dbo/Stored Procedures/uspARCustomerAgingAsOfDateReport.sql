CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	@dtmDateFrom				DATETIME = NULL,
	@dtmDateTo					DATETIME = NULL,
	@strSalesperson				NVARCHAR(100) = NULL,
	@intEntityCustomerId		INT = NULL,
	@intEntityUserId			INT = NULL,
	@strSourceTransaction		NVARCHAR(100) = NULL,
	@strCompanyLocation			NVARCHAR(100) = NULL,
	@ysnIncludeBudget			BIT = 0,
	@ysnIncludeCredits			BIT = 1,
	@ysnIncludeWriteOffPayment	BIT = 0,
	@strCustomerName			NVARCHAR(MAX) = NULL,
	@strAccountStatusCode		NVARCHAR(100) = NULL,
	@strCustomerIds				NVARCHAR(MAX) = NULL,
	@ysnFromBalanceForward		BIT = 0,
	@dtmBalanceForwardDate		DATETIME = NULL
AS

DECLARE @dtmDateFromLocal				DATETIME		= NULL,
	    @dtmDateToLocal					DATETIME		= NULL,
	    @strSalespersonLocal			NVARCHAR(100)	= NULL,
	    @intEntityCustomerIdLocal		INT				= NULL,
		@intEntityUserIdLocal			INT				= NULL,
		@strSourceTransactionLocal		NVARCHAR(100)	= NULL,
		@strCompanyLocationLocal		NVARCHAR(100)	= NULL,
		@ysnIncludeBudgetLocal			BIT				= 0,
		@ysnIncludeCreditsLocal			BIT				= 1,
		@ysnIncludeWriteOffPaymentLocal BIT				= 1,
		@intSalespersonId				INT				= NULL,
		@intCompanyLocationId			INT				= NULL,
		@strCustomerNameLocal			NVARCHAR(MAX)	= NULL,
		@strAccountStatusCodeLocal		NVARCHAR(100)	= NULL,
		@strCustomerIdsLocal			NVARCHAR(MAX)	= NULL

DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)
		
SET @dtmDateFromLocal				= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET	@dtmDateToLocal					= ISNULL(@dtmDateTo, GETDATE())
SET @strSalespersonLocal			= NULLIF(@strSalesperson, '')
SET @intEntityCustomerIdLocal		= NULLIF(@intEntityCustomerId, 0)
SET @intEntityUserIdLocal			= NULLIF(@intEntityUserId, 0)
SET @strSourceTransactionLocal		= NULLIF(@strSourceTransaction, '')
SET @strCompanyLocationLocal		= NULLIF(@strCompanyLocation, '')
SET @ysnIncludeBudgetLocal			= @ysnIncludeBudget
SET @ysnIncludeCreditsLocal			= @ysnIncludeCredits
SET @ysnIncludeWriteOffPaymentLocal	= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @strCustomerNameLocal			= NULLIF(@strCustomerName, '')
SET @strAccountStatusCodeLocal		= NULLIF(@strAccountStatusCode, '')
SET @strCustomerIdsLocal			= NULLIF(@strCustomerIds, '')

IF ISNULL(@intEntityCustomerIdLocal, 0) <> 0
	BEGIN
		INSERT INTO @tblCustomers
		SELECT TOP 1 C.intEntityId 
			       , C.strCustomerNumber
				   , EC.strName
				   , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE intEntityId = @intEntityCustomerIdLocal
		) EC ON C.intEntityId = EC.intEntityId
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
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
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		OUTER APPLY (
			SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
			FROM (
				SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
				FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
				INNER JOIN (
					SELECT intAccountStatusId
							, strAccountStatusCode
					FROM dbo.tblARAccountStatus WITH (NOLOCK)
				) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
				WHERE CAS.intEntityCustomerId = C.intEntityId
				FOR XML PATH ('')
			) SC (strAccountStatusCode)
		) STATUSCODES
		WHERE (@strAccountStatusCodeLocal IS NULL OR STATUSCODES.strAccountStatusCode LIKE '%'+ @strAccountStatusCodeLocal +'%')
	END

IF ISNULL(@strSalespersonLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intSalespersonId = SP.intEntityId
		FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strSalespersonLocal IS NULL OR strName = @strSalespersonLocal)
		) ES ON SP.intEntityId = ES.intEntityId
	END

IF ISNULL(@strCompanyLocationLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE (@strCompanyLocationLocal IS NULL OR strLocationName = @strCompanyLocationLocal)
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

IF(OBJECT_ID('tempdb..#PROVISIONALINVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #PROVISIONALINVOICES
END

--#ARPOSTEDPAYMENT
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
	 , intPaymentMethodId
INTO #ARPOSTEDPAYMENT
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON P.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND ysnProcessedToNSF = 0
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

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
SELECT dblPayment = SUM(dblPayment)
		, PD.intInvoiceId
INTO #INVOICETOTALPREPAYMENTS
FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
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
INNER JOIN (SELECT intPaymentId
				 , dblAmountPaid
			FROM dbo.tblAPPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
) APP ON APPD.intPaymentId = APP.intPaymentId
WHERE intInvoiceId IS NOT NULL

--#PROVISIONALINVOICES
SELECT intInvoiceId            = PROVI.intInvoiceId
     , dblInvoiceTotal         = PROVI.dblInvoiceTotal
INTO #PROVISIONALINVOICES
FROM dbo.tblARInvoice PROVI
WHERE PROVI.ysnPosted = 1
  AND PROVI.strType = 'Provisional'
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), PROVI.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

--#POSTEDINVOICES
SELECT I.intInvoiceId
	 , I.intPaymentId
	 , I.intEntityCustomerId
	 , I.intOriginalInvoiceId
     , I.intSourceId
	 , I.dtmPostDate
	 , I.dtmDueDate
	 , I.strTransactionType
	 , I.strType
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dblInterest
	 , I.ysnForgiven
	 , I.dtmForgiveDate
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND ysnCancelled = 0
	AND ((I.strType = 'Service Charge' AND (@ysnFromBalanceForward = 0 AND @dtmDateToLocal < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) )) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
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
					WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
	)
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal		
	AND (@intCompanyLocationId IS NULL OR I.intCompanyLocationId = @intCompanyLocationId)
	AND (@intSalespersonId IS NULL OR intEntitySalespersonId = @intSalespersonId)
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')

--REMOVE SERVICE CHARGE THAT WAS ALREADY CAUGHT IN BALANCE FORWARD
IF (@ysnFromBalanceForward = 0 AND @dtmBalanceForwardDate IS NOT NULL)
BEGIN
	DELETE FROM #POSTEDINVOICES WHERE strType = 'Service Charge' AND ysnForgiven = 1 AND @dtmBalanceForwardDate < dtmForgiveDate
END
	
DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Summary'
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
	 , intEntityUserId
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
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
	 , strAgingType
	 , dblTotalCustomerAR

)	
SELECT strCustomerName		= CUSTOMER.strCustomerName
     , strEntityNo			= CUSTOMER.strCustomerNumber
	 , strCustomerInfo		= CUSTOMER.strCustomerName + ' ' + CUSTOMER.strCustomerNumber
	 , intEntityCustomerId	= AGING.intEntityCustomerId
	 , intEntityUserId		= @intEntityUserIdLocal
	 , dblCreditLimit		= CUSTOMER.dblCreditLimit
	 , dblTotalAR			= AGING.dblTotalAR
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
	 , strCompanyName		= COMPANY.strCompanyName
	 , strCompanyAddress	= COMPANY.strCompanyAddress
	 , strAgingType			= 'Summary'
	 , dblTotalCustomerAR	= CUSTAR.dblARBalance
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
WHERE ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))

UNION ALL

SELECT intInvoiceId			= CB.intCustomerBudgetId
     , intEntityCustomerId	= CB.intEntityCustomerId      
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 0 THEN 'Current'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 90 THEN 'Over 90' END    
FROM tblARCustomerBudget CB	
INNER JOIN (
	SELECT intEntityId
		 , ysnCustomerBudgetTieBudget
	FROM tblARCustomer 
) CUST ON CB.intEntityCustomerId = CUST.intEntityId
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON CUST.intEntityId = C.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	AND CB.dblAmountPaid < CB.dblBudgetAmount
	AND @ysnIncludeBudgetLocal = 1
	--AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

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
WHERE I.strTransactionType IN ('Invoice', 'Debit Memo')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= CASE WHEN I.strType = 'CF Tran' THEN (ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)) * -1 ELSE 0 END
     , dblAmountDue			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit   = CASE WHEN I.strType = 'CF Tran' THEN 0
								WHEN ISNULL(I.intSourceId, 0) = 2 AND ISNULL(I.intOriginalInvoiceId, 0) <> 0 THEN ISNULL(I.dblAmountDue, 0) + ISNULL(PD.dblPayment, 0)
								ELSE ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) 
                              END
	 , dblPrepayments		= 0
	 , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
	LEFT JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment)
			 , PD.intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
		GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId		
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
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
	 , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
WHERE ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    		
	                                          
UNION ALL
            
SELECT I.intInvoiceId
    , dblAmountPaid         = CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) + ISNULL(PROVI.dblInvoiceTotal, 0) END
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
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId
) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
LEFT JOIN #PROVISIONALINVOICES PROVI ON I.intOriginalInvoiceId = PROVI.intInvoiceId
WHERE ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))

UNION ALL

SELECT intInvoiceId			= CB.intCustomerBudgetId
     , dblAmountPaid		= CB.dblAmountPaid
	 , dblInvoiceTotal		= CB.dblBudgetAmount
     , dblAmountDue			= CB.dblBudgetAmount - CB.dblAmountPaid
     , dtmDueDate			= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
     , intEntityCustomerId	= CB.intEntityCustomerId
     , dblAvailableCredit	= 0
	 , dblPrepayments		= 0
	 , strType				= ''
FROM tblARCustomerBudget CB	
LEFT JOIN (
	SELECT intEntityId
		 , ysnCustomerBudgetTieBudget
	FROM tblARCustomer 
) CUST ON CB.intEntityCustomerId = CUST.intEntityId
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON CUST.intEntityId = C.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	AND CB.dblAmountPaid < CB.dblBudgetAmount 
	AND @ysnIncludeBudgetLocal = 1
	--AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

) AS TBL) AS B
          
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

GROUP BY A.intEntityCustomerId) AS AGING
INNER JOIN @tblCustomers CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) 
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
LEFT JOIN (SELECT intEntityCustomerId, dblARBalance FROM vyuARCustomerSearch) CUSTAR ON CUSTAR.intEntityCustomerId = AGING.intEntityCustomerId 
ORDER BY strCustomerName