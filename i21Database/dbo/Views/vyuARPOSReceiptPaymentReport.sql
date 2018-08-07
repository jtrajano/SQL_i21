CREATE VIEW [dbo].[vyuARPOSReceiptPaymentReport]
AS
SELECT intPOSId			= POS.intPOSId
	 , dblTotal			= POS.dblTotal
	 , strPaymentMethod	= PAYMENT.strPaymentMethod
	 , strReferenceNo	= PAYMENT.strReferenceNo
	 , dblAmount		= PAYMENT.dblAmountTendered
	 , dblTotalAmount	= TOTAL.dblTotalAmount
FROM tblARPOS POS 
INNER JOIN tblARPOSPayment PAYMENT ON POS.intPOSId = PAYMENT.intPOSId
CROSS APPLY (
	SELECT dblTotalAmount = SUM(POSP.dblAmountTendered) 
	FROM tblARPOSPayment POSP
	WHERE POSP.intPOSId = POS.intPOSId
) TOTAL