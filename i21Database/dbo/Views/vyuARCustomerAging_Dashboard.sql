CREATE VIEW vyuARCustomerAging_DashBoard
AS
WITH Query AS
(
SELECT
	I.intEntityCustomerId,
	strCustomerName = E.strName,
	dblTotalDue = SUM(dblTotalDue) - SUM(dblAvailableCredit) - SUM(dblPrepayments)
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN vyuARCustomerAgingSubview Z ON Z.intEntityCustomerId = I.intEntityCustomerId 
JOIN tblARCustomer C WITH (NOLOCK) ON I.intEntityCustomerId = C.intEntityId
JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
JOIN vyuGLAccountDetail GL ON I.intAccountId = GL.intAccountId AND GL.strAccountCategory IN ('AR Account', 'Customer Prepayments')
AND Z.intInvoiceId = I.intInvoiceId
AND I.ysnPosted = 1
AND I.ysnCancelled = 0
AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) 
OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) 
OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= GETDATE()
GROUP BY I.intEntityCustomerId,E.strName )
SELECT TOP 5 * FROM Query ORDER by dblTotalDue DESC