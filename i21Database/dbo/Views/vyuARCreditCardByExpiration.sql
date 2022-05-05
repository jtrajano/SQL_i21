CREATE VIEW  vyuARCreditCardByExpiration 
AS

SELECT ROW_NUMBER() OVER (ORDER BY P.intPaymentId) [intId],
CI.strCardExpDate,
CI.strCreditCardNumber,
I.dtmDate [dtmLastInvoiceDate],
CAST(CASE WHEN I.ysnPaid = 1 THEN 0 ELSE 1 END AS BIT) [ysnOpenInvoices],
CI.ysnActive,
cus.strCustomerNumber,
cus.strName
FROM tblARPayment P
INNER join vyuARPaymentMethodForReceivePayments PMR ON P.intPaymentMethodId=PMR.intPaymentMethodID and intPaymentMethodID =11 and P.intEntityCustomerId=PMR.intEntityId
INNER join tblARPaymentDetail PD ON P.intPaymentId=PD.intPaymentId
INNER JOIN tblARInvoice I ON I.intInvoiceId=PD.intInvoiceId
INNER JOIN tblEMEntityCardInformation CI ON CI.strCreditCardNumber=P.strPaymentMethod and CI.intEntityId=P.intEntityCustomerId
INNER JOIN vyuARCustomer cus ON cus.intEntityId=CI.intEntityId
