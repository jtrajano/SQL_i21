
CREATE FUNCTION fn_GetGLAccountIDFromOriginToi21(@strOriginAccountID AS NVARCHAR(16))	
RETURNS INT 
AS
BEGIN 

	DECLARE @intAccountID INT

	SELECT	@intAccountID = inti21ID 
	FROM	dbo.tblGLCOACrossReference 
	WHERE	strExternalID = @strOriginAccountID

	RETURN @intAccountID
END