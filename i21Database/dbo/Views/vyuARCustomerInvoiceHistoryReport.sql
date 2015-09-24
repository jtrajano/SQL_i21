﻿CREATE VIEW [dbo].[vyuARCustomerInvoiceHistoryReport]
AS
SELECT * FROM (
SELECT DISTINCT
	  C.strName
	 , strContact = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL)
	 , P.strRecordNumber
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , P.dtmDatePaid
	 , dblAmountPaid    = ISNULL(PD.dblPayment, 0)
	 , dblAmountApplied = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblInvoiceTotal  = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountDue     = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , ysnPaid = CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , P.intPaymentId	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , I.intInvoiceId	 
FROM tblARInvoice I
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId 
							         LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) 
		ON I.intEntityCustomerId = P.intEntityCustomerId AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE I.ysnPosted = 1 AND P.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')) AS A
LEFT JOIN 
(SELECT grandDblInvoiceTotal = SUM(ISNULL(dblInvoiceTotal, 0))
     , grandDblAmountApplied = SUM(ISNULL(dblPayment, 0))
	 , grandDblAmountDue     = SUM(ISNULL(dblAmountDue, 0))
	 , intTotalCount	     = COUNT(*)
	 , intEntityCustomer     = intEntityCustomerId
FROM
(SELECT DISTINCT
       dblInvoiceTotal = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
     , dblPayment      = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblAmountDue    = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , I.intInvoiceId
	 , I.intEntityCustomerId
FROM tblARInvoice I
	INNER JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId) 
		ON  PD.intInvoiceId = I.intInvoiceId
	    AND P.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1
  AND P.ysnPosted = 1) AS TBL
GROUP BY intEntityCustomerId) B

ON A.intEntityCustomerId = B.intEntityCustomer