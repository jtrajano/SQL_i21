CREATE VIEW [dbo].[vyuARCustomerInvoiceHistoryReport]
AS
SELECT DISTINCT
	   C.strName	 
	 , strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
	 , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
     , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
	 , strRecordNumber		= PAYMENTS.strRecordNumber
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , dtmDatePaid			= PAYMENTS.dtmDatePaid
	 , dblAmountPaid		= ISNULL(PAYMENTS.dblPayment, 0)
	 , dblAmountApplied		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblInvoiceTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , intPaymentId			= PAYMENTS.intPaymentId
	 , I.intEntityCustomerId
	 , strPaymentMethod		= PM.strPaymentMethod
	 , I.intInvoiceId
FROM tblARInvoice I
	LEFT JOIN (SELECT P.intPaymentId
				   , P.intPaymentMethodId
				   , P.strRecordNumber
				   , P.dtmDatePaid
				   , PD.dblPayment
				   , PD.intInvoiceId
			  FROM tblARPaymentDetail PD 
				INNER JOIN tblARPayment P 
					ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1

			  UNION ALL

			  SELECT APP.intPaymentId
				   , APP.intPaymentMethodId
				   , APP.strPaymentRecordNum
				   , APP.dtmDatePaid
				   , APPD.dblPayment
				   , APPD.intInvoiceId 
			  FROM tblAPPaymentDetail APPD 
				INNER JOIN tblAPPayment APP 
				  ON APP.intPaymentId = APPD.intPaymentId AND APP.ysnPosted = 1 AND APPD.intInvoiceId IS NOT NULL

			  UNION ALL

			  SELECT PC.intPrepaymentId
				   , NULL
				   , PCI.strInvoiceNumber
				   , PCI.dtmPostDate
				   , PC.dblAppliedInvoiceAmount
				   , PC.intInvoiceId
			  FROM tblARPrepaidAndCredit PC
				INNER JOIN tblARInvoice PCI
					ON PC.intPrepaymentId = PCI.intInvoiceId AND PC.ysnApplied = 1) PAYMENTS ON PAYMENTS.intInvoiceId = I.intInvoiceId
	LEFT JOIN tblSMPaymentMethod PM ON PAYMENTS.intPaymentMethodId = PM.intPaymentMethodID
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.[intEntityId] = CC.[intEntityId] AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.[intEntityId]
WHERE I.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'Undeposited Funds'))