CREATE VIEW [dbo].[vyuARCustomerPaymentHistoryReport]
AS 
SELECT C.strName
	 , strCompanyName		= (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
     , strCompanyAddress	= (SELECT TOP 1 dbo.[fnARFormatCustomerAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0) FROM tblSMCompanySetup)
	 , strContact			= [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, 0)
	 , strPaymentMethod		= PM.strPaymentMethod
	 , PAYMENT1.*
FROM ( 

SELECT I.strInvoiceNumber
	 , I.intEntityCustomerId
	 , I.intInvoiceId	 
	 , I.intCompanyLocationId
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strRecordNumber		= PAYMENTS.strRecordNumber	 
	 , dtmDatePaid			= PAYMENTS.dtmDatePaid
	 , dblAmountPaid		= ISNULL(PAYMENTS.dblAmountPaid, 0)
	 , dblAmountApplied		= ISNULL(PAYMENTS.dblPayment, 0)
	 , dblInvoiceTotal		= ISNULL(PAYMENTS.dblInvoiceTotal, 0)
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(PAYMENTS.dblAmountDue, 0) * -1 ELSE ISNULL(PAYMENTS.dblAmountDue, 0) END	 
	 , intPaymentId			= PAYMENTS.intPaymentId	 
	 , intPaymentMethodId	= PAYMENTS.intPaymentMethodId	 
	 , strReferenceNumber	= PAYMENTS.strPaymentInfo	 
	 , Item.intCommodityId
	 , dblUnappliedAmount	= ISNULL(PAYMENTS.dblUnappliedAmount, 0)
	 , I.intAccountId
FROM tblARInvoice I	
	LEFT JOIN tblARInvoiceDetail D ON I.intInvoiceId = D.intInvoiceId
	LEFT JOIN tblICItem Item ON D.intItemId = Item.intItemId
	LEFT JOIN (
		SELECT strRecordNumber	= P.strRecordNumber
		     , P.dtmDatePaid
			 , P.dblAmountPaid			 
			 , PD.dblPayment
			 , dblInvoiceTotal	= PD.dblInvoiceTotal
			 , PD.dblAmountDue
			 , P.intPaymentId
			 , P.intPaymentMethodId
			 , P.strPaymentInfo
			 , P.dblUnappliedAmount
			 , PD.intInvoiceId
		FROM tblARPayment P
			INNER JOIN tblARPaymentDetail PD 
				ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1
		
		UNION ALL

		SELECT strRecordNumber		= APP.strPaymentRecordNum
		     , APP.dtmDatePaid
			 , APP.dblAmountPaid
			 , APPD.dblPayment
			 , dblInvoiceTotal		= APPD.dblTotal
			 , APPD.dblAmountDue
			 , APP.intPaymentId
			 , APP.intPaymentMethodId
			 , APP.strPaymentInfo
			 , dblUnappliedAmount	= APP.dblUnapplied
			 , APPD.intInvoiceId
		FROM tblAPPayment APP
			INNER JOIN tblAPPaymentDetail APPD
				ON APP.intPaymentId = APPD.intPaymentId AND APP.ysnPosted = 1
	) AS PAYMENTS
		ON I.intInvoiceId = PAYMENTS.intInvoiceId	
WHERE I.ysnPosted = 1
  AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))

UNION ALL

SELECT I.strInvoiceNumber
	 , I.intEntityCustomerId
	 , I.intInvoiceId	 
	 , I.intCompanyLocationId
	 , ysnPaid				= CASE WHEN I.ysnPaid = 1 THEN 'Yes' ELSE 'No' END
	 , strRecordNumber		= PREPAYMENT.strRecordNumber	 
	 , dtmDatePaid			= PREPAYMENT.dtmDatePaid
	 , dblAmountPaid		= ISNULL(PREPAYMENT.dblAmountPaid, 0)
	 , dblAmountApplied		= 0
	 , dblInvoiceTotal		= 0
	 , dblAmountDue			= CASE WHEN I.strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END	 
	 , intPaymentId			= PREPAYMENT.intPaymentId	 
	 , intPaymentMethodId	= PREPAYMENT.intPaymentMethodId	 
	 , strReferenceNumber	= PREPAYMENT.strPaymentInfo	 
	 , intCommodityId		= NULL
	 , dblUnappliedAmount	= ISNULL(PREPAYMENT.dblUnappliedAmount, 0)
	 , I.intAccountId
FROM tblARInvoice I
	INNER JOIN tblARPayment PREPAYMENT
		ON I.intEntityCustomerId = PREPAYMENT.intEntityCustomerId AND I.intPaymentId = PREPAYMENT.intPaymentId
WHERE I.ysnPosted = 1 AND I.strTransactionType = 'Customer Prepayment'
) AS PAYMENT1

INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) 
		ON PAYMENT1.intEntityCustomerId = C.intEntityCustomerId
LEFT JOIN tblSMPaymentMethod PM
		ON PAYMENT1.intPaymentMethodId = PM.intPaymentMethodID
 
WHERE PAYMENT1.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments'))