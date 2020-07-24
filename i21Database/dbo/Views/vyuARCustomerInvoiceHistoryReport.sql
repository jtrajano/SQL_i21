CREATE VIEW [dbo].[vyuARCustomerInvoiceHistoryReport]
AS
SELECT DISTINCT
	   C.strName	 
	 , strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	 , strCompanyName		= COMPANY.strCompanyName
     , strCompanyAddress	= COMPANY.strCompanyAddress
	 , strRecordNumber		= PAYMENTS.strRecordNumber
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , dtmDatePaid			= PAYMENTS.dtmDatePaid
	 , dblAmountPaid		= ISNULL(PAYMENTS.dblPayment, 0)
	 , dblAmountApplied		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblInvoiceTotal		= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END COLLATE Latin1_General_CI_AS
	 , intPaymentId			= PAYMENTS.intPaymentId
	 , I.intEntityCustomerId
	 , strPaymentMethod		= PM.strPaymentMethod
	 , I.intInvoiceId
	 , strPeriod		    = AccPeriod.strPeriod
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
OUTER APPLY (
	SELECT TOP 1 strCompanyName
			   , strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY(
	SELECT strPeriod from tblGLFiscalYearPeriod P
	WHERE I.intPeriodId = P.intGLFiscalYearPeriodId
) AccPeriod
WHERE I.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments', 'Undeposited Funds'))