CREATE TRIGGER trgARPaymentDelete
ON dbo.tblARPayment
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @strRecordNumber NVARCHAR(50);
	DECLARE @intPaymentId INT;
	DECLARE @error NVARCHAR(500);

	SELECT @intPaymentId = intPaymentId, @strRecordNumber = strRecordNumber FROM deleted WHERE ysnPosted = 1 

	IF @intPaymentId > 0
		BEGIN
			SET @error = 'You cannot delete posted payment (' + @strRecordNumber + ')';
			RAISERROR(@error, 16, 1);
		END
	ELSE
		BEGIN
			DELETE A
			FROM tblARPayment A
			INNER JOIN DELETED B ON A.intPaymentId = B.intPaymentId
		END
END