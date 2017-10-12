CREATE VIEW [dbo].[vyuARCustomerAgingReport]
AS
SELECT strCustomerName = CUSTOMER.strName
	 , strEntityNo = CUSTOMER.strCustomerNumber
	 , dblCreditLimit = CUSTOMER.dblCreditLimit
	 , AGING.*
FROM (
SELECT A.intEntityCustomerId
	 , dblTotalAR			= SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
	 , dblTotalARDiscount	= SUM(B.dblTotalDue) - SUM(A.dblDiscountTerm) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
	 , dblFuture			= SUM(B.dblFuture)
	 , dbl0Days				= SUM(B.dbl0Days)
     , dbl10Days			= SUM(B.dbl10Days)
	 , dbl30Days			= SUM(B.dbl30Days)
	 , dbl60Days			= SUM(B.dbl60Days)
	 , dbl90Days			= SUM(B.dbl90Days)
	 , dbl91Days			= SUM(B.dbl91Days)
	 , dblTotalDue			= SUM(B.dblTotalDue) - SUM(B.dblAvailableCredit) - SUM(B.dblPrepayments)
	 , dblAmountPaid		= SUM(B.dblAmountPaid)
	 , dblInvoiceTotal		= SUM(A.dblInvoiceTotal)
	 , dblCredits			= SUM(B.dblAvailableCredit) * -1
	 , dblPrepayments		= SUM(B.dblPrepayments) * -1
	 , dblPrepaids			= 0.000000
FROM

(SELECT I.intInvoiceId
	  , I.intEntityCustomerId
	  , I.dblInvoiceTotal
	  , dblDiscountTerm		= dbo.fnARComputeDiscountForEarlyPayment(GETDATE(), I.intInvoiceId)
	  , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				 ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
				 END
FROM (
	SELECT I.intInvoiceId
		 , I.intEntityCustomerId
		 , I.dtmDueDate
		 , I.strType
		 , I.dblInvoiceTotal
	FROM dbo.tblARInvoice I WITH (NOLOCK)
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
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)		
) I ) AS A  

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
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 0 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 0 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 10 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 30 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 60 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) <= 90 AND strType <> 'CF Tran'
		 THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR, TBL.dtmDueDate, GETDATE()) > 90 AND strType <> 'CF Tran'
	     THEN ISNULL((TBL.dblInvoiceTotal), 0) - ISNULL(TBL.dblAmountPaid, 0) ELSE 0 END dbl91Days 
FROM (

SELECT I.intInvoiceId
     , dblAmountPaid		= 0
     , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
     , dblAmountDue			= 0    
     , I.dtmDueDate    
     , I.intEntityCustomerId
     , dblAvailableCredit	= 0
	 , dblPrepayments		= 0
	 , I.strType
FROM (
	SELECT I.intInvoiceId
		 , I.dblInvoiceTotal
		 , I.dtmDueDate    
		 , I.intEntityCustomerId
		 , I.strType
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
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)		
) I

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
FROM (
	SELECT I.intInvoiceId
		 , I.dblInvoiceTotal
		 , I.dtmDueDate    
		 , I.intEntityCustomerId
		 , I.strType
		 , I.intPaymentId
	FROM dbo.tblARInvoice I WITH (NOLOCK)
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
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)
) I
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
FROM (
	SELECT I.intInvoiceId
		 , dblInvoiceTotal		= ISNULL(dblInvoiceTotal,0)
		 , I.dtmDueDate    
		 , I.intEntityCustomerId
		 , I.strType
		 , I.intPaymentId
	FROM dbo.tblARInvoice I WITH (NOLOCK)
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
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)
) I
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
FROM (
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
FROM dbo.tblARInvoice I WITH (NOLOCK)
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
		) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
	)	
) I
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

) AS TBL) AS B    
    
ON
A.intEntityCustomerId	 = B.intEntityCustomerId
AND A.intInvoiceId		 = B.intInvoiceId
GROUP BY A.intEntityCustomerId) AGING
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