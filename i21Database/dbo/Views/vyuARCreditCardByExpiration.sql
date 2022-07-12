CREATE VIEW  vyuARCreditCardByExpiration 
AS
SELECT intId				= ROW_NUMBER() OVER (ORDER BY P.intPaymentId)
	 , strCardExpDate		= CI.strCardExpDate
	 , strCreditCardNumber	= CI.strCreditCardNumber
	 , dtmLastInvoiceDate	= I.dtmDate 
	 , ysnOpenInvoices		= CAST(CASE WHEN I.ysnPaid = 1 THEN 0 ELSE 1 END AS BIT) 
	 , ysnActive			= CI.ysnActive
	 , strCustomerNumber	= CUS.strEntityNo
	 , strName				= CUS.strName
FROM tblARPayment P
INNER JOIN vyuARPaymentMethodForReceivePayments PMR ON P.intPaymentMethodId = PMR.intPaymentMethodID AND PMR.intPaymentMethodID = 11 AND P.intEntityCustomerId = PMR.intEntityId
INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
INNER JOIN tblARInvoice I ON I.intInvoiceId = PD.intInvoiceId
INNER JOIN tblEMEntityCardInformation CI ON CI.strCreditCardNumber = P.strPaymentMethod and CI.intEntityId = P.intEntityCustomerId
INNER JOIN tblEMEntity CUS ON CUS.intEntityId = CI.intEntityId