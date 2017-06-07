CREATE VIEW [dbo].[vyuARInvoiceAgingReport]
AS
SELECT AGING.*
     , dblCreditLimit       = C.dblCreditLimit
	 , strCustomerName		= E.strName
	 , intCurrencyId        = INVOICE.intCurrencyId
     , strCurrency          = CUR.strCurrency
     , strCurrencyDescription = CUR.strDescription
     , strShipToLocation    = dbo.fnARFormatCustomerAddress(NULL, NULL, SHIPTOLOCATION.strLocationName, SHIPTOLOCATION.strAddress, SHIPTOLOCATION.strCity, SHIPTOLOCATION.strState, SHIPTOLOCATION.strZipCode, SHIPTOLOCATION.strCountry, NULL, 0)
	 , strBillToLocation    = dbo.fnARFormatCustomerAddress(NULL, NULL, BILLTOLOCATION.strLocationName, BILLTOLOCATION.strAddress, BILLTOLOCATION.strCity, BILLTOLOCATION.strState, BILLTOLOCATION.strZipCode, BILLTOLOCATION.strCountry, NULL, 0)
	 , strDefaultLocation   = dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTLOCATION.strLocationName, DEFAULTLOCATION.strAddress, DEFAULTLOCATION.strCity, DEFAULTLOCATION.strState, DEFAULTLOCATION.strZipCode, DEFAULTLOCATION.strCountry, NULL, 0)
	 , strDefaultShipTo     = dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTSHIPTO.strLocationName, DEFAULTSHIPTO.strAddress, DEFAULTSHIPTO.strCity, DEFAULTSHIPTO.strState, DEFAULTSHIPTO.strZipCode, DEFAULTSHIPTO.strCountry, NULL, 0)
	 , strDefaultBillTo     = dbo.fnARFormatCustomerAddress(NULL, NULL, DEFAULTBILLTO.strLocationName, DEFAULTBILLTO.strAddress, DEFAULTBILLTO.strCity, DEFAULTBILLTO.strState, DEFAULTBILLTO.strZipCode, DEFAULTBILLTO.strCountry, NULL, 0)
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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
	, dblAvailableCredit	= 0
	, dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
			        , intInvoiceId 
			   FROM dbo.tblAPPaymentDetail APPD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId
																			   , ysnPosted 
																	      FROM dbo.tblAPPayment WITH (NOLOCK)
																	      WHERE ysnPosted = 1
																			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		  ) APP ON APPD.intPaymentId = APP.intPaymentId
			   GROUP BY intInvoiceId
	) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId    
WHERE I.ysnPosted = 1
  AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) <= GETDATE()
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 90 THEN 'Over 90' END
	 , dblAvailableCredit		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARInvoice I	WITH (NOLOCK)
	LEFT JOIN (SELECT intPaymentId
	                , dtmDatePaid 
			   FROM dbo.tblARPayment WITH (NOLOCK)
			   WHERE ysnPosted = 1
				 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment)
				   , PD.intInvoiceId 
			   FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		FROM dbo.tblARPayment WITH (NOLOCK)
																		WHERE ysnPosted = 1
																		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		) P ON PD.intPaymentId = P.intPaymentId
			   GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
		            , dblAppliedInvoiceAmount	= SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId	
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.dblInvoiceTotal - (ISNULL(PD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)) <> 0 
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
	 , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 10 THEN '1 - 10 Days'
			         WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 60 THEN '31 - 60 Days'     
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) <= 90 THEN '61 - 90 Days'    
				     WHEN DATEDIFF(DAYOFYEAR, ISNULL(P.dtmDatePaid, I.dtmDueDate), GETDATE()) > 90 THEN 'Over 90' END
	 , dblAvailableCredit		= 0
	 , dblPrepayments			= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0)
FROM dbo.tblARInvoice I	WITH (NOLOCK)
	LEFT JOIN (SELECT intPaymentId
	                , dtmDatePaid 
			   FROM dbo.tblARPayment WITH (NOLOCK)
			   WHERE ysnPosted = 1
				 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment)
					, PD.intInvoiceId 
			   FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		FROM dbo.tblARPayment WITH (NOLOCK)
																		WHERE ysnPosted = 1
																		  AND ysnInvoicePrepayment = 0
																		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		) P ON PD.intPaymentId = P.intPaymentId
			   GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (
		(SELECT intPrepaymentId
		      , dblAppliedInvoiceAmount	= SUM(dblAppliedInvoiceAmount)
			FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			WHERE ysnApplied = 1
			GROUP BY intPrepaymentId)
	) PC ON I.intInvoiceId = PC.intPrepaymentId 
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
     , strAge = CASE  WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 0 THEN 'Current'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 10 THEN '1 - 10 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 30 THEN '11 - 30 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 60 THEN '31 - 60 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) <= 90 THEN '61 - 90 Days'
                      WHEN DATEDIFF(DAYOFYEAR, P.dtmDatePaid, GETDATE()) > 90 THEN 'Over 90' END
     , dblAvailableCredit       = ISNULL(PD.dblPayment, 0)
	 , dblPrepayments			= 0
FROM dbo.tblARPayment P WITH (NOLOCK)
    INNER JOIN (SELECT intPaymentId
					 , dblPayment
					 , intInvoiceId 
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId
	                , intCompanyLocationId
					, strBOLNumber
					, strInvoiceNumber
					, strTransactionType
					, intEntityCustomerId
					, dtmPostDate
			   FROM dbo.tblARInvoice WITH (NOLOCK)
			   WHERE ysnPosted = 1 
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > GETDATE()				
				AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	) I ON PD.intInvoiceId = I.intInvoiceId
	   AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))				
WHERE P.ysnPosted = 1  
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
        
UNION ALL      
      
SELECT dtmDate				= I.dtmPostDate      
     , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
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
	 , I.dblAmountDue     
	 , dblDiscount			= ISNULL(I.dblDiscount, 0)    
	 , strTransactionType	= ISNULL(I.strTransactionType, 'Invoice')    
	 , I.intEntityCustomerId
	 , I.dtmDueDate
     , strAge = CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
					 WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'
				     WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
	 , dblAvailableCredit	= 0 
	 , dblPrepayments		= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)
	 LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblInvoiceTotal
					  , dblPayment 
				 FROM dbo.tblARPaymentDetail WITH (NOLOCK)) PD INNER JOIN (SELECT intPaymentId
																				, dblAmountPaid
																		   FROM dbo.tblARPayment WITH (NOLOCK)
																		   WHERE ysnPosted = 1
																			 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) <= GETDATE()
	 ) P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblPayment
				  FROM dbo.tblAPPaymentDetail WITH (NOLOCK)) APPD INNER JOIN (SELECT intPaymentId
																				   , dblAmountPaid
																			  FROM dbo.tblAPPayment WITH (NOLOCK)
																			  WHERE ysnPosted = 1
																				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	 ) APP ON APPD.intPaymentId = APP.intPaymentId) ON I.intInvoiceId = APPD.intInvoiceId
	 LEFT JOIN (SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
			         , intInvoiceId 
				FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		 FROM dbo.tblAPPayment WITH (NOLOCK)
																		 WHERE ysnPosted = 1
																		   AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		 ) P ON PD.intPaymentId = P.intPaymentId
				GROUP BY intInvoiceId
	 ) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	 LEFT JOIN (SELECT PC.intInvoiceId
		             , I.strInvoiceNumber
			         , PC.intPrepaymentId
		             , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount) 
				FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) INNER JOIN (SELECT intInvoiceId
																				 , strInvoiceNumber
																			FROM dbo.tblARInvoice WITH (NOLOCK)
																			) I ON I.intInvoiceId = PC.intPrepaymentId
			WHERE ysnApplied = 1
			GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber
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
FROM dbo.tblARInvoice I	WITH (NOLOCK)
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Invoice', 'Debit Memo')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) <= GETDATE()
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
FROM dbo.tblARInvoice I	WITH (NOLOCK)
	LEFT JOIN (SELECT intPaymentId
					, dtmDatePaid
		       FROM dbo.tblARPayment WITH (NOLOCK)
			   WHERE ysnPosted = 1
			     AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment)
			        , PD.intInvoiceId 
			   FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		FROM dbo.tblARPayment WITH (NOLOCK)
																		WHERE ysnPosted = 1
																		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		) P ON PD.intPaymentId = P.intPaymentId
			   GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
				    , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.dblInvoiceTotal - (ISNULL(PD.dblPayment, 0) + ISNULL(PC.dblAppliedInvoiceAmount, 0)) <> 0 
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
FROM dbo.tblARInvoice I	WITH (NOLOCK)
	LEFT JOIN (SELECT intPaymentId
					, dtmDatePaid
			   FROM dbo.tblARPayment WITH (NOLOCK)
			   WHERE ysnPosted = 1
				 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON I.intPaymentId = P.intPaymentId
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment)
				    , PD.intInvoiceId 
			   FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		FROM dbo.tblARPayment WITH (NOLOCK)
																		WHERE ysnPosted = 1
																		  AND ysnInvoicePrepayment = 0
																		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
																		) P ON PD.intPaymentId = P.intPaymentId
			   GROUP BY PD.intInvoiceId
	) PD ON I.intInvoiceId = PD.intInvoiceId
	LEFT JOIN (SELECT intPrepaymentId
					, dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK) 
			   WHERE ysnApplied = 1
			   GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId 
WHERE I.ysnPosted = 1
 AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
 AND I.strTransactionType = 'Customer Prepayment'
 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
 AND I.dblInvoiceTotal - ISNULL(PD.dblPayment, 0) <> 0 
 AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

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
FROM dbo.tblARPayment P WITH (NOLOCK)
    INNER JOIN (SELECT intInvoiceId
					 , intPaymentId
					 , dblPayment
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) PD ON P.intPaymentId = PD.intPaymentId
    LEFT JOIN (SELECT intInvoiceId
					, intEntityCustomerId
					, strInvoiceNumber
					, strBOLNumber
					, dtmPostDate
			   FROM dbo.tblARInvoice WITH (NOLOCK)
			   WHERE ysnPosted = 1
				AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) > GETDATE()				
				AND intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WITH (NOLOCK) WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))
	) I ON PD.intInvoiceId = I.intInvoiceId
	   AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))    
WHERE P.ysnPosted = 1
  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), P.dtmDatePaid))) <= GETDATE()
  						      
UNION ALL      
      
SELECT I.strInvoiceNumber
  , I.intInvoiceId
  , I.strBOLNumber
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
  , dblDiscount				= ISNULL(PD.dblDiscount, 0) + ISNULL(APPD.dblDiscount, 0)
  , dblInterest				= ISNULL(PD.dblInterest, 0) + ISNULL(APPD.dblInterest, 0)
  , dtmDueDate				= ISNULL(I.dtmDueDate, GETDATE())
  , I.intEntityCustomerId
  , dblAvailableCredit		= 0
  , dblPrepayments			= 0
FROM dbo.tblARInvoice I WITH (NOLOCK)	
	LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblInvoiceTotal
					  , dblPayment
					  , dblDiscount
					  , dblInterest
				 FROM dbo.tblARPaymentDetail WITH (NOLOCK)) PD INNER JOIN (SELECT intPaymentId
																				, dblAmountPaid
																		   FROM dbo.tblARPayment WITH (NOLOCK)
																		   WHERE ysnPosted = 1
																			 AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid ))) <= GETDATE()
	 ) P ON PD.intPaymentId = P.intPaymentId) ON I.intInvoiceId = PD.intInvoiceId
	 LEFT JOIN ((SELECT intPaymentId
					  , intInvoiceId
					  , dblPayment
					  , dblDiscount
					  , dblInterest
				  FROM dbo.tblAPPaymentDetail WITH (NOLOCK)) APPD INNER JOIN (SELECT intPaymentId
																				   , dblAmountPaid
																			  FROM dbo.tblAPPayment WITH (NOLOCK)
																			  WHERE ysnPosted = 1
																				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) APP ON APPD.intPaymentId = APP.intPaymentId) ON I.intInvoiceId = APPD.intInvoiceId
	LEFT JOIN (SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
				    , intInvoiceId 
			   FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK) INNER JOIN (SELECT intPaymentId 
																		FROM dbo.tblAPPayment WITH (NOLOCK)
																		WHERE ysnPosted = 1
																		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()) P ON PD.intPaymentId = P.intPaymentId
			   GROUP BY intInvoiceId
	) TOTALSETTLEMENT ON I.intInvoiceId = TOTALSETTLEMENT.intInvoiceId
	LEFT JOIN (SELECT PC.intInvoiceId
				    , I.strInvoiceNumber
				    , PC.intPrepaymentId
				    , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
			   FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) INNER JOIN (SELECT intInvoiceId
																				, strInvoiceNumber
																		   FROM dbo.tblARInvoice WITH (NOLOCK)
																		   ) I ON I.intInvoiceId = PC.intPrepaymentId
			   WHERE ysnApplied = 1
			   GROUP BY PC.intInvoiceId, PC.intPrepaymentId, I.strInvoiceNumber
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
LEFT JOIN (SELECT intEntityId
				 , intShipToId
				 , intBillToId
				 , dblCreditLimit
			FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON AGING.intEntityCustomerId = C.intEntityId
LEFT JOIN (SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON E.intEntityId = C.intEntityId
LEFT JOIN (SELECT intInvoiceId
				, intShipToLocationId
				, intBillToLocationId
				, intEntityCustomerId
				, intCurrencyId
				, ysnPaid
		   FROM dbo.tblARInvoice WITH (NOLOCK)
) INVOICE ON AGING.intInvoiceId = INVOICE.intInvoiceId
LEFT JOIN (SELECT intCurrencyID
			    , strCurrency
				, strDescription
		   FROM dbo.tblSMCurrency WITH (NOLOCK)
) CUR ON INVOICE.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (SELECT intEntityLocationId
			    , intEntityId
				, strLocationName
				, strAddress
				, strCity
				, strState
				, strZipCode
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) SHIPTOLOCATION ON INVOICE.intShipToLocationId = SHIPTOLOCATION.intEntityLocationId 
                AND INVOICE.intEntityCustomerId = SHIPTOLOCATION.intEntityId
LEFT JOIN (SELECT intEntityLocationId
			    , intEntityId
				, strLocationName
				, strAddress
				, strCity
				, strState
				, strZipCode
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) BILLTOLOCATION ON INVOICE.intBillToLocationId = BILLTOLOCATION.intEntityLocationId 
				AND INVOICE.intEntityCustomerId = BILLTOLOCATION.intEntityId
LEFT JOIN (SELECT intEntityLocationId
			    , intEntityId
				, strLocationName
				, strAddress
				, strCity
				, strState
				, strZipCode
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
		   WHERE ysnDefaultLocation = 1
) DEFAULTLOCATION ON AGING.intEntityCustomerId = DEFAULTLOCATION.intEntityId
LEFT JOIN (SELECT intEntityLocationId
			    , intEntityId
				, strLocationName
				, strAddress
				, strCity
				, strState
				, strZipCode
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) DEFAULTSHIPTO ON C.intShipToId = DEFAULTSHIPTO.intEntityLocationId 
			   AND C.intEntityId = DEFAULTSHIPTO.intEntityId
LEFT JOIN (SELECT intEntityLocationId
			    , intEntityId
				, strLocationName
				, strAddress
				, strCity
				, strState
				, strZipCode
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) DEFAULTBILLTO ON C.intBillToId = DEFAULTBILLTO.intEntityLocationId 
			   AND C.intEntityId = DEFAULTBILLTO.intEntityId
WHERE ISNULL(INVOICE.ysnPaid, 0) = 0
