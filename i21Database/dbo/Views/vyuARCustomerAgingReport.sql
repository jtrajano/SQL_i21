CREATE VIEW [dbo].[vyuARCustomerAgingReport]
AS
WITH RESULT_CTE(intInvoiceId, intEntityCustomerId, dblInvoiceTotal, dblDiscountTerm, strAge, dblAmountPaid, dblTotalDue, dblAvailableCredit, dblPrepayments, dblFuture, dbl0Days, dbl10Days, dbl30Days, dbl60Days, dbl90Days, dbl91Days)
AS(
SELECT I.intInvoiceId
	  , I.intEntityCustomerId
	  , I.dblInvoiceTotal
	  , dblDiscountTerm		= ISNULL(CONVERT(NUMERIC(18, 6), DISCOUNT.dblDiscount), 0.00)
	  , strAge = CASE WHEN I.strType = 'CF Tran' THEN 'Future'
				 ELSE CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 0 THEN 'Current'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 0  AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 10 THEN '1 - 10 Days'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 10 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 30 THEN '11 - 30 Days'
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 30 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 60 THEN '31 - 60 Days'     
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 60 AND DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) <= 90 THEN '61 - 90 Days'    
						   WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, GETDATE()) > 90 THEN 'Over 90' END
				 END
	  , dblAmountPaid
	  , dblTotalDue
	  , dblAvailableCredit
	  , dblPrepayments
	  , dblFuture
	  , dbl0Days
	  , dbl10Days
	  , dbl30Days
	  , dbl60Days
	  , dbl90Days
	  , dbl91Days
FROM (
	SELECT I.intInvoiceId
		 , I.intEntityCustomerId
		 , I.dtmDate
		 , I.dtmDueDate
		 , I.strType
		 , I.intTermId
		 , I.dblInvoiceTotal
		 , Z.dblAmountPaid
		 , Z.dblTotalDue
		 , Z.dblAvailableCredit
		 , Z.dblPrepayments
		 , Z.dblFuture
		 , Z.dbl0Days
		 , Z.dbl10Days
		 , Z.dbl30Days
		 , Z.dbl60Days
		 , Z.dbl90Days
		 , Z.dbl91Days
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	LEFT JOIN vyuARCustomerAgingSubview Z ON Z.intEntityCustomerId = I.intEntityCustomerId 
	  AND Z.intInvoiceId = I.intInvoiceId
	  AND I.ysnPosted = 1
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
	) I
	OUTER APPLY (
		SELECT TOP 1 dblDiscount = CASE WHEN GETDATE() BETWEEN I.dtmDate AND DATEADD(DAYOFYEAR, T.intDiscountDay, I.dtmDate) THEN I.dblInvoiceTotal * (T.dblDiscountEP/100) ELSE 0.00 END
		FROM dbo.tblSMTerm T
		WHERE T.intTermID = I.intTermId
	) DISCOUNT
)

SELECT strCustomerName = CUSTOMER.strName
	 , strEntityNo = CUSTOMER.strCustomerNumber
	 , dblCreditLimit = ISNULL(CUSTOMER.dblCreditLimit, 0)
	 , AGING.*
FROM (
	SELECT intEntityCustomerId
		 , dblTotalAR			= SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
		 , dblTotalARDiscount	= SUM(dblTotalDue) - SUM(dblDiscountTerm) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
		 , dblFuture			= SUM(dblFuture)
		 , dbl0Days				= SUM(dbl0Days)
		 , dbl10Days			= SUM(dbl10Days)
		 , dbl30Days			= SUM(dbl30Days)
		 , dbl60Days			= SUM(dbl60Days)
		 , dbl90Days			= SUM(dbl90Days)
		 , dbl91Days			= SUM(dbl91Days)
		 , dblTotalDue			= SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
		 , dblAmountPaid		= SUM(dblAmountPaid)
		 , dblInvoiceTotal		= SUM(dblInvoiceTotal)
		 , dblCredits			= SUM(dblAvailableCredit) * -1
		 , dblPrepayments		= SUM(dblPrepayments) * -1
		 , dblPrepaids			= 0.000000
	FROM RESULT_CTE
	GROUP BY intEntityCustomerId
	--HAVING dbo.fnRoundBanker(SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments), 2) <> 0.00 
	--	OR dbo.fnRoundBanker(SUM(dblAvailableCredit) * -1, 2) <> 0.00 
	--	OR dbo.fnRoundBanker(SUM(dblPrepayments) * -1, 2) <> 0.00
) AGING
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