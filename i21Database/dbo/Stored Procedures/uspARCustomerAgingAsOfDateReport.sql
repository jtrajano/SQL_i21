﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingAsOfDateReport]
	@dtmDateFrom			DATETIME = NULL,
	@dtmDateTo				DATETIME = NULL,
	@strSalesperson			NVARCHAR(100) = NULL,
	@intEntityCustomerId	INT = NULL,
	@strSourceTransaction	NVARCHAR(100) = NULL,
	@strCompanyLocation		NVARCHAR(100) = NULL
AS

DECLARE @dtmDateFromLocal			DATETIME		= NULL,
	    @dtmDateToLocal				DATETIME		= NULL,
	    @strSalespersonLocal		NVARCHAR(100)	= NULL,
	    @intEntityCustomerIdLocal	INT				= NULL,
		@strSourceTransactionLocal	NVARCHAR(100)	= NULL,
		@strCompanyLocationLocal    NVARCHAR(100)	= NULL

SET @dtmDateFromLocal			= @dtmDateFrom
SET	@dtmDateToLocal				= @dtmDateTo
SET @strSalespersonLocal		= @strSalesperson
SET @intEntityCustomerIdLocal   = @intEntityCustomerId
SET @strSourceTransactionLocal  = @strSourceTransaction
SET @strCompanyLocationLocal  = @strCompanyLocation

IF @dtmDateFromLocal IS NULL
    SET @dtmDateFromLocal = CAST(-53690 AS DATETIME)

IF @dtmDateToLocal IS NULL
    SET @dtmDateToLocal = GETDATE()

IF RTRIM(LTRIM(@strSalespersonLocal)) = ''
    SET @strSalespersonLocal = NULL

IF RTRIM(LTRIM(@strSourceTransactionLocal)) = ''
    SET @strSourceTransactionLocal = NULL

IF RTRIM(LTRIM(@strCompanyLocationLocal)) = ''
	SET @strCompanyLocationLocal = NULL

SELECT A.strCustomerName
     , A.strEntityNo
     , A.intEntityCustomerId
     , dblCreditLimit       = (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
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
     , dblPrepaids          = 0.000000
     , dtmAsOfDate          = @dtmDateToLocal
     , strSalespersonName   ='strSalespersonName' 
	 , strSourceTransaction	= @strSourceTransactionLocal
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
      , I.dtmDueDate    
      , I.intTermId
      , T.intBalanceDue    
      , strCustomerName			= E.strName
      , E.strEntityNo   
	  , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	    			  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 THEN 'Over 90' END    
      , I.ysnPosted
      , dblAvailableCredit		= 0
	  , dblPrepayments			= 0
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId 
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Invoice', 'Debit Memo')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')

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
     , dtmDueDate				= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intTermId
     , T.intBalanceDue
     , strCustomerName			= E.strName
     , E.strEntityNo
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments			= 0
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		(SELECT intPrepaymentId
		     , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
		) PC ON I.intInvoiceId = PC.intPrepaymentId	
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')

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
     , dtmDueDate				= ISNULL(P.dtmDatePaid, I.dtmDueDate)
     , I.intTermId
     , T.intBalanceDue
     , strCustomerName			= E.strName
     , E.strEntityNo
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 0 THEN 'Current'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 				 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), @dtmDateToLocal) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit		= 0
	 , dblPrepayments			= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType = 'Customer Prepayment'
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')                                   

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
     , dtmDueDate               = P.dtmDatePaid
     , I.intTermId
     , T.intBalanceDue
     , strCustomerName          = E.strName
     , E.strEntityNo
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, @dtmDateToLocal) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateToLocal
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
  AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
  AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
  AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
                                     
UNION ALL      
      
SELECT I.dtmPostDate      
        , I.intInvoiceId
		, dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
								THEN 
									CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 
										THEN ISNULL(PD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
										ELSE 0 
									END 
								ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
							  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
	    , dblInvoiceTotal	= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
										THEN ISNULL(PD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
        , I.dblAmountDue		 
        , dblDiscount			= ISNULL(I.dblDiscount, 0)
		, dblInterest			= ISNULL(I.dblInterest, 0)
        , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
        , I.intEntityCustomerId
        , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
        , T.intTermID
        , intBalanceDue			= ISNULL(T.intBalanceDue, 0)    
        , strCustomerName		= ISNULL(E.strName, '')
        , strEntityNo			= ISNULL(E.strEntityNo, '')
        , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 0 THEN 'Current'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 10 THEN '1 - 10 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 30 THEN '11 - 30 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 60 THEN '31 - 60 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) <= 90 THEN '61 - 90 Days'
	 					WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateToLocal) > 90 THEN 'Over 90' END
        , ysnPosted				= ISNULL(I.ysnPosted, 1)
        , dblAvailableCredit	= 0 
		, dblPrepayments		= 0
FROM tblARInvoice I 
        INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
        INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId    
        INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
        LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = PD.intInvoiceId
		LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = APPD.intInvoiceId
		LEFT JOIN (
			(SELECT PC.intInvoiceId
				  , I.strInvoiceNumber
				  , PC.intPrepaymentId
				  , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
				FROM tblARPrepaidAndCredit PC
					INNER JOIN tblARInvoice I ON I.intInvoiceId = PC.intPrepaymentId
				WHERE ysnApplied = 1
				GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber)
			) PC ON I.intInvoiceId = PC.intInvoiceId
        LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
		LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	    
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
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
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Invoice', 'Debit Memo')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')

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
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId 
	LEFT JOIN (
		(SELECT intPrepaymentId
		     , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
		) PC ON I.intInvoiceId = PC.intPrepaymentId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')

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
	 , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
FROM tblARInvoice I
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId 
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND I.strTransactionType = 'Customer Prepayment'
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
    AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
                                          
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
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId 
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > @dtmDateToLocal
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal   
  AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
  AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	
  AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')

UNION ALL      
            
SELECT I.intInvoiceId
     , dblAmountPaid		= (CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') 
								THEN 
									CASE WHEN ISNULL(P.dblAmountPaid, 0) + ISNULL(APP.dblAmountPaid, 0) < 0 
										THEN ISNULL(PD.dblPayment, 0) + ISNULL(APPD.dblPayment, 0) 
										ELSE 0 
									END 
								ELSE ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) 
							  END) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
    , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
										THEN ISNULL(PD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
    , dblAmountDue			= 0
    , dblDiscount			= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
	, dblInterest			= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
    , dtmDueDate			= ISNULL(I.dtmDueDate, GETDATE())
    , I.intEntityCustomerId
    , dblAvailableCredit	= 0
	, dblPrepayments		= 0
FROM tblARInvoice I 
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
    LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal) ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN (
		(SELECT PC.intInvoiceId
		      , I.strInvoiceNumber
			  , PC.intPrepaymentId
		      , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit PC
				INNER JOIN tblARInvoice I ON I.intInvoiceId = PC.intPrepaymentId
			WHERE ysnApplied = 1
			GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber)
		) PC ON I.intInvoiceId = PC.intInvoiceId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
	LEFT JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
WHERE I.ysnPosted  = 1
    AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
    AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) BETWEEN @dtmDateFromLocal AND @dtmDateToLocal    
    AND (@strSalespersonLocal IS NULL OR ES.strName LIKE '%'+@strSalespersonLocal+'%')
	AND (@strCompanyLocationLocal IS NULL OR CL.strLocationName LIKE '%'+@strCompanyLocationLocal+'%')	    
	AND (@strSourceTransactionLocal IS NULL OR I.strType LIKE '%'+@strSourceTransactionLocal+'%')
	) AS TBL) AS B
          
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.dblPrepayments	 = B.dblPrepayments

WHERE
	(A.intEntityCustomerId = @intEntityCustomerIdLocal AND ISNULL(@intEntityCustomerIdLocal,0) <> 0)
	OR
	ISNULL(@intEntityCustomerIdLocal,0) = 0

GROUP BY A.strCustomerName, A.intEntityCustomerId, A.strEntityNo
