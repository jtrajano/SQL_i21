CREATE PROCEDURE [dbo].[uspARPOSUpdateCashPaymentReceived]
	 @intPOSEndOfDayId INT
	,@intPaymentId INT
	,@strMessage AS VARCHAR(50) OUTPUT 
AS
BEGIN
	UPDATE POSPAYMENT
	SET
		  POSPAYMENT.intPOSEndOfDayId = @intPOSEndOfDayId
		, POSPAYMENT.intPaymentId = @intPaymentId
	FROM tblARPaymentDetail PAYMENTDETAIL
	INNER JOIN tblARPOS POS ON PAYMENTDETAIL.intInvoiceId = POS.intInvoiceId
	INNER JOIN tblARPOSPayment POSPAYMENT ON POS.intPOSId = POSPAYMENT.intPOSId
	WHERE PAYMENTDETAIL.intPaymentId = @intPaymentId

END
GO