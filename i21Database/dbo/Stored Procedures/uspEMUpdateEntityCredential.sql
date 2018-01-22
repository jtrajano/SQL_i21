CREATE PROCEDURE [dbo].[uspEMUpdateEntityCredential]
	@intEntityContactId  INT,
	@strUsername AS NVARCHAR(50)
AS
BEGIN
	DECLARE @isExist AS BIT
	SET @isExist = (SELECT 1 FROM tblEMEntityCredential WHERE intEntityId = @intEntityContactId)

	IF(@isExist = 1)
	BEGIN
		UPDATE tblEMEntityCredential
		SET strUserName = @strUsername
		WHERE intEntityId = @intEntityContactId
	END
END
GO