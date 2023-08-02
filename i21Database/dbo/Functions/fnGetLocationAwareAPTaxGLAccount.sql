CREATE FUNCTION [dbo].[fnGetLocationAwareAPTaxGLAccount] (
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
			@intGLAccountId_LocationSegment = dbo.fnGetGLAccountIdFromProfitCenter(
				@intAccountId
				, intProfitCenter
			)	
	FROM	dbo.tblSMCompanyLocation
			CROSS APPLY (
				SELECT TOP 1 
					ysnOverrideLocationSegment
				FROM 
					tblAPCompanyPreference
			) preference 
	WHERE	intCompanyLocationId = @intLocationId
			AND preference.ysnOverrideLocationSegment = 1
			AND @intAccountId IS NOT NULL

	SELECT	@intGLAccountId_LocationSegment = @intAccountId
	FROM	tblAPCompanyPreference preference
	WHERE	preference.ysnOverrideLocationSegment = 0 OR preference.ysnOverrideLocationSegment IS NULL 

	-- Generate the gl account id based on "company" segment. 
	SELECT	TOP 1
			@intGLAccountId_CompanySegment = dbo.fnGetGLAccountIdFromProfitCenter(
				ISNULL(@intGLAccountId_LocationSegment, @intAccountId)
				, intCompanySegment
			)
	FROM	dbo.tblSMCompanyLocation
			CROSS APPLY (
				SELECT TOP 1 
					ysnOverrideCompanySegment
				FROM 
					tblAPCompanyPreference
			) preference 
	WHERE	intCompanyLocationId = @intLocationId			
			AND preference.ysnOverrideCompanySegment = 1
			AND ISNULL(@intGLAccountId_LocationSegment, @intAccountId) IS NOT NULL 

	SELECT	@intGLAccountId_CompanySegment = @intGLAccountId_LocationSegment
	FROM	tblAPCompanyPreference preference
	WHERE	preference.ysnOverrideCompanySegment = 0 OR preference.ysnOverrideCompanySegment IS NULL 

	RETURN COALESCE(@intGLAccountId_CompanySegment, @intGLAccountId_LocationSegment) 
END 