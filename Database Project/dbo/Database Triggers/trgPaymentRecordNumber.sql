CREATE TRIGGER trgPaymentRecordNumber
ON tblAPPayment
AFTER INSERT
AS
	DECLARE @PaymentId NVARCHAR(50)
	SELECT @PaymentId = strPrefix + CONVERT(NVARCHAR,intNumber + 1) 
		FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Payable' AND ysnEnable = 1
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
	UPDATE tblAPPayment
		SET tblAPPayment.strPaymentRecordNum = @PaymentId
	FROM tblAPPayment A
		INNER JOIN INSERTED B ON A.intPaymentId = B.intPaymentId
	END

	UPDATE tblSMStartingNumber
		SET intNumber = intNumber + 1
	WHERE strTransactionType = 'Payable' AND ysnEnable = 1