/*
Used AS A drilldown to invoice for DASH-2443
*/
CREATE VIEW vyuARCustomerAgingInvoice
AS
WITH RESULT_CTE(intInvoiceId, intEntityCustomerId,strInvoiceNumber)
AS(
SELECT 
	 I.intInvoiceId
	 , I.intEntityCustomerId
	 , I.strInvoiceNumber
FROM (
	SELECT I.intInvoiceId
		 , I.intEntityCustomerId
		 , Z.dblTotalDue
		 , Z.dblAvailableCredit
		 , Z.dblPrepayments
		 , I.strInvoiceNumber
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
	
)

SELECT 
	AGING.intInvoiceId,
	AGING.intEntityCustomerId,
	CUSTOMER.strCustomerNumber,
	AGING.strInvoiceNumber
FROM
RESULT_CTE AGING
INNER JOIN (
	SELECT C.intEntityId
		 , E.strName
		 , C.strCustomerNumber
		 --, C.dblCreditLimit
	FROM tblARCustomer C WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId
					 , strName
				FROM dbo.tblEMEntity
	) E ON C.intEntityId = E.intEntityId
) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityId



