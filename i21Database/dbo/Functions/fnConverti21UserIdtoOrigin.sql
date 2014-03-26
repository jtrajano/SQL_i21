-- This function retrieves the user id from i21 and tries to get its equivalent in Origin. 
CREATE FUNCTION [dbo].[fnConverti21UserIdtoOrigin](@intUserId AS INT)
RETURNS CHAR(16)
AS
BEGIN 

DECLARE @strUserId AS CHAR(16)

SELECT TOP 1 
		@strUserId = UPPER(CAST(strUserName AS CHAR(16)))
FROM	tblSMUserSecurity
WHERE	intUserSecurityID = @intUserId

RETURN @strUserId
		
END
