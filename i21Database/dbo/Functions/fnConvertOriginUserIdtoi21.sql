-- This function retrieves the user id from Origin and tries to get its equivalent in i21. 
CREATE FUNCTION [dbo].[fnConvertOriginUserIdtoi21](@user_id AS NVARCHAR(MAX))
RETURNS INT
AS
BEGIN 

DECLARE @intUserId AS INT 

SELECT TOP 1 
		@intUserId = intUserSecurityID
FROM	tblSMUserSecurity
WHERE	strUserName = LTRIM(RTRIM(@user_id)) 

RETURN @intUserId
		
END
