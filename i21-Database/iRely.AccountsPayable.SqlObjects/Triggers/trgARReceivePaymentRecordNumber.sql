CREATE TRIGGER trgARReceivePaymentRecordNumber
ON tblARPayment
AFTER INSERT
AS

DECLARE @inserted TABLE(intPaymentId INT, intCompanyLocationId INT, strRecordNumber NVARCHAR(25) COLLATE Latin1_General_CI_AS)
DECLARE @count INT = 0
DECLARE @intPaymentId INT
DECLARE @intCompanyLocationId INT
DECLARE @PaymentId NVARCHAR(50)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intPaymentId, intLocationId, strRecordNumber FROM INSERTED ORDER BY intPaymentId

WHILE((SELECT TOP 1 1 FROM @inserted WHERE RTRIM(LTRIM(ISNULL(strRecordNumber,''))) = '') IS NOT NULL)
BEGIN	
	SELECT TOP 1 @intPaymentId = intPaymentId, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARPayment WHERE strRecordNumber = @PaymentId)
			BEGIN
				SET @PaymentId = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strRecordNumber, 5, 10))) FROM tblARPayment
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 17
				EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId		
			END
		
		UPDATE tblARPayment
			SET tblARPayment.strRecordNumber = @PaymentId
		FROM tblARPayment A
		WHERE A.intPaymentId = @intPaymentId
	END

	DELETE FROM @inserted
	WHERE intPaymentId = @intPaymentId

END