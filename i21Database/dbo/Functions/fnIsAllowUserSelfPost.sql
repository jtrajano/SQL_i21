CREATE FUNCTION [dbo].[fnIsAllowUserSelfPost] (
	@intEntityUserSecurityId INT
)
RETURNS BIT
AS 
BEGIN 
	DECLARE @ysnAllowUserSelfPost BIT 

	SELECT	@ysnAllowUserSelfPost = 1  
	FROM	dbo.tblSMPreferences   
	WHERE	strPreference = 'AllowUserSelfPost'   
			AND LOWER(RTRIM(LTRIM(strValue))) = 'true'    
			AND intUserID = @intEntityUserSecurityId  

	RETURN ISNULL(@ysnAllowUserSelfPost, 0)
END
GO