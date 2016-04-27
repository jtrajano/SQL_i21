﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailAsOfDateReport]
	@dtmDateFrom		DATETIME = NULL,
	@dtmDateTo			DATETIME = NULL,
	@strSalesperson		NVARCHAR(100) = NULL
AS

IF @dtmDateFrom IS NULL
    SET @dtmDateFrom = CAST(-53690 AS DATETIME)

IF @dtmDateTo IS NULL
    SET @dtmDateTo = GETDATE()

IF RTRIM(LTRIM(@strSalesperson)) = ''
    SET @strSalesperson = NULL

SELECT A.strInvoiceNumber
     , A.strRecordNumber
     , A.intInvoiceId
	 , A.strCustomerName
	 , A.strBOLNumber
	 , A.intEntityCustomerId
	 , A.strCustomerNumber
	 , dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , dblTotalAR			= B.dblTotalDue - B.dblAvailableCredit
	 , dblFuture			= 0.000000
	 , dbl0Days				= B.dbl0Days
	 , dbl10Days			= B.dbl10Days
	 , dbl30Days			= B.dbl30Days
	 , dbl60Days			= B.dbl60Days
	 , dbl90Days			= B.dbl90Days
	 , dbl91Days			= B.dbl91Days
	 , dblTotalDue			= B.dblTotalDue - B.dblAvailableCredit
	 , dblAmountPaid		= A.dblAmountPaid
	 , dblInvoiceTotal		= A.dblInvoiceTotal
	 , dblCredits			= B.dblAvailableCredit
	 , dblPrepaids			= 0.000000
	 , dtmDate				= ISNULL(B.dtmDatePaid, A.dtmDate)
	 , dtmDueDate	 
	 , dtmAsOfDate			= @dtmDateTo
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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 90 THEN 'Over 90' END
	, I.ysnPosted
	, dblAvailableCredit = 0
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId    
WHERE I.ysnPosted = 1
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.strTransactionType = 'Invoice'
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
  AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateTo) > 90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
			GROUP BY intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
 AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
      
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
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateTo) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit        = ISNULL(PD.dblPayment, 0)
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateTo
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
                                    INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
                                    WHERE AG.strAccountGroup = 'Receivables')
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
  AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')  

UNION ALL      
      
SELECT DISTINCT
       dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , P.strRecordNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , P.intPaymentId
	 , I.strBOLNumber
	 , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) END
     , dblInvoiceTotal		= 0    
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
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) > 90 THEN 'Over 90' END
     , ysnPosted			= ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit	= 0 
FROM tblARInvoice I 
	 INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
	 INNER JOIN tblEntity E ON E.intEntityId = C.intEntityCustomerId    
	 INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	 LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) BETWEEN @dtmDateFrom AND @dtmDateTo) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo 
 AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')) AS A    

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
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 0
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 0  AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 10
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 30
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 60    
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) <= 90     
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl90Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, @dtmDateTo) > 90      
  			THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl91Days 
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
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Invoice'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
 AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')

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
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo
			GROUP BY intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo
 AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')
						      
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
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateTo
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
                                    INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
                                    WHERE AG.strAccountGroup = 'Receivables')
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo    
  AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')

UNION ALL      
      
SELECT DISTINCT
    I.strInvoiceNumber
  , I.intInvoiceId
  , P.intPaymentId
  , I.strBOLNumber
  , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) END
  , dblInvoiceTotal		= 0
  , dblAmountDue		= 0
  , dblDiscount			= ISNULL(PD.dblDiscount, 0)
  , dblInterest			= ISNULL(PD.dblInterest, 0)
  , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
  , P.dtmDatePaid
  , I.intEntityCustomerId
  , dblAvailableCredit	= 0
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFrom AND @dtmDateTo) ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblARSalesperson SP INNER JOIN tblEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFrom AND @dtmDateTo 
 AND (@strSalesperson IS NULL OR ES.strName LIKE '%'+@strSalesperson+'%')
 AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
										INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
										WHERE AG.strAccountGroup = 'Receivables')) AS TBL) AS B   
    
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.intPaymentId		 = B.intPaymentId