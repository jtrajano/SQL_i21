CREATE VIEW [dbo].[vyuARInvoiceAgingReport]
AS
SELECT AGING.*
     , dblCreditLimit			= ISNULL(CUSTOMER.dblCreditLimit, 0)
     , strShipToLocation		= SHIPTOLOCATION.strAddress
	 , strBillToLocation		= BILLTOLOCATION.strAddress
	 , strDefaultLocation		= DEFAULTLOCATION.strAddress
	 , strDefaultShipTo			= CUSTOMER.strDefaultShipTo
	 , strDefaultBillTo			= CUSTOMER.strDefaultBillTo
	 , intCurrencyId			= INVOICE.intCurrencyId
	 , strCurrency				= CUR.strCurrency
	 , strCurrencyDescription	= CUR.strDescription
	 , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber		= CUSTOMER.strCustomerNumber
	 , strLocationName			= COMPANYLOCATION.strLocationName
FROM 
(SELECT strInvoiceNumber	= A.strInvoiceNumber
     , intInvoiceId			= A.intInvoiceId
	 , strBOLNumber			= A.strBOLNumber
	 , intEntityCustomerId	= A.intEntityCustomerId     
	 , dblTotalAR			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN (SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)) * -1 ELSE SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments) END
	 , dblFuture			= SUM(B.dblFuture)
	 , dbl0Days				= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl0Days) * -1 ELSE SUM(B.dbl0Days) END 
	 , dbl10Days			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl10Days) * -1 ELSE SUM(B.dbl10Days) END 
	 , dbl30Days			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl30Days) * -1 ELSE SUM(B.dbl30Days) END  
	 , dbl60Days			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl60Days) * -1 ELSE SUM(B.dbl60Days) END 
	 , dbl90Days			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl90Days) * -1 ELSE SUM(B.dbl90Days) END 
	 , dbl91Days			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dbl91Days) * -1 ELSE SUM(B.dbl91Days) END 
	 , dblTotalDue			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN (SUM(B.dblAvailableCredit) + SUM(B.dblPrepayments)) * -1 ELSE SUM(B.dblTotalDue)- SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments) END 
	 , dblAmountPaid		= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dblAmountPaid) * -1 ELSE SUM(B.dblAmountPaid) END 
	 , dblInvoiceTotal		= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN (SUM(B.dblAvailableCredit) + SUM(B.dblPrepayments)) * -1 ELSE SUM(A.dblInvoiceTotal) END 
	 , dblCredits			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dblAvailableCredit) * -1 ELSE SUM(B.dblAvailableCredit)  END 
	 , dblPrepayments		= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dblPrepayments) * -1 ELSE SUM(B.dblPrepayments) END 
	 , dblPrepaids			= CASE WHEN A.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN SUM(B.dblPrepayments) * -1 ELSE SUM(B.dblPrepayments) END 
	 , dtmDate				= A.dtmDate
	 , dtmDueDate			= A.dtmDueDate
	 , intCompanyLocationId	= A.intCompanyLocationId
	 , strTransactionType	= A.strTransactionType
	 , intAccountId			= A.intAccountId
	 , dtmAccountingPeriod  = A.dtmAccountingPeriod
FROM

(SELECT dtmDate				= I.dtmPostDate
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.intAccountId
	 , I.dtmDueDate    
	 , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
				END
	 ,dtmAccountingPeriod   = I.dtmAccountingPeriod
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE ysnPosted = 1
	AND ysnPaid = 0
	AND ysnCancelled = 0
	AND ysnReturned = 0
	AND strTransactionType <> 'Cash Refund'
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
  , dblTotalDue	= dblInvoiceTotal - dblAmountPaid
  , dblDiscount
  , dblInterest
  , dblAvailableCredit
  , dblPrepayments
  , CASE WHEN strType = 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dblFuture
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 0 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 0 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 10 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 30 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 60 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 90 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL((TBL.dblAmountPaid + TBL.dblDiscount - TBL.dblInterest), 0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 90 AND strType <> 'CF Tran'
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
	  , strType				= I.strType
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE ysnPosted = 1
	AND ysnPaid = 0
	AND ysnCancelled = 0
	AND ysnReturned = 0
	AND strTransactionType <> 'Cash Refund'
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType IN ('Invoice', 'Debit Memo')

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
	  , dblAvailableCredit	= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0) - ISNULL(CR.dblRefundTotal, 0)
	  , dblPrepayments		= 0
	  , strType				= I.strType
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN (
	SELECT intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
	FROM dbo.tblARPayment P WITH (NOLOCK)
	WHERE ysnPosted = 1
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
) P ON I.intPaymentId = P.intPaymentId
LEFT JOIN (
	SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
		 , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
	INNER JOIN (
		SELECT intPaymentId
			 , dtmDatePaid
			 , dblAmountPaid
			 , ysnInvoicePrepayment
		FROM dbo.tblARPayment P WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON PD.intPaymentId = P.intPaymentId 
	GROUP BY PD.intInvoiceId
) PD ON I.intInvoiceId = PD.intInvoiceId		
LEFT JOIN (
	SELECT intPrepaymentId
		 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
	FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK) 
	WHERE ysnApplied = 1
	GROUP BY intPrepaymentId
) PC ON I.intInvoiceId = PC.intPrepaymentId
LEFT JOIN (
	SELECT strDocumentNumber	= ID.strDocumentNumber
		 , dblRefundTotal		= SUM(I.dblInvoiceTotal) 
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	WHERE I.strTransactionType = 'Cash Refund'
	AND I.ysnPosted = 1
	AND ISNULL(ID.strDocumentNumber, '') <> ''
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	GROUP BY ID.strDocumentNumber
) CR ON I.strInvoiceNumber = CR.strDocumentNumber
WHERE ysnPosted = 1
    AND ysnPaid = 0
	AND ysnCancelled = 0
	AND strTransactionType <> 'Cash Refund'
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')

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
	  , dblPrepayments		= ISNULL(I.dblInvoiceTotal, 0) + ISNULL(PD.dblPayment, 0) - ISNULL(PC.dblAppliedInvoiceAmount, 0) - ISNULL(CR.dblRefundTotal, 0)
	  , strType				= I.strType
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intPaymentId
		 , dtmDatePaid
		 , dblAmountPaid
		 , ysnInvoicePrepayment
	FROM dbo.tblARPayment P WITH (NOLOCK)
	WHERE ysnPosted = 1
	  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
) P ON I.intPaymentId = P.intPaymentId 
LEFT JOIN (
	SELECT dblPayment = SUM(dblPayment) + SUM(ISNULL(dblWriteOffAmount, 0))
		 , PD.intInvoiceId
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
	INNER JOIN (
		SELECT intPaymentId
			 , dtmDatePaid
			 , dblAmountPaid
			 , ysnInvoicePrepayment
		FROM dbo.tblARPayment P WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON PD.intPaymentId = P.intPaymentId AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId
) PD ON I.intInvoiceId = PD.intInvoiceId
LEFT JOIN (
	SELECT intPrepaymentId
		 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
	FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK) 
	WHERE ysnApplied = 1
	GROUP BY intPrepaymentId
) PC ON I.intInvoiceId = PC.intPrepaymentId
LEFT JOIN (
	SELECT strDocumentNumber	= ID.strDocumentNumber
		 , dblRefundTotal		= SUM(I.dblInvoiceTotal) 
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	WHERE I.strTransactionType = 'Cash Refund'
	AND I.ysnPosted = 1
	AND ISNULL(ID.strDocumentNumber, '') <> ''
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	GROUP BY ID.strDocumentNumber
) CR ON I.strInvoiceNumber = CR.strDocumentNumber  
WHERE ysnPosted = 1
    AND ysnPaid = 0
	AND ysnCancelled = 0
	AND strTransactionType <> 'Cash Refund'
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType = 'Customer Prepayment'

UNION ALL
      
SELECT I.strInvoiceNumber
  , I.intInvoiceId
  , I.strBOLNumber
  , dblAmountPaid			= CASE WHEN I.strTransactionType IN ('Credit Memo', 'Overpayment', 'Customer Prepayment') THEN 0 ELSE ISNULL(PAYMENT.dblTotalPayment, 0) END
  , dblInvoiceTotal			= 0
  , dblAmountDue			= 0
  , dblDiscount				= 0
  , dblInterest				= 0
  , dtmDueDate				= ISNULL(I.dtmDueDate, GETDATE())
  , I.intEntityCustomerId
  , dblAvailableCredit		= 0
  , dblPrepayments			= 0
  , strType					= I.strType
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN (
	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , dtmDatePaid
			 , dblAmountPaid
			 , ysnInvoicePrepayment
		FROM dbo.tblARPayment P WITH (NOLOCK)
		WHERE ysnPosted = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
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

	UNION ALL

	SELECT intOriginalInvoiceId
		 , dblInvoiceTotal
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	WHERE ysnPosted = 1
	AND ysnRefundProcessed = 1
	AND strTransactionType = 'Credit Memo'
	AND intOriginalInvoiceId IS NOT NULL
	AND ISNULL(strInvoiceOriginId, '') <> ''
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmPostDate))) <= GETDATE()

) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
WHERE ysnPosted = 1
    AND ysnPaid = 0
	AND ysnCancelled = 0
	AND ysnReturned = 0
	AND strTransactionType <> 'Cash Refund'
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()	
 ) AS TBL) AS B   
    
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0

GROUP BY A.strInvoiceNumber, A.intInvoiceId, A.strBOLNumber, A.intEntityCustomerId, A.dtmDate, A.dtmDueDate, A.intCompanyLocationId, A.strTransactionType, A.intAccountId,A.dtmAccountingPeriod) AS AGING
INNER JOIN (
	SELECT C.intEntityId
		 , E.strName
		 , C.strCustomerNumber
		 , C.dblCreditLimit
		 , strDefaultShipTo = DEFAULTSHIPTO.strAddress
		 , strDefaultBillTo = DEFAULTBILLTO.strAddress
	FROM tblARCustomer C WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId
					 , strName
				FROM dbo.tblEMEntity
	) E ON C.intEntityId = E.intEntityId
	LEFT JOIN (
		SELECT intEntityId
			 , intEntityLocationId
			 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	) DEFAULTSHIPTO ON C.intShipToId = DEFAULTSHIPTO.intEntityLocationId 
				   AND C.intEntityId = DEFAULTSHIPTO.intEntityId
	LEFT JOIN (
		SELECT intEntityId
			 , intEntityLocationId
			 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	) DEFAULTBILLTO ON C.intBillToId = DEFAULTBILLTO.intEntityLocationId 
				   AND C.intEntityId = DEFAULTBILLTO.intEntityId
) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
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
) GL ON AGING.intAccountId = GL.intAccountId
LEFT JOIN (
	SELECT *
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE ysnCancelled = 0 
	  AND ysnPosted = 1
	  AND strTransactionType <> 'Cash Refund'
) INVOICE ON AGING.intInvoiceId = INVOICE.intInvoiceId 
LEFT JOIN (
	SELECT intEntityId
		 , intEntityLocationId
		 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	WHERE ysnDefaultLocation = 1
) SHIPTOLOCATION ON INVOICE.intShipToLocationId = SHIPTOLOCATION.intEntityLocationId 
			    AND INVOICE.intEntityCustomerId = SHIPTOLOCATION.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , intEntityLocationId
		 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	WHERE ysnDefaultLocation = 1
) BILLTOLOCATION ON INVOICE.intBillToLocationId = BILLTOLOCATION.intEntityLocationId 
                AND INVOICE.intEntityCustomerId = BILLTOLOCATION.intEntityId
LEFT JOIN (
	SELECT intEntityId
		 , intEntityLocationId
		 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
	WHERE ysnDefaultLocation = 1
) DEFAULTLOCATION ON AGING.intEntityCustomerId = DEFAULTLOCATION.intEntityId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
		 , strDescription
	FROM dbo.tblSMCurrency
) CUR ON INVOICE.intCurrencyId = CUR.intCurrencyID
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) COMPANYLOCATION ON INVOICE.intCompanyLocationId = COMPANYLOCATION.intCompanyLocationId
WHERE INVOICE.ysnPaid = 0
AND AGING.intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE strTransactionType NOT IN ('Cash', 'Cash Refund'))