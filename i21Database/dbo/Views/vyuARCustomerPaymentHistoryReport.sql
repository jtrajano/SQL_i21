﻿CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT DISTINCT 
	  C.strName
	, strContact = ISNULL(RTRIM(C.strPhone) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToLocationName) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToAddress) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToCity), '')
				  + ISNULL(', ' + RTRIM(C.strBillToState), '')
				  + ISNULL(', ' + RTRIM(C.strZipCode), '')
				  + ISNULL(', ' + RTRIM(C.strBillToCountry), '')
	 , P.strRecordNumber
	 , I.strInvoiceNumber
	 , P.dtmDatePaid
	 , dblAmountPaid = ISNULL(P.dblAmountPaid, 0)
	 , dblAmountApplied = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END	 
	 , dblInvoiceTotal = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END	 
	 , dblAmountDue = ISNULL(PD.dblAmountDue, 0)
	 , ysnPaid = CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , P.intPaymentId	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , I.intInvoiceId	 
FROM tblARInvoice I
	LEFT JOIN (tblARPayment P INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId 
							  LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) ON I.intEntityCustomerId = P.intEntityCustomerId  AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON I.intEntityCustomerId = C.intEntityCustomerId		
WHERE I.ysnPosted = 1 AND P.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')