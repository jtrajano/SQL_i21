CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT P.intPaymentId
     , P.strRecordNumber
	 , P.intEntityId
	 , P.intEntityCustomerId
	 , P.intBankAccountId
	 , LTRIM(RTRIM(BA.strBankAccountNo)) AS strBankAccountNo
	 , LTRIM(RTRIM(E.strName)) AS strCustomerName
	 , ISNULL(C.strCustomerNumber, E.strEntityNo) AS strCustomerNumber
	 , P.dtmDatePaid
	 , P.intPaymentMethodId
	 , PM.strPaymentMethod AS strPaymentMethod
	 , P.dblAmountPaid AS dblAmountPaid
	 , P.ysnPosted
	 , 'Payment' AS strPaymentType
	 , dbo.fnARGetInvoiceNumbersFromPayment(intPaymentId) AS strInvoices
FROM tblARPayment P 
	LEFT JOIN tblSMPaymentMethod PM ON P.intPaymentMethodId = PM.intPaymentMethodID
	LEFT JOIN (tblARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = P.intEntityCustomerId
	LEFT JOIN tblCMBankAccount BA ON P.intBankAccountId = BA.intBankAccountId