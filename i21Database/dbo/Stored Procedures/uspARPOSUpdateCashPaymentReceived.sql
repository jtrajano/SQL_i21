CREATE PROCEDURE [dbo].[uspARPOSUpdateCashPaymentReceived]
	 @intPOSEndOfDayId INT
	,@intPaymentId INT
	,@strMessage AS VARCHAR(50) OUTPUT 
AS
BEGIN

	IF EXISTS(SELECT TOP 1 NULL FROM tblARPayment WHERE intPaymentId = @intPaymentId)
	BEGIN
		UPDATE POSPAYMENT
		SET
			  POSPAYMENT.intPOSEndOfDayId = @intPOSEndOfDayId
			, POSPAYMENT.intPaymentId = @intPaymentId
		FROM tblARPaymentDetail PAYMENTDETAIL
		INNER JOIN tblARPOS POS ON PAYMENTDETAIL.intInvoiceId = POS.intInvoiceId
		INNER JOIN tblARPOSPayment POSPAYMENT ON POS.intPOSId = POSPAYMENT.intPOSId
		WHERE PAYMENTDETAIL.intPaymentId = @intPaymentId

		UPDATE EOD 
		SET
			dblCashPaymentReceived = ISNULL(dblCashPaymentReceived, 0.000000) + PAYMENTDETAIL.dblPayment
		FROM tblARPOSEndOfDay EOD
		INNER JOIN tblARPOSPayment POSPAYMENT ON EOD.intPOSEndOfDayId = POSPAYMENT.intPOSEndOfDayId
		INNER JOIN tblARPaymentDetail PAYMENTDETAIL ON POSPAYMENT.intPaymentId = PAYMENTDETAIL.intPaymentId
		INNER JOIN tblARPayment PAYMENT ON POSPAYMENT.intPaymentId = PAYMENT.intPaymentId
		INNER JOIN tblSMPaymentMethod PAYMENTMETHOD ON PAYMENT.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodID
		WHERE POSPAYMENT.intPaymentId = @intPaymentId AND PAYMENTMETHOD.strPaymentMethod IN('Cash', 'Check')
	END

END
GO