CREATE VIEW [dbo].[vyuSMCreditCardPaymentHistory]
	AS SELECT SP.intTransactionId, ARP.intEntityCardInfoId, SP.strFrequency, SP.strPaymentMethod
FROM tblSMPayment SP
INNER JOIN (
	SELECT intEntityCardInfoId,  intPaymentId FROM tblARPayment
) ARP ON ARP.intPaymentId = SP.intTransactionId
WHERE SP.strPaymentMethod = 'Credit Card'
