
CREATE FUNCTION fnCMGetGLAccountIdFromOriginToi21(@strOriginAccountId AS NVARCHAR(16))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intAccountID INT

	SELECT	@intAccountID = inti21ID 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	strExternalID = @strOriginAccountId

	RETURN @intAccountID
END