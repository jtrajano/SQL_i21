CREATE PROCEDURE [dbo].[uspEMUpdateEntityCredential]
	@intEntityId  INT,
	@intEntityContactId  INT,
	@strUsername AS NVARCHAR(50)	
AS
BEGIN
	DECLARE @isDefaultContact AS BIT
	SET @isDefaultContact = (SELECT ysnDefaultContact FROM tblEMEntityToContact WHERE intEntityId = @intEntityId AND intEntityContactId = @intEntityContactId)
	DECLARE @isExist AS BIT
	SET @isExist = (SELECT 1 FROM tblEMEntityCredential WHERE intEntityId = @intEntityContactId)

	IF(@isExist = 1 AND @isDefaultContact = 1)
	BEGIN
		UPDATE tblEMEntityCredential
		SET strUserName = @strUsername
		WHERE intEntityId = @intEntityContactId
	END
END
GO