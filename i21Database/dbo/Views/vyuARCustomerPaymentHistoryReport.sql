CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT DISTINCT 
	  C.strName
	, strContact = [dbo].fnARFormatCustomerAddress(C.strPhone, E.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry)
	 , P.strRecordNumber
	 , I.strInvoiceNumber
	 , P.dtmDatePaid
	 , dblAmountPaid = ISNULL(PD.dblPayment, 0)
	 , dblAmountApplied = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END	 
	 , dblInvoiceTotal = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END	 
	 , dblAmountDue = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(PD.dblAmountDue, 0) * -1 ELSE ISNULL(PD.dblAmountDue, 0) END
	 , ysnPaid = CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , P.intPaymentId	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , I.intInvoiceId	 
	 , I.intCompanyLocationId
	 , Item.intCommodityId
FROM tblARInvoice I
	LEFT JOIN (tblARPayment P INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId 
							  LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) ON I.intEntityCustomerId = P.intEntityCustomerId  AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON I.intEntityCustomerId = C.intEntityCustomerId		
	LEFT OUTER JOIN tblARInvoiceDetail D ON I.intInvoiceId = D.intInvoiceId
	INNER JOIN tblICItem Item ON D.intItemId = Item.intItemId	
WHERE I.ysnPosted = 1 AND P.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')