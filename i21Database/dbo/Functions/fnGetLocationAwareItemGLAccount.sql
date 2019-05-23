CREATE FUNCTION [dbo].[fnGetLocationAwareItemGLAccount] (
	@intAccountId INT
	,@intItemLocationId INT
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SELECT	@intGLAccountId = dbo.fnGetGLAccountIdFromProfitCenter(@intAccountId, dbo.fnGetItemProfitCenter(tblICItemLocation.intLocationId))	
	FROM	dbo.tblICItemLocation
	WHERE	intItemLocationId = @intItemLocationId

	RETURN @intGLAccountId
END 