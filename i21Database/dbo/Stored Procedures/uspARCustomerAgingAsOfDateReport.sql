CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	@dtmDateFrom			DATETIME = NULL,
	@dtmDateTo				DATETIME = NULL,
	@strSalesperson			NVARCHAR(100) = NULL,
	@intEntityCustomerId	INT = NULL,
	@strSourceTransaction	NVARCHAR(100) = NULL,
	@strCompanyLocation		NVARCHAR(100) = NULL,
	@ysnIncludeBudget       BIT = 0,
	@ysnIncludeCredits      BIT = 1
AS

DECLARE @dtmDateFromLocal			DATETIME		= NULL,
	    @dtmDateToLocal				DATETIME		= NULL,
	    @strSalespersonLocal		NVARCHAR(100)	= NULL,
	    @intEntityCustomerIdLocal	INT				= NULL,
		@strSourceTransactionLocal	NVARCHAR(100)	= NULL,
		@strCompanyLocationLocal    NVARCHAR(100)	= NULL,
		@ysnIncludeBudgetLocal		BIT				= 0,
		@ysnIncludeCreditsLocal		BIT				= 1

SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo
SET @strSalespersonLocal		= @strSalesperson
SET @intEntityCustomerIdLocal   = @intEntityCustomerId
SET @strSourceTransactionLocal  = @strSourceTransaction
SET @strCompanyLocationLocal	= @strCompanyLocation
SET @ysnIncludeBudgetLocal		= @ysnIncludeBudget
SET @ysnIncludeCreditsLocal		= @ysnIncludeCredits

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE()

IF RTRIM(LTRIM(@strSalespersonLocal)) = ''
    SET @strSalespersonLocal = NULL

IF RTRIM(LTRIM(@strSourceTransactionLocal)) = ''
    SET @strSourceTransactionLocal = NULL

IF RTRIM(LTRIM(@strCompanyLocationLocal)) = ''
	SET @strCompanyLocationLocal = NULL;

WITH SALESPERSON AS (
    SELECT intEntitySalespersonId
	     , strName
	FROM dbo.tblARSalesperson WITH (NOLOCK) 
	INNER JOIN (SELECT intEntityId
					 , strName 
			   FROM dbo.tblEMEntity WITH (NOLOCK)			   			   
	) ES ON intEntitySalespersonId = ES.intEntityId
),
COMPANYLOCATION AS (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM tblSMCompanyLocation WITH (NOLOCK)
),
ARPOSTEDPAYMENT AS (
	SELECT intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE ysnPosted = 1
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
),
INVOICETOTALPAYMENT AS (
	SELECT dblPayment = SUM(dblPayment)
		  , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId 
	GROUP BY PD.intInvoiceId
),
INVOICETOTALPREPAYMENTS AS (
	SELECT dblPayment = SUM(dblPayment)
		  , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId
),
PAYMENTDETAIL AS (
	SELECT intPaymentId 
		 , intInvoiceId
		 , dblPayment
	FROM dbo.tblARPaymentDetail WITH (NOLOCK)
),
ARPAYMENTDETAILS AS (
	SELECT PD.intPaymentId
	     , intInvoiceId
		 , dblDiscount
		 , dblInvoiceTotal
		 , dblPayment
		 , dblInterest
		 , dblAmountPaid
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN ARPOSTEDPAYMENT P ON PD.intPaymentId = P.intPaymentId
),
APPAYMENTDETAILS AS (
	SELECT APPD.intPaymentId
		 , intInvoiceId
		 , dblDiscount
		 , dblPayment
		 , dblInterest
		 , dblAmountPaid
	FROM dbo.tblAPPaymentDetail APPD WITH (NOLOCK)
	INNER JOIN (SELECT intPaymentId
					 , dblAmountPaid
				FROM dbo.tblAPPayment WITH (NOLOCK)
				WHERE ysnPosted = 1
				  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	) APP ON APPD.intPaymentId = APP.intPaymentId
	WHERE intInvoiceId IS NOT NULL
),
GLACCOUNTS AS (
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
),
POSTEDINVOICES AS (
	SELECT intInvoiceId
		 , intEntityCustomerId
		 , dtmPostDate
		 , strTransactionType
	FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
		LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	WHERE ysnPosted = 1
		AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
		AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > @dtmDateToLocal		
		AND intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
		AND (@strSourceTransactionLocal IS NULL OR strType LIKE '%'+@strSourceTransactionLocal+'%')
		AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')
		AND ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))
),
PREPAIDS AS (
	SELECT intPrepaymentId
		 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
	FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK) 
	WHERE ysnApplied = 1
	GROUP BY intPrepaymentId
),
PREPAIDSINVOICES AS (
	SELECT PC.intInvoiceId
		 , I.strInvoiceNumber
		 , PC.intPrepaymentId
		 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
	FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) 
	INNER JOIN (SELECT intInvoiceId
					 , strInvoiceNumber
				FROM dbo.tblARInvoice WITH (NOLOCK)
	) I ON I.intInvoiceId = PC.intPrepaymentId
	WHERE ysnApplied = 1
	GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber
)
SELECT strCustomerName		= E.strName
     , strEntityNo			= E.strEntityNo
	 , intEntityCustomerId	= AGING.intEntityCustomerId
	 , dblCreditLimit		= C.dblCreditLimit
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
FROM
(SELECT A.intEntityCustomerId
     , dblTotalAR           = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
     , dblFuture            = 0.000000
	 , dbl0Days				= SUM(B.dbl0Days)
     , dbl10Days            = SUM(B.dbl10Days)
     , dbl30Days            = SUM(B.dbl30Days)
     , dbl60Days            = SUM(B.dbl60Days)
     , dbl90Days            = SUM(B.dbl90Days)
     , dbl91Days            = SUM(B.dbl91Days)
     , dblTotalDue          = SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
     , dblAmountPaid        = SUM(A.dblAmountPaid)
     , dblCredits           = SUM(B.dblAvailableCredit) * -1
	 , dblPrepayments		= SUM(B.dblPrepayments) * -1     
FROM

(SELECT I.dtmPostDate
      , I.intInvoiceId
      , dblAmountPaid			= 0
      , dblInvoiceTotal			= ISNULL(I.dblInvoiceTotal, 0)
      , dblAmountDue			= ISNULL(I.dblAmountDue, 0)
      , dblDiscount				= 0    
	  , dblInterest				= 0    
      , I.strTransactionType    
      , I.intEntityCustomerId
	  , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 THEN 'Over 90' END    
      , dblAvailableCredit		= 0
	  , dblPrepayments			= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Invoice', 'Debit Memo')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')

UNION ALL
                                    
SELECT dtmPostDate				= ISNULL(P.dtmDatePaid, I.dtmPostDate)
     , I.intInvoiceId
     , dblAmountPaid			= 0
     , dblInvoiceTotal			= 0
     , dblAmountDue				= 0    
     , dblDiscount				= 0
	 , dblInterest				= 0
     , I.strTransactionType		   
     , I.intEntityCustomerId
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 THEN 'Over 90' END
     , dblAvailableCredit		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPAYMENT PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId	
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')) OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal	
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	

UNION ALL
                                    
SELECT dtmPostDate				= ISNULL(P.dtmDatePaid, I.dtmPostDate)
     , I.intInvoiceId
     , dblAmountPaid			= 0
     , dblInvoiceTotal			= 0
     , dblAmountDue				= 0    
     , dblDiscount				= 0
	 , dblInterest				= 0
     , I.strTransactionType		   
     , I.intEntityCustomerId
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 THEN 'Over 90' END
     , dblAvailableCredit		= 0
	 , dblPrepayments			= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId 
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
                                   
UNION ALL

SELECT P.dtmDatePaid
     , I.intInvoiceId
     , dblAmountPaid            = 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0
     , I.strTransactionType           
     , I.intEntityCustomerId
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 90 THEN 'Over 90' END
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARPayment P WITH (NOLOCK)
    LEFT JOIN PAYMENTDETAIL PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN POSTEDINVOICES I ON PD.intInvoiceId = I.intInvoiceId AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))				    	
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    
                                     
UNION ALL      
      
SELECT I.dtmPostDate      
        , I.intInvoiceId
		, dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
								THEN 
									CASE WHEN ISNULL(ARPD.dblAmountPaid, 0) + ISNULL(APPD.dblAmountPaid, 0) < 0 
										THEN ISNULL(ARPD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
										ELSE 0 
									END 
								ELSE ISNULL(ARPD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
							  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
	    , dblInvoiceTotal	= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(ARPD.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(ARPD.dblAmountPaid, 0) < 0
										THEN ISNULL(ARPD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
        , I.dblAmountDue		 
        , dblDiscount			= ISNULL(I.dblDiscount, 0)
		, dblInterest			= ISNULL(I.dblInterest, 0)
        , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
        , I.intEntityCustomerId
        , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 THEN 'Over 90' END
        , dblAvailableCredit	= 0 
		, dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
    LEFT JOIN ARPAYMENTDETAILS ARPD ON I.intInvoiceId = ARPD.intInvoiceId
	LEFT JOIN APPAYMENTDETAILS APPD ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN PREPAIDSINVOICES PC ON I.intInvoiceId = PC.intInvoiceId
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal        
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')
	AND ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))

UNION ALL

SELECT dtmPostDate			= NULL
     , intInvoiceId			= CB.intCustomerBudgetId
	 , dblAmountPaid		= CB.dblAmountPaid
	 , dblInvoiceTotal		= CB.dblBudgetAmount
     , dblAmountDue			= CB.dblBudgetAmount - CB.dblAmountPaid
     , dblDiscount			= 0
	 , dblInterest			= 0
     , strTransactionType	= 'Customer Budget'  
     , intEntityCustomerId	= CB.intEntityCustomerId      
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 0 THEN 'Current'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				WHEN DATEDIFF(DAYOFYEAR, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), @dtmDateToLocal) > 90 THEN 'Over 90' END    
    , dblAvailableCredit	= 0 
	, dblPrepayments		= 0
FROM tblARCustomerBudget CB	
	LEFT JOIN (SELECT intEntityCustomerId
					, ysnCustomerBudgetTieBudget
			   FROM tblARCustomer 
	) CUST ON CB.intEntityCustomerId = CUST.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND CB.dblAmountPaid < CB.dblBudgetAmount 
	AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

) AS A  

LEFT JOIN
          
(SELECT DISTINCT 
      intEntityCustomerId
    , intInvoiceId  
    , dblInvoiceTotal
    , dblAmountPaid
    , (dblInvoiceTotal) - (dblAmountPaid) - (dblDiscount) + (dblInterest) AS dblTotalDue
    , dblDiscount
	, dblInterest
    , dblAvailableCredit
	, dblPrepayments
    , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 0
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl0Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 10
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl10Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 30
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl30Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 60    
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl60Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 90     
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl90Days
	, CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90      
			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl91Days
FROM
(SELECT I.intInvoiceId
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
      , dblAmountDue		= 0    
      , dblDiscount			= 0    
	  , dblInterest			= 0    
      , I.dtmDueDate    
      , I.intEntityCustomerId
      , dblAvailableCredit	= 0
	  , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Invoice', 'Debit Memo')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    	
	AND ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
     , dblAmountDue			= 0    
     , dblDiscount			= 0    
	 , dblInterest			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN INVOICETOTALPAYMENT PD ON I.intInvoiceId = PD.intInvoiceId 
	LEFT JOIN PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')) OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    		
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')

UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
     , dblAmountDue			= 0    
     , dblDiscount			= 0    
	 , dblInterest			= 0    
     , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intEntityCustomerId
     , dblAvailableCredit	= 0
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN ARPOSTEDPAYMENT P ON I.intPaymentId = P.intPaymentId 
	LEFT JOIN INVOICETOTALPREPAYMENTS PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN PREPAIDS PC ON I.intInvoiceId = PC.intPrepaymentId 
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND ((@ysnIncludeCreditsLocal = 1 AND I.strTransactionType = 'Customer Prepayment') OR (@ysnIncludeCreditsLocal = 0 AND I.strTransactionType = 'EXCLUDE CREDITS'))    
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    		
    AND I.intAccountId IN (SELECT intAccountId FROM GLACCOUNTS)
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')
	                                          
UNION ALL

SELECT I.intInvoiceId
     , dblAmountPaid            = 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0     
     , dtmDueDate               = P.dtmDatePaid
     , I.intEntityCustomerId
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARPayment P WITH (NOLOCK)
    LEFT JOIN PAYMENTDETAIL PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN POSTEDINVOICES I ON PD.intInvoiceId = I.intInvoiceId AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))    	
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal   

UNION ALL      
            
SELECT I.intInvoiceId
     , dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
								THEN 
									CASE WHEN ISNULL(ARPD.dblAmountPaid, 0) + ISNULL(APPD.dblAmountPaid, 0) < 0 
										THEN ISNULL(ARPD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
										ELSE 0 
									END 
								ELSE ISNULL(ARPD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
							  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
    , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(ARPD.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(ARPD.dblAmountPaid, 0) < 0
										THEN ISNULL(ARPD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
    , dblAmountDue			= 0
    , dblDiscount			= ISNULL(ARPD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
	, dblInterest			= ISNULL(ARPD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
    , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
    , I.intEntityCustomerId
    , dblAvailableCredit	= 0
	, dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
    LEFT JOIN ARPAYMENTDETAILS ARPD ON I.intInvoiceId = ARPD.intInvoiceId
	LEFT JOIN APPAYMENTDETAILS APPD ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN PREPAIDSINVOICES PC ON I.intInvoiceId = PC.intInvoiceId
    LEFT JOIN SALESPERSON SP ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN COMPANYLOCATION CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted  = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	AND (@strSalespersonLocal IS NULL OR SP.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR strLocationName LIKE '%'+@strCompanyLocationLocal+'%')
	AND ((@ysnIncludeCreditsLocal = 0 AND strTransactionType IN ('Invoice', 'Debit Memo')) OR (@ysnIncludeCreditsLocal = 1))

UNION ALL

SELECT intInvoiceId			= CB.intCustomerBudgetId
     , dblAmountPaid		= CB.dblAmountPaid
     , dblInvoiceTotal		= CB.dblBudgetAmount
     , dblAmountDue			= CB.dblBudgetAmount - CB.dblAmountPaid
     , dblDiscount			= 0
	 , dblInterest			= 0
     , dtmDueDate			= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
     , intEntityCustomerId	= CB.intEntityCustomerId
     , dblAvailableCredit	= 0
	 , dblPrepayments		= 0
FROM tblARCustomerBudget CB	
	LEFT JOIN (SELECT intEntityCustomerId
					, ysnCustomerBudgetTieBudget
			   FROM tblARCustomer 
	) CUST ON CB.intEntityCustomerId = CUST.intEntityCustomerId
WHERE CB.dtmBudgetDate BETWEEN @dtmDateFrom AND @dtmDateTo
	AND CB.dblAmountPaid < CB.dblBudgetAmount 
	AND (@ysnIncludeBudgetLocal = 1 OR CUST.ysnCustomerBudgetTieBudget = 1)

) AS TBL) AS B
          
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.dblPrepayments	 = B.dblPrepayments

WHERE
	(A.intEntityCustomerId = @intEntityCustomerIdLocal AND ISNULL(@intEntityCustomerIdLocal, 0) <> 0)
	OR ISNULL(@intEntityCustomerIdLocal, 0) = 0
GROUP BY A.intEntityCustomerId) AS AGING

LEFT JOIN (SELECT intEntityCustomerId
				 , dblCreditLimit 
			FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON AGING.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN (SELECT intEntityId
			     , strName
				 , strEntityNo 
			FROM tblEMEntity WITH (NOLOCK)
) E ON C.intEntityCustomerId = E.intEntityId
WHERE ISNULL(AGING.intEntityCustomerId, 0) > 0
ORDER BY strCustomerName