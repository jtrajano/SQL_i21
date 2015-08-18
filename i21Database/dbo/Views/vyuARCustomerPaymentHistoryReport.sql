CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT * FROM (
SELECT DISTINCT 
	  C.strName
	 , strContact = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry)
	 , P.strRecordNumber
	 , I.strInvoiceNumber
	 , P.dtmDatePaid
	 , dblAmountPaid	= ISNULL(P.dblAmountPaid, 0)
	 , dblAmountApplied = ISNULL(PD.dblPayment, 0)
	 , dblInvoiceTotal	= ISNULL(PD.dblInvoiceTotal, 0)
	 , dblAmountDue		= CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(PD.dblAmountDue, 0) * -1 ELSE ISNULL(PD.dblAmountDue, 0) END
	 , ysnPaid			= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , P.intPaymentId	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , I.intInvoiceId	 
	 , I.intCompanyLocationId
	 , Item.intCommodityId
FROM tblARInvoice I
	LEFT JOIN (tblARPayment P INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId 
							  LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) 
		ON I.intEntityCustomerId = P.intEntityCustomerId  AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) 
		ON I.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN tblARInvoiceDetail D ON I.intInvoiceId = D.intInvoiceId
	LEFT JOIN tblICItem Item ON D.intItemId = Item.intItemId	
WHERE I.ysnPosted = 1 AND P.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')) AS A
LEFT JOIN 
(SELECT grandDblAmountPaid = SUM(dblAmountPaid)
	 , intEntityCustomer     = intEntityCustomerId
FROM
(SELECT DISTINCT
	   intEntityCustomerId
	 , dblAmountPaid	 
FROM tblARPayment P 
	INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
WHERE P.ysnPosted = 1) AS TBL
GROUP BY intEntityCustomerId) B

ON A.intEntityCustomerId = B.intEntityCustomer