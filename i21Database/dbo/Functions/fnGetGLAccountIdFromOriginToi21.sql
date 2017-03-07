
CREATE FUNCTION fnGetGLAccountIdFromOriginToi21(@strOriginAccountId AS NVARCHAR(50))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intAccountId INT

	SELECT	@intAccountId = inti21Id 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	ABS(strExternalId) = @strOriginAccountId

	RETURN @intAccountId
END