CREATE FUNCTION [dbo].[fnGetEntityIdFromUser]
(
	@intUserSecurityId INT
)
RETURNS INT
AS
BEGIN 

	DECLARE @EntityId INT
	
	SELECT TOP 1 @EntityId = [intEntityUserSecurityId] FROM tblSMUserSecurity
	WHERE [intEntityUserSecurityId] = @intUserSecurityId

	RETURN @EntityId
	
END