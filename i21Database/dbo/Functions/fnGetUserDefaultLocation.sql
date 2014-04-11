CREATE FUNCTION [dbo].[fnGetUserDefaultLocation]
(
	@UserId INT
)
RETURNS INT
AS
BEGIN 

DECLARE @intLocationId AS INT 

SELECT TOP 1 @intLocationId = intCompanyLocationId
FROM tblSMUserSecurity
WHERE intUserSecurityID = @UserId

RETURN @intLocationId
		
END