CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT DISTINCT 
	   C.strName
	 , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
     , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
	 , strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
	 , P.strRecordNumber
	 , I.strInvoiceNumber
	 , P.dtmDatePaid
	 , dblAmountPaid		= ISNULL(P.dblAmountPaid, 0)
	 , dblAmountApplied		= ISNULL(PD.dblPayment, 0)
	 , dblInvoiceTotal		= ISNULL(PD.dblInvoiceTotal, 0)
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(PD.dblAmountDue, 0) * -1 ELSE ISNULL(PD.dblAmountDue, 0) END
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , P.intPaymentId	 
	 , I.intEntityCustomerId
	 , PM.strPaymentMethod
	 , strReferenceNumber	= P.strPaymentInfo
	 , I.intInvoiceId	 
	 , I.intCompanyLocationId
	 , Item.intCommodityId
	 , dblUnappliedAmount	= ISNULL(P.dblUnappliedAmount, 0)
FROM tblARInvoice I
	LEFT JOIN (tblARPayment P INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1
							  LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID) 
		ON I.intEntityCustomerId = P.intEntityCustomerId AND PD.intInvoiceId = I.intInvoiceId
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) 
		ON I.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN tblARInvoiceDetail D ON I.intInvoiceId = D.intInvoiceId
	LEFT JOIN tblICItem Item ON D.intItemId = Item.intItemId	
WHERE I.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))