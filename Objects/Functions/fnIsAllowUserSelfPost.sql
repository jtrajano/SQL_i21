CREATE FUNCTION [dbo].[fnIsAllowUserSelfPost] (
	@intEntityUserSecurityId INT
)
RETURNS BIT
AS 
BEGIN 
	DECLARE @ysnAllowUserSelfPost BIT 

	SELECT @ysnAllowUserSelfPost = ysnAllowUserSelfPost 
	FROM dbo.tblSMUserPreference 
	WHERE intEntityUserSecurityId = @intEntityUserSecurityId

	RETURN ISNULL(@ysnAllowUserSelfPost, 0)
END
GO