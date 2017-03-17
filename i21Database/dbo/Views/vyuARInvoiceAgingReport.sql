CREATE VIEW [dbo].[vyuARInvoiceAgingReport]
AS
SELECT AGING.*
     , dblCreditLimit			= C.dblCreditLimit
     , strShipToLocation		= dbo.fnARFormatCustomerAddress(NULL, NULL, SHIPTOLOCATION.strLocationName, SHIPTOLOCATION.strAddress, SHIPTOLOCATION.strCity, SHIPTOLOCATION.strState, SHIPTOLOCATION.strZipCode, SHIPTOLOCATION.strCountry, NULL, 0)
	 , strBillToLocation		= dbo.fnARFormatCustomerAddress(NULL, NULL, BILLTOLOCATION.strLocationName, BILLTOLOCATION.strAddress, BILLTOLOCATION.strCity, BILLTOLOCATION.strState, BILLTOLOCATION.strZipCode, BILLTOLOCATION.strCountry, NULL, 0)
	 , strDefaultLocation		= dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTLOCATION.strLocationName, DEFAULTLOCATION.strAddress, DEFAULTLOCATION.strCity, DEFAULTLOCATION.strState, DEFAULTLOCATION.strZipCode, DEFAULTLOCATION.strCountry, NULL, 0)
	 , strDefaultShipTo			= dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTSHIPTO.strLocationName, DEFAULTSHIPTO.strAddress, DEFAULTSHIPTO.strCity, DEFAULTSHIPTO.strState, DEFAULTSHIPTO.strZipCode, DEFAULTSHIPTO.strCountry, NULL, 0)
	 , strDefaultBillTo			= dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTBILLTO.strLocationName, DEFAULTBILLTO.strAddress, DEFAULTBILLTO.strCity, DEFAULTBILLTO.strState, DEFAULTBILLTO.strZipCode, DEFAULTBILLTO.strCountry, NULL, 0)
	 , intCurrencyId			= INVOICE.intCurrencyId
	 , strCurrency				= CUR.strCurrency
	 , strCurrencyDescription	= CUR.strDescription
	 , strCustomerName			= C.strName
FROM 
(SELECT A.strInvoiceNumber
     , A.intInvoiceId
	 , A.strBOLNumber
	 , A.intEntityCustomerId     
	 , dblTotalAR			= SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
	 , dblFuture			= 0.000000
	 , dbl0Days				= SUM(B.dbl0Days)
	 , dbl10Days			= SUM(B.dbl10Days)
	 , dbl30Days			= SUM(B.dbl30Days)
	 , dbl60Days			= SUM(B.dbl60Days)
	 , dbl90Days			= SUM(B.dbl90Days)
	 , dbl91Days			= SUM(B.dbl91Days)
	 , dblTotalDue			= SUM(B.dblTotalDue)- SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
	 , dblAmountPaid		= SUM(A.dblAmountPaid)
	 , dblInvoiceTotal		= SUM(A.dblInvoiceTotal)
	 , dblCredits			= SUM(B.dblAvailableCredit) * -1
	 , dblPrepayments		= SUM(B.dblPrepayments) * -1
	 , dblPrepaids			= SUM(B.dblPrepayments) * -1
	 , A.dtmDate
	 , A.dtmDueDate
	 , A.intCompanyLocationId
FROM
(SELECT dtmDate				= I.dtmPostDate
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
	 , dblAmountPaid		= 0
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , dblAmountDue			= ISNULL(I.dblAmountDue,0)
	 , dblDiscount			= 0
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , I.intTermId	 
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
	, I.ysnPosted
	, dblAvailableCredit	= 0
	, dblPrepayments		= 0
FROM tblARInvoice I	
WHERE I.ysnPosted = 1
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) <= GETDATE()
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL
						
SELECT dtmDate					= ISNULL(P.dtmDatePaid, I.dtmPostDate)
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
     , dblAmountPaid			= 0
     , dblInvoiceTotal			= 0
	 , dblAmountDue				= 0
	 , dblDiscount				= 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblAvailableCredit		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments			= 0
FROM tblARInvoice I	
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		(SELECT intPrepaymentId
		     , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
		) PC ON I.intInvoiceId = PC.intPrepaymentId	
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL
						
SELECT dtmDate					= ISNULL(P.dtmDatePaid, I.dtmPostDate)
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
     , dblAmountPaid			= 0
     , dblInvoiceTotal			= 0
	 , dblAmountDue				= 0
	 , dblDiscount				= 0
	 , I.strTransactionType	  
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblAvailableCredit		= 0
	 , dblPrepayments			= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM tblARInvoice I	
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
        (SELECT intPrepaymentId
             , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
            FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
            GROUP BY intPrepaymentId)
        ) PC ON I.intInvoiceId = PC.intPrepaymentId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT P.dtmDatePaid
     , I.strInvoiceNumber     
     , I.intCompanyLocationId
     , I.intInvoiceId
	 , I.strBOLNumber
     , dblAmountPaid			= 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , I.strTransactionType           
     , I.intEntityCustomerId
     , dtmDueDate               = P.dtmDatePaid
     , I.intTermId
     , strAge = CASE  WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > GETDATE()
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
        
UNION ALL      
      
SELECT dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
	 , dblAmountPaid		= ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
     , dblInvoiceTotal		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
										THEN ISNULL(PD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)    
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , I.intTermId
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
     , ysnPosted			= ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit	= 0 
	 , dblPrepayments		= 0
FROM tblARInvoice I 	 
	 LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) <= GETDATE()) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) <= GETDATE()) ON I.intInvoiceId = APPD.intInvoiceId
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
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE() 
 ) AS A    

LEFT JOIN
    
(SELECT DISTINCT 
	intEntityCustomerId
  , strInvoiceNumber
  , intInvoiceId  
  , strBOLNumber
  , dblInvoiceTotal
  , dblAmountPaid
  , (dblInvoiceTotal) - (dblAmountPaid) - (dblDiscount) + (dblInterest) AS dblTotalDue
  , dblDiscount
  , dblInterest
  , dblAvailableCredit
  , dblPrepayments
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 0
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 0 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 10
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 30
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 60    
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 90     
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 90      
	     THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl91Days    
FROM
(SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , I.strBOLNumber
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
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Invoice', 'Debit Memo')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= 0
	  , dblAmountDue		= 0
	  , dblDiscount			= 0
	  , dblInterest			= 0
	  , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	  , dblPrepayments		= 0
FROM tblARInvoice I	
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		(SELECT intPrepaymentId
		     , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
			FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
		) PC ON I.intInvoiceId = PC.intPrepaymentId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND I.dblInvoiceTotal - (ISNULL(PD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)) <> 0
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT I.strInvoiceNumber
	  , I.intInvoiceId
	  , I.strBOLNumber
      , dblAmountPaid		= 0
      , dblInvoiceTotal		= 0
	  , dblAmountDue		= 0
	  , dblDiscount			= 0
	  , dblInterest			= 0
	  , dtmDueDate			= ISNULL(P.dtmDatePaid, I.dtmDueDate)
	  , I.intEntityCustomerId
	  , dblAvailableCredit	= 0
	  , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM tblARInvoice I	
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND P.ysnInvoicePrepayment = 0 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
        (SELECT intPrepaymentId
             , SUM(dblAppliedInvoiceAmount) AS dblAppliedInvoiceAmount
            FROM tblARPrepaidAndCredit WHERE ysnApplied = 1
            GROUP BY intPrepaymentId)
        ) PC ON I.intInvoiceId = PC.intPrepaymentId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT I.strInvoiceNumber
     , I.intInvoiceId
     , I.strBOLNumber
     , dblAmountPaid            = 0
     , dblInvoiceTotal          = 0
     , dblAmountDue             = 0 
     , dblDiscount              = 0
     , dblInterest              = 0     
     , dtmDueDate               = P.dtmDatePaid
     , I.intEntityCustomerId
     , dblAvailableCredit		= ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > GETDATE()
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
  						      
UNION ALL      
      
SELECT I.strInvoiceNumber
  , I.intInvoiceId
  , I.strBOLNumber
  , dblAmountPaid			= ISNULL(PD.dblPayment,0) + ISNULL(APPD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)
  , dblInvoiceTotal			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) = (I.dblInvoiceTotal * -1) 
								THEN I.dblInvoiceTotal * -1 
								ELSE 
									CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment') AND ISNULL(P.dblAmountPaid, 0) < 0
										THEN ISNULL(PD.dblInvoiceTotal, 0)
										ELSE 0
									END
							  END
  , dblAmountDue			= 0
  , dblDiscount				= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
  , dblInterest				= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
  , dtmDueDate				= ISNULL(I.dtmDueDate, GETDATE())
  , I.intEntityCustomerId
  , dblAvailableCredit		= 0
  , dblPrepayments			= 0
FROM tblARInvoice I 	
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()) ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APPD.intPaymentId = APP.intPaymentId AND APP.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), APP.dtmDatePaid ))) <= GETDATE()) ON I.intInvoiceId = APPD.intInvoiceId
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
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE() 
 ) AS TBL) AS B   
    
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
AND A.dblInvoiceTotal	 = B.dblInvoiceTotal
AND A.dblAmountPaid		 = B.dblAmountPaid
AND A.dblAvailableCredit = B.dblAvailableCredit
AND A.dblPrepayments	 = B.dblPrepayments

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0

GROUP BY A.strInvoiceNumber, A.intInvoiceId, A.strBOLNumber, A.intEntityCustomerId, A.dtmDate, A.dtmDueDate, A.intCompanyLocationId) AS AGING
INNER JOIN vyuARCustomer C ON AGING.intEntityCustomerId = C.intEntityCustomerId
INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
LEFT JOIN tblARInvoice INVOICE ON AGING.intInvoiceId = INVOICE.intInvoiceId
LEFT JOIN tblEMEntityLocation SHIPTOLOCATION ON INVOICE.intShipToLocationId = SHIPTOLOCATION.intEntityLocationId AND INVOICE.intEntityCustomerId = SHIPTOLOCATION.intEntityId
LEFT JOIN tblEMEntityLocation BILLTOLOCATION ON INVOICE.intBillToLocationId = BILLTOLOCATION.intEntityLocationId AND INVOICE.intEntityCustomerId = BILLTOLOCATION.intEntityId
LEFT JOIN tblEMEntityLocation DEFAULTLOCATION ON AGING.intEntityCustomerId = DEFAULTLOCATION.intEntityId AND DEFAULTLOCATION.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation DEFAULTSHIPTO ON C.intShipToId = DEFAULTSHIPTO.intEntityLocationId AND C.intEntityCustomerId = DEFAULTSHIPTO.intEntityId
LEFT JOIN tblEMEntityLocation DEFAULTBILLTO ON C.intBillToId = DEFAULTBILLTO.intEntityLocationId AND C.intEntityCustomerId = DEFAULTBILLTO.intEntityId
LEFT JOIN
	(SELECT intCurrencyID
		  , strCurrency
		  , strDescription
		FROM dbo.tblSMCurrency
	 ) CUR ON INVOICE.intCurrencyId = CUR.intCurrencyID
WHERE INVOICE.ysnPaid = 0
AND AGING.intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE strTransactionType NOT IN ('Cash', 'Cash Refund'))
