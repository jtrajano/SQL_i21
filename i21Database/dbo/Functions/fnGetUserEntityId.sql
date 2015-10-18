CREATE FUNCTION [dbo].[fnGetUserEntityId]
(
	@intUserId INT = NULL
)
RETURNS INT
AS
BEGIN 
	DECLARE @intEntityId AS INT
	
	SELECT	@intEntityId = [intEntityUserSecurityId]
	FROM	dbo.tblSMUserSecurity
	WHERE	[intEntityUserSecurityId] = @intUserId

	RETURN @intEntityId
END 