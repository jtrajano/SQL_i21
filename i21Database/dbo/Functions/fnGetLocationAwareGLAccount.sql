CREATE FUNCTION [dbo].[fnGetLocationAwareGLAccount] (
	@intAccountId INT
	,@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId_LocationSegment AS INT
			,@intGLAccountId_CompanySegment AS INT 

	-- Generate the gl account id based on "location" segment. 
	SELECT	TOP 1 
			@intGLAccountId_LocationSegment = dbo.fnGetGLAccountIdFromProfitCenter(@intAccountId, intProfitCenter)	
	FROM	dbo.tblSMCompanyLocation
	WHERE	intCompanyLocationId = @intLocationId

	-- Generate the gl account id based on "company" segment. 
	SELECT	TOP 1
			@intGLAccountId_CompanySegment = dbo.fnGetGLAccountIdFromProfitCenter(@intGLAccountId_LocationSegment, intCompanySegment)
	FROM	dbo.tblSMCompanyLocation
	WHERE	intCompanyLocationId = @intLocationId
			AND @intGLAccountId_LocationSegment IS NOT NULL 

	IF @intGLAccountId_CompanySegment IS NOT NULL 
		RETURN @intGLAccountId_CompanySegment
	
	RETURN @intGLAccountId_LocationSegment
END 