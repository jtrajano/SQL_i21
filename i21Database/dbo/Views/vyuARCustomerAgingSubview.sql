CREATE VIEW [dbo].[vyuARCustomerAgingSubview]
AS
WITH RESULT_CTE (intInvoiceId, dblAmountPaid, dblInvoiceTotal, dblAmountDue, dtmDueDate, intEntityCustomerId, dblAvailableCredit, dblPrepayments, strType)
AS(SELECT I.intInvoiceId
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
	WHERE I.ysnPosted = 1
		AND I.ysnCancelled = 0
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
/**/
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
	WHERE I.ysnPosted = 1
		AND I.ysnCancelled = 0
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
	WHERE P.ysnPosted = 1
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
		WHERE P.ysnPosted = 1
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
	WHERE I.ysnPosted = 1
		AND I.ysnCancelled = 0
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
	WHERE P.ysnPosted = 1
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
		WHERE P.ysnPosted = 1
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
	SELECT *
FROM dbo.tblARInvoice I WITH (NOLOCK)
WHERE I.ysnPosted = 1	
	AND I.ysnCancelled = 0
	AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
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
		WHERE P.ysnPosted = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= GETDATE()
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId

	UNION ALL 

	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0)) + SUM(ISNULL(dblDiscount, 0)) - SUM(ISNULL(dblInterest, 0))
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
		FROM dbo.tblAPPayment APP WITH (NOLOCK)
		WHERE APP.ysnPosted = 1
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
	) )

SELECT DISTINCT 
	intEntityCustomerId
  , intInvoiceId  
  , dblAmountPaid
  , dblTotalDue	= dblInvoiceTotal - dblAmountPaid
  , dblAvailableCredit
  , dblPrepayments
  , CASE WHEN strType = 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dblFuture
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) <= 0 AND strType <> 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl0Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) > 0 AND DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) <= 10 AND strType <> 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl10Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) <= 30 AND strType <> 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl30Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) <= 60 AND strType <> 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl60Days
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) <= 90 AND strType <> 'CF Tran'
		 THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl90Days    
  , CASE WHEN DATEDIFF(DAYOFYEAR, dtmDueDate, GETDATE()) > 90 AND strType <> 'CF Tran'
	     THEN ISNULL((dblInvoiceTotal), 0) - ISNULL(dblAmountPaid, 0) ELSE 0 END dbl91Days 
FROM RESULT_CTE