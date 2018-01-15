﻿CREATE VIEW [dbo].[vyuARInvoiceAgingReport]
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
	 , strCustomerNumber		= C.strCustomerNumber
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
FROM

(SELECT dtmDate				= I.dtmPostDate
	 , I.strInvoiceNumber
	 , I.intCompanyLocationId
	 , I.intInvoiceId
	 , I.strBOLNumber
     , dblInvoiceTotal		= ISNULL(I.dblInvoiceTotal,0)
	 , I.strTransactionType    
	 , I.intEntityCustomerId
	 , I.dtmDueDate    
	 , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
						  WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
				END
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE ysnPosted = 1
	AND I.ysnCancelled = 0
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
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
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType IN ('Invoice', 'Debit Memo')
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
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId)

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
	SELECT dblPayment = SUM(dblPayment)
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
WHERE ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit')
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
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId)

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
	SELECT dblPayment = SUM(dblPayment)
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
WHERE ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
	AND strTransactionType = 'Customer Prepayment'
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
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId)

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

) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
WHERE ysnPosted = 1
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
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
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId)
 ) AS TBL) AS B   
    
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId

WHERE B.dblTotalDue - B.dblAvailableCredit - B.dblPrepayments <> 0

GROUP BY A.strInvoiceNumber, A.intInvoiceId, A.strBOLNumber, A.intEntityCustomerId, A.dtmDate, A.dtmDueDate, A.intCompanyLocationId, A.strTransactionType) AS AGING
INNER JOIN (
	SELECT C.intEntityId
		 , E.strName
		 , C.strCustomerNumber
		 , C.dblCreditLimit
	FROM tblARCustomer C WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId
					 , strName
				FROM dbo.tblEMEntity
	) E ON C.intEntityId = E.intEntityId
) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityId
LEFT JOIN tblARInvoice INVOICE ON AGING.intInvoiceId = INVOICE.intInvoiceId AND INVOICE.ysnCancelled = 0 AND INVOICE.ysnPosted = 1
LEFT JOIN tblEMEntityLocation SHIPTOLOCATION ON INVOICE.intShipToLocationId = SHIPTOLOCATION.intEntityLocationId AND INVOICE.intEntityCustomerId = SHIPTOLOCATION.intEntityId
LEFT JOIN tblEMEntityLocation BILLTOLOCATION ON INVOICE.intBillToLocationId = BILLTOLOCATION.intEntityLocationId AND INVOICE.intEntityCustomerId = BILLTOLOCATION.intEntityId
LEFT JOIN tblEMEntityLocation DEFAULTLOCATION ON AGING.intEntityCustomerId = DEFAULTLOCATION.intEntityId AND DEFAULTLOCATION.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation DEFAULTSHIPTO ON C.intShipToId = DEFAULTSHIPTO.intEntityLocationId AND C.[intEntityId] = DEFAULTSHIPTO.intEntityId
LEFT JOIN tblEMEntityLocation DEFAULTBILLTO ON C.intBillToId = DEFAULTBILLTO.intEntityLocationId AND C.[intEntityId] = DEFAULTBILLTO.intEntityId
LEFT JOIN
	(SELECT intCurrencyID
		  , strCurrency
		  , strDescription
		FROM dbo.tblSMCurrency
	 ) CUR ON INVOICE.intCurrencyId = CUR.intCurrencyID
WHERE INVOICE.ysnPaid = 0
AND AGING.intInvoiceId IN (SELECT intInvoiceId FROM tblARInvoice WHERE strTransactionType NOT IN ('Cash', 'Cash Refund'))
