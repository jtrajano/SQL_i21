CREATE FUNCTION [dbo].[fnGetUserEntityId]
(
	@intUserId INT = NULL
)
RETURNS INT
AS
BEGIN 
	DECLARE @intEntityId AS INT
	
	SELECT	@intEntityId = [intEntityId]
	FROM	dbo.tblSMUserSecurity
	WHERE	[intEntityId] = @intUserId

	RETURN @intEntityId
END 