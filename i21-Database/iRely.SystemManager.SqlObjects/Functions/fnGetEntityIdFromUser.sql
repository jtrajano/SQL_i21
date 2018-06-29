CREATE FUNCTION [dbo].[fnGetEntityIdFromUser]
(
	@intUserSecurityId INT
)
RETURNS INT
AS
BEGIN 

	DECLARE @EntityId INT
	
	SELECT TOP 1 @EntityId = [intEntityId] FROM tblSMUserSecurity
	WHERE [intEntityId] = @intUserSecurityId

	RETURN @EntityId
	
END