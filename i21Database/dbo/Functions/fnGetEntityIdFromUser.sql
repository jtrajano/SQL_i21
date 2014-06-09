CREATE FUNCTION [dbo].[fnGetEntityIdFromUser]
(
	@intUserSecurityId INT
)
RETURNS INT
AS
BEGIN 

	DECLARE @EntityId INT
	
	SELECT TOP 1 @EntityId = intEntityId FROM tblSMUserSecurity
	WHERE intUserSecurityID = @intUserSecurityId

	RETURN @EntityId
	
END