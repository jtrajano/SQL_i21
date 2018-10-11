CREATE VIEW [dbo].[vyuARPOSReceiptPaymentReport]
AS
SELECT intPOSId			= POS.intPOSId
	 , dblTotal			= CASE WHEN POS.ysnReturn = 1 THEN POS.dblTotal * -1 ELSE POS.dblTotal END
	 , strPaymentMethod	= PAYMENT.strPaymentMethod
	 , strReferenceNo	= CASE WHEN PAYMENT.strPaymentMethod = 'Check' THEN ' # ' + PAYMENT.strReferenceNo ELSE PAYMENT.strReferenceNo END
	 , dblAmount		= CASE WHEN POS.ysnReturn = 1 THEN PAYMENT.dblAmountTendered * -1 ELSE PAYMENT.dblAmountTendered END
	 , dblTotalAmount	= CASE WHEN POS.ysnReturn = 1 THEN TOTAL.dblTotalAmount * -1 ELSE TOTAL.dblTotalAmount END
FROM tblARPOS POS 
INNER JOIN tblARPOSPayment PAYMENT ON POS.intPOSId = PAYMENT.intPOSId
CROSS APPLY (
	SELECT dblTotalAmount = SUM(POSP.dblAmountTendered) 
	FROM tblARPOSPayment POSP
	WHERE POSP.intPOSId = POS.intPOSId
) TOTAL