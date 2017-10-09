﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	@dtmDateFrom			DATETIME = NULL,
	@dtmDateTo				DATETIME = NULL,
	@strSalesperson			NVARCHAR(100) = NULL,
	@intEntityCustomerId	INT = NULL,
	@strSourceTransaction	NVARCHAR(100) = NULL,
	@strCompanyLocation		NVARCHAR(100) = NULL,
	@ysnIncludeBudget       BIT = 0,
	@ysnIncludeCredits      BIT = 1,
	@strCustomerName		NVARCHAR(MAX) = NULL
AS

DECLARE @dtmDateFromLocal			DATETIME		= NULL,
	    @dtmDateToLocal				DATETIME		= NULL,
	    @strSalespersonLocal		NVARCHAR(100)	= NULL,
	    @intEntityCustomerIdLocal	INT				= NULL,
		@strSourceTransactionLocal	NVARCHAR(100)	= NULL,
		@strCompanyLocationLocal    NVARCHAR(100)	= NULL,
		@ysnIncludeBudgetLocal		BIT				= 0,
		@ysnIncludeCreditsLocal		BIT				= 1,
		@intSalespersonId			INT				= NULL,
		@intCompanyLocationId		INT				= NULL,
		@strCustomerNameLocal		NVARCHAR(MAX)	= NULL

DECLARE @tblCustomers TABLE (
	    intEntityCustomerId			INT	  
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)
		
SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo
SET @strSalespersonLocal		= @strSalesperson
SET @intEntityCustomerIdLocal   = @intEntityCustomerId
SET @strSourceTransactionLocal  = @strSourceTransaction
SET @strCompanyLocationLocal	= @strCompanyLocation
SET @ysnIncludeBudgetLocal		= @ysnIncludeBudget
SET @ysnIncludeCreditsLocal		= @ysnIncludeCredits
SET @strCustomerNameLocal		= @strCustomerName

IF ISNULL(@intEntityCustomerIdLocal, 0) <> 0
	BEGIN
		INSERT INTO @tblCustomers
		SELECT TOP 1 intEntityCustomerId 
			       , C.strCustomerNumber
				   , EC.strName
				   , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			     , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE intEntityId = @intEntityCustomerIdLocal
		) EC ON C.intEntityCustomerId = EC.intEntityId
	END
ELSE
	BEGIN
		INSERT INTO @tblCustomers
		SELECT intEntityCustomerId 
			 , C.strCustomerNumber
			 , EC.strName
			 , C.dblCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName LIKE '%'+ @strCustomerNameLocal +'%')
		) EC ON C.intEntityCustomerId = EC.intEntityId
	END

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE()

IF ISNULL(@strSalespersonLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intSalespersonId = SP.intEntitySalespersonId
		FROM dbo.tblARSalesperson SP WITH (NOLOCK) 
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strSalespersonLocal IS NULL OR strName LIKE '%'+ @strSalespersonLocal +'%')
		) ES ON SP.intEntitySalespersonId = ES.intEntityId
	END

IF ISNULL(@strCompanyLocationLocal, '') <> ''
	BEGIN
		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		WHERE (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+ @strCompanyLocationLocal +'%')
	END

IF RTRIM(LTRIM(@strSourceTransactionLocal)) = ''
    SET @strSourceTransactionLocal = NULL;

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

IF(OBJECT_ID('tempdb..#PREPAIDS') IS NOT NULL)
BEGIN
    DROP TABLE #PREPAIDS
END

IF(OBJECT_ID('tempdb..#PREPAIDSINVOICES') IS NOT NULL)
BEGIN
    DROP TABLE #PREPAIDSINVOICES
END

--#ARPOSTEDPAYMENT
SELECT intPaymentId
	 , dtmDatePaid
	 , dblAmountPaid
	 , ysnInvoicePrepayment
INTO #ARPOSTEDPAYMENT
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON P.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal

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

--#POSTEDINVOICES
SELECT I.intInvoiceId
	 , I.intPaymentId
	 , I.intEntityCustomerId
	 , I.dtmPostDate
	 , I.dtmDueDate
	 , I.strTransactionType
	 , I.strType
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dblInterest
INTO #POSTEDINVOICES
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
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
	AND (@intCompanyLocationId IS NULL OR intCompanyLocationId = @intCompanyLocationId)
	AND (@intSalespersonId IS NULL OR intEntitySalespersonId = @intSalespersonId)
	AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')	

--#PREPAIDS
SELECT intPrepaymentId
	 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
INTO #PREPAIDS
FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK) 
WHERE ysnApplied = 1
GROUP BY intPrepaymentId

--#PREPAIDSINVOICES
SELECT PC.intInvoiceId
	 , I.strInvoiceNumber
	 , PC.intPrepaymentId
	 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
INTO #PREPAIDSINVOICES
FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) 
INNER JOIN (SELECT intInvoiceId
				 , strInvoiceNumber
			FROM dbo.tblARInvoice WITH (NOLOCK)
) I ON I.intInvoiceId = PC.intPrepaymentId
WHERE ysnApplied = 1
GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber

SELECT strCustomerName		= CUSTOMER.strCustomerName
     , strEntityNo			= CUSTOMER.strCustomerNumber
	 , intEntityCustomerId	= AGING.intEntityCustomerId
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
	SELECT intEntityCustomerId
		 , ysnCustomerBudgetTieBudget
	FROM tblARCustomer 
) CUST ON CB.intEntityCustomerId = CUST.intEntityCustomerId
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON CUST.intEntityCustomerId = C.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	AND CB.dblAmountPaid < CB.dblBudgetAmount
	AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

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
     , dblInvoiceTotal		= 0
     , dblAmountDue			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
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
	LEFT JOIN #PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId
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
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , I.strType
FROM #POSTEDINVOICES I WITH (NOLOCK)
	INNER JOIN #ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN #INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN #PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId 
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

	UNION ALL

	SELECT PC.intInvoiceId
		 , dblTotalPayment = SUM(dblAppliedInvoiceAmount)
	FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) 
	INNER JOIN (SELECT intInvoiceId
					 , strInvoiceNumber
				FROM dbo.tblARInvoice WITH (NOLOCK)
	) I ON I.intInvoiceId = PC.intPrepaymentId
	WHERE ysnApplied = 1
	GROUP BY PC.intInvoiceId

) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
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
	SELECT intEntityCustomerId
		 , ysnCustomerBudgetTieBudget
	FROM tblARCustomer 
) CUST ON CB.intEntityCustomerId = CUST.intEntityCustomerId
INNER JOIN (
	SELECT intEntityCustomerId
	FROM @tblCustomers
) C ON CUST.intEntityCustomerId = C.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	AND CB.dblAmountPaid < CB.dblBudgetAmount 
	AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

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
ORDER BY strCustomerName