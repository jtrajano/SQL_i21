CREATE TRIGGER [dbo].[trgSMDocumentCode]
ON [dbo].[tblSMDocumentMaintenance]
AFTER INSERT
AS

DECLARE @inserted TABLE(intDocumentId INT)
DECLARE @intDocumentId INT
DECLARE @strDocumentCode NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT [intDocumentMaintenanceId] FROM INSERTED ORDER BY [intDocumentMaintenanceId]
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intDocumentId = intDocumentId FROM @inserted

	EXEC uspSMGetStartingNumber 67, @strDocumentCode OUT

	IF(@strDocumentCode IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM [tblSMDocumentMaintenance] WHERE [strCode] = @strDocumentCode)
			BEGIN
				SET @strDocumentCode = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING([strCode], 5, 10))) FROM [tblSMDocumentMaintenance]
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 67
				EXEC uspSMGetStartingNumber 67, @strDocumentCode OUT
			END
		
		UPDATE [tblSMDocumentMaintenance]
			SET [tblSMDocumentMaintenance].[strCode] = @strDocumentCode
		FROM [tblSMDocumentMaintenance] A
		WHERE A.[intDocumentMaintenanceId] = @intDocumentId
	END

	DELETE FROM @inserted
	WHERE intDocumentId = @intDocumentId
END