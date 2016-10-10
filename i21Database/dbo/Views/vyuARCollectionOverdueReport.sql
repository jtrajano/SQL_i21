﻿CREATE VIEW [dbo].[vyuARCollectionOverdueReport]
AS
SELECT
	 intCompanyLocationId		= (SELECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
	 , strCompanyName			= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress		= (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) FROM tblSMCompanySetup)
	 , strCompanyPhone			= (SELECT TOP 1 strPhone FROM tblSMCompanySetup)
	 , A.intEntityCustomerId    
	 , Cus.strCustomerNumber	  
	 , A.strCustomerName
	 , strCustomerAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, E.strName, NULL)
	 , strCustomerPhone			= EnPhoneNo.strPhone 
	 , A.strInvoiceNumber
     , A.intInvoiceId
	 , intTermsId				= A.intTermId 	 
	 , A.strBOLNumber	 
	 , A.dblCreditLimit
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
	 , dblInvoiceTotal
	 , dblCredits
	 , dblPrepaids
	 , dtmDate
	 , dtmDueDate
	 , strAccountNumber		= (SELECT strAccountNumber FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId) 
FROM 
(
SELECT A.strInvoiceNumber
     , A.intInvoiceId
	 , A.strCustomerName
	 , A.strBOLNumber
	 , A.intEntityCustomerId     
	 , dblCreditLimit		= (SELECT dblCreditLimit FROM tblARCustomer WHERE intEntityCustomerId = A.intEntityCustomerId)
	 , dblTotalAR			= SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit)
	 , dblFuture			= 0.000000
	 , dbl0Days				= SUM(B.dbl0Days)
	 , dbl10Days			= SUM(B.dbl10Days)
	 , dbl30Days			= SUM(B.dbl30Days)
	 , dbl60Days			= SUM(B.dbl60Days)
	 , dbl90Days			= SUM(B.dbl90Days)
	 , dbl91Days			= SUM(B.dbl91Days)
	 , dblTotalDue			= SUM(B.dblTotalDue)- SUM(B.dblAvailableCredit)
	 , dblAmountPaid		= SUM(A.dblAmountPaid)
	 , dblInvoiceTotal		= SUM(A.dblInvoiceTotal)
	 , dblCredits			= SUM(B.dblAvailableCredit) * -1
	 , dblPrepaids			= 0.000000
	 , dtmDate
	 , dtmDueDate
	 , intCompanyLocationId  
	 , A.intTermId
	
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
	 , T.intBalanceDue    
     , strCustomerName		= E.strName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
	, I.ysnPosted
	, dblAvailableCredit = 0	    
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId    
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
	 , T.intBalanceDue
	 , strCustomerName			= E.strName
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 90 THEN 'Over 90' END
	 , I.ysnPosted
	 , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)      
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
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
     , T.intBalanceDue
     , strCustomerName          = E.strName
     , strAge = CASE  WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 90 THEN 'Over 90' END
     , I.ysnPosted
     , dblAvailableCredit        = ISNULL(PD.dblPayment, 0)	 	 
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1 
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > GETDATE()
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId
    INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
        
UNION ALL      
      
SELECT dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
	 , dblAmountPaid		= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) END
     , dblInvoiceTotal		= 0    
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)    
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , I.dtmDueDate
	 , T.intTermID
     , intBalanceDue		= ISNULL(T.intBalanceDue, 0)    
     , strCustomerName		= ISNULL(E.strName, '')
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
     , ysnPosted			= ISNULL(I.ysnPosted, 1)
	 , dblAvailableCredit	= 0 	 	 
FROM tblARInvoice I 
	 INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId 
	 INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityCustomerId    
	 INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId
	 LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid ))) <= GETDATE()) ON I.intInvoiceId = PD.intInvoiceId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE() 
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) AS A    

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
  , intTermId  
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
	  , I.intTermId
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
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
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0)
	  , I.intTermId
FROM tblARInvoice I
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN tblARPayment P ON I.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
	LEFT JOIN (
		(SELECT SUM(dblPayment) AS dblPayment
				 , PD.intInvoiceId 
			FROM tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
			GROUP BY PD.intInvoiceId) 
		) PD ON I.intInvoiceId = PD.intInvoiceId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Prepayment')
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
	 , I.intTermId
FROM tblARPayment P
    INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
				AND I.ysnPosted = 1
				AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) > GETDATE()
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))
				AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
    INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId
    LEFT JOIN (tblARSalesperson SP INNER JOIN tblEMEntity ES ON SP.intEntitySalespersonId = ES.intEntityId) ON I.intEntitySalespersonId = SP.intEntitySalespersonId
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
  						      
UNION ALL      
      
SELECT I.strInvoiceNumber
  , I.intInvoiceId
  , I.strBOLNumber
  , dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN CASE WHEN ISNULL(P.dblAmountPaid, 0) < 0 THEN ISNULL(P.dblAmountPaid, 0) ELSE 0 END ELSE ISNULL(PD.dblPayment,0) END
  , dblInvoiceTotal			= 0
  , dblAmountDue			= 0
  , dblDiscount				= ISNULL(PD.dblDiscount, 0)
  , dblInterest				= ISNULL(PD.dblInterest, 0)
  , dtmDueDate				= ISNULL(I.dtmDueDate, GETDATE())
  , I.intEntityCustomerId
  , dblAvailableCredit		= 0
  , I.intTermId
FROM tblARInvoice I 
	INNER JOIN tblARCustomer C ON C.intEntityCustomerId = I.intEntityCustomerId    
	INNER JOIN tblSMTerm T ON T.intTermID = I.intTermId	
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId AND P.ysnPosted = 1 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()) ON I.intInvoiceId = PD.intInvoiceId
WHERE I.ysnPosted  = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE() 
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))) AS TBL) AS B      
ON
A.intEntityCustomerId		= B.intEntityCustomerId
AND A.strInvoiceNumber		= B.strInvoiceNumber
AND A.dblInvoiceTotal		= B.dblInvoiceTotal
AND A.dblAmountPaid			= B.dblAmountPaid
AND A.dblAvailableCredit	= B.dblAvailableCredit
GROUP BY A.strInvoiceNumber, A.intInvoiceId, A.strBOLNumber, A.intEntityCustomerId, A.strCustomerName, A.dtmDate, A.dtmDueDate, A.intCompanyLocationId , A.intTermId
) A 
INNER JOIN (SELECT intEntityId, strName FROM tblEMEntity) E ON A.intEntityCustomerId = E.intEntityId 
INNER JOIN (SELECT intCompanyLocationId, strUseLocationAddress, strAddress, strCity, strStateProvince, strZipPostalCode, strCountry, strPhone FROM tblSMCompanyLocation) L ON A.intCompanyLocationId = L.intCompanyLocationId
INNER JOIN (SELECT intEntityId, [intEntityContactId], ysnDefaultContact FROM [tblEMEntityToContact]) as CusToCon ON A.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
LEFT JOIN (SELECT intEntityId, strPhone FROM tblEMEntityPhoneNumber) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
INNER JOIN (SELECT intEntityCustomerId, strCustomerNumber, strBillToAddress, strBillToCity, strBillToCountry, strBillToLocationName, strBillToState, strBillToZipCode, intTermsId FROM vyuARCustomer) Cus ON A.intEntityCustomerId = Cus.intEntityCustomerId