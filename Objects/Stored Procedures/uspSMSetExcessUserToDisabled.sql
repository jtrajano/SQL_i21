CREATE PROCEDURE [uspSMSetExcessUserToDisabled]
@intEntityId INT 
AS
BEGIN
	UPDATE tblSMUserSecurity SET ysnDisabled = 1 WHERE intEntityId >= @intEntityId
END



