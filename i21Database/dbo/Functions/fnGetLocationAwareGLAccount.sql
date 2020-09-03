CREATE FUNCTION [dbo].[fnGetLocationAwareGLAccount] (
	@intAccountId INT
	,@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SELECT	TOP 1 
			@intGLAccountId = dbo.fnGetGLAccountIdFromProfitCenter(@intAccountId, intProfitCenter)	
	FROM	dbo.tblSMCompanyLocation
	WHERE	intCompanyLocationId = @intLocationId

	RETURN @intGLAccountId
END 