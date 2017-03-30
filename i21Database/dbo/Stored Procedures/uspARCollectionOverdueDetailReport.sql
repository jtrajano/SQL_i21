CREATE PROCEDURE [dbo].[uspARCollectionOverdueDetailReport]
	@dtmDateFrom		DATETIME = NULL,
	@dtmDateTo			DATETIME = NULL,
	@strSalesperson		NVARCHAR(100) = NULL
	
AS

DECLARE @dtmDateFromLocal			DATETIME,  
		@dtmDateToLocal				DATETIME,  
		@strSalespersonLocal		NVARCHAR(100)  
				
SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo
SET @strSalespersonLocal		= @strSalesperson

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE()

IF RTRIM(LTRIM(@strSalespersonLocal)) = ''
    SET @strSalespersonLocal = NULL

SET NOCOUNT ON;
SELECT A.strInvoiceNumber
     , A.strRecordNumber
     , A.intInvoiceId
	 , A.strCustomerName
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , A.strCustomerNumber
	 , dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WHERE [intEntityId] = A.intEntityCustomerId)
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit
	 , dblFuture			= 0.000000
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl120Days			= B.dbl120Days
	 , dbl121Days			= B.dbl121Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit
	 , dblAmountPaid		= A.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit * -1
	 , dblPrepaids			= 0.000000
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , dtmAsOfDate			= @dtmDateToLocal
	 , strSalespersonName	= 'strSalespersonName'
	 , intCompanyLocationId	 
FROM
(SELECT dtmDate				= I.dtmPostDate
	 , I.strInvoiceNumber
	 , strRecordNumber		= NULL
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= 0
	 , I.strBOLNumber
	 , dblAmountPaid		= 0
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , dblAmountDue			= ISNULL(I.dblAmountDue,0)
	 , dblDiscount			= 0
	 , dblInterest			= 0
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , I.intTermId
	 , T.intBalanceDue    
     , strCustomerName		= E.strName
	 , strCustomerNumber	= C.strCustomerNumber
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days' 
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId
	INNER JOIN tblEMEntity E ON E.intEntityId = C.[intEntityId]
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]    
WHERE I.ysnPosted = 1
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
  AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
  AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL
						
SELECT dtmDate				= ISNULL(P.dtmDatePaid, I.dtmPostDate)
	 , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , intPaymentId			= 0
	 , I.strBOLNumber
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= 0
	 , dblAmountDue			= 0    
	 , dblDiscount			= 0
	 , dblInterest			= 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	 , I.intTermId
	 , T.intBalanceDue
	 , strCustomerName		= E.strName
	 , strCustomerNumber	= C.strCustomerNumber
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 120 THEN '91 - 120 Days'  
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 120 THEN 'Over 120' END
	 , I.ysnPosted
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId
	INNER JOIN tblEMEntity E ON E.intEntityId = C.[intEntityId]
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
      
UNION ALL

SELECT P.dtmDatePaid
     , I.strInvoiceNumber
     , P.strRecordNumber
     , I.intCompanyLocationId
     , I.intInvoiceId
     , intPaymentId				= 0
     , I.strBOLNumber
     , dblAmountPaid			= 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0
     , I.strTransactionType           
     , I.intEntityCustomerId
     , dtmDueDate               = P.dtmDatePaid
     , I.intTermId
     , T.intBalanceDue
     , strCustomerName          = E.strName
     , strCustomerNumber		= C.strCustomerNumber
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
					  WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 120 THEN '91 - 120 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 120 THEN 'Over 120' END
     , I.ysnPosted
     , dblAvailableCredit        = ISNULL(PD.dblPayment, 0)
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateToLocal
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.[intEntityId]
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
  AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
  AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')  

UNION ALL      
      
SELECT DISTINCT
       dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , P.intPaymentId
	 , I.strBOLNumber	 
	 , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) END
     , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) THEN I.dblInvoiceTotal * -1 ELSE 0 END   
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)
	 , dblInterest			= ISNULL(I.dblInterest, 0)
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
	 , T.intTermID
     , intBalanceDue		= ISNULL(T.intBalanceDue, 0)    
     , strCustomerName		= ISNULL(E.strName, '')
	 , strCustomerNumber	= C.strCustomerNumber
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 120 THEN '91 - 120 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 120 THEN 'Over 120' END
     , ysnPosted			= ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit	= 0 
FROM tblARInvoice I 
	 INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId 
	 INNER JOIN tblEMEntity E ON E.intEntityId = C.[intEntityId]    
	 INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	 LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = APPD.intInvoiceId
	 LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	 LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblAPPaymentDetail PD INNER JOIN tblAPPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	 LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal 
 AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) - ISNULL(TOTALSETTLEMENT.dblPayment, 0) <> 0
 AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) AS A    

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , strInvoiceNumber
  , intInvoiceId
  , intPaymentId  
  , strBOLNumber
  , dblInvoiceTotal
  , dblAmountPaid
  , dtmDatePaid
  , (dblInvoiceTotal) - (dblAmountPaid) - (dblDiscount) + (dblInterest) AS dblTotalDue
  , dblDiscount
  , dblInterest
  , dblAvailableCredit  
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
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 90 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) <= 120     
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl120Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateToLocal) > 120      
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl121Days 
FROM
(SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , intPaymentId		= 0
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
	  , dblAmountDue		= 0    
	  , dblDiscount			= 0
	  , dblInterest			= 0   
	  , I.dtmDueDate
	  , dtmDatePaid			= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId    
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Invoice', 'Debit Memo')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
 AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , intPaymentId		= 0
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= 0
	  , dblAmountDue		= 0    
	  , dblDiscount			= 0
	  , dblInterest			= 0    
	  , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	  , dtmDatePaid			= NULL
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
						      
UNION ALL

SELECT I.strInvoiceNumber
     , I.intInvoiceId
     , intPaymentId             = 0
     , I.strBOLNumber
     , dblAmountPaid            = 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0     
     , dtmDueDate               = P.dtmDatePaid
     , dtmDatePaid				= P.dtmDatePaid
     , I.intEntityCustomerId
     , dblAvailableCredit		= ISNULL(PD.dblPayment, 0)
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateToLocal
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    
  AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) <> 0
  AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')

UNION ALL      
      
SELECT DISTINCT
    I.strInvoiceNumber
  , I.intInvoiceId
  , P.intPaymentId
  , I.strBOLNumber
  , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) END
  , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) THEN I.dblInvoiceTotal * -1 ELSE 0 END
  , dblAmountDue		= 0
  , dblDiscount			= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
  , dblInterest			= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , P.dtmDatePaid
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.[intEntityId] = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (
		(SELECT SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest) AS dblPayment
			  , intInvoiceId 
			FROM tblAPPaymentDetail PD INNER JOIN tblAPPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= @dtmDateToLocal
			GROUP BY intInvoiceId)
		) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.[intEntityId] = ES.intEntityId) ON I.intEntitySalespersonId = SP.[intEntityId]	
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal 
 AND I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0) - ISNULL(TOTALSETTLEMENT.dblPayment, 0) <> 0
 AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) AS TBL) AS B    

ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.intPaymentId		 = B.intPaymentId

WHERE B.dblTotalDue - B.dblAvailableCredit <> 0

SET NOCOUNT OFF;