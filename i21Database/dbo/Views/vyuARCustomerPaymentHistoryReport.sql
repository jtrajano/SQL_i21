CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT DISTINCT C.strName
	 , I.intInvoiceId
	 , I.strInvoiceNumber
	 , I.intEntityCustomerId
	 , dblInvoiceTotal = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , P.intPaymentId
	 , P.strRecordNumber
	 , PD.dblPayment AS dblAmountPaidDetail
	 , P.dblAmountPaid AS dblAmountPaid
	 , P.dtmDatePaid	 
	 , dblAmountDue = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(PD.dblAmountDue, 0) * -1 ELSE ISNULL(PD.dblAmountDue, 0) END
	 , PD.intTermId
	 , T.strTerm
	 , PM.strPaymentMethod
	 , strContact = ISNULL(RTRIM(C.strPhone) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToLocationName) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToAddress) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToCity), '')
				  + ISNULL(', ' + RTRIM(C.strBillToState), '')
				  + ISNULL(', ' + RTRIM(C.strZipCode), '')
				  + ISNULL(', ' + RTRIM(C.strBillToCountry), '')
	 , ysnPaid = CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
FROM tblARInvoice I
	LEFT JOIN (tblARPayment P INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId 
							  LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) ON I.intEntityCustomerId = P.intEntityCustomerId  AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON I.intEntityCustomerId = C.intEntityCustomerId	
	INNER JOIN tblSMTerm T ON PD.intTermId = T.intTermID
WHERE I.ysnPosted = 1 AND P.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')