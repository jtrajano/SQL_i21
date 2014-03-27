
CREATE FUNCTION fnGetGLAccountIdFromOriginToi21(@strOriginAccountId AS NVARCHAR(16))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intAccountId INT

	SELECT	@intAccountId = inti21Id 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	strExternalId = @strOriginAccountId

	RETURN @intAccountId
END