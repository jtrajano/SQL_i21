﻿CREATE VIEW [dbo].[vyuARCustomerInvoiceHistoryReport]
AS
SELECT DISTINCT
	   C.strName	 
	 , strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
	 , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
     , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
	 , strRecordNumber		= ISNULL(P.strRecordNumber, APP.strPaymentRecordNum)
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , dtmDatePaid			= ISNULL(P.dtmDatePaid, APP.dtmDatePaid)
	 , dblAmountPaid		= ISNULL(ISNULL(PD.dblPayment, APPD.dblPayment), 0)
	 , dblAmountApplied		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblInvoiceTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , intPaymentId			= ISNULL(P.intPaymentId, APP.intPaymentId)	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , I.intInvoiceId
FROM tblARInvoice I
	LEFT JOIN (tblARPaymentDetail PD INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1
							         LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) 
		ON I.intEntityCustomerId = P.intEntityCustomerId AND PD.intInvoiceId = I.intInvoiceId
	LEFT JOIN (tblAPPaymentDetail APPD INNER JOIN tblAPPayment APP ON APP.intPaymentId = APPD.intPaymentId AND APP.ysnPosted = 1
									 LEFT JOIN tblSMPaymentMethod PM ON APP.intPaymentMethodId = PM.intPaymentMethodID) 
		ON APPD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE I.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'Undeposited Funds'))