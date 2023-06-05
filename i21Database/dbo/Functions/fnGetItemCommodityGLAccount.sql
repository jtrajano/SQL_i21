
/*
 fnGetItemCommodityGLAccount is a function that returns the GL account id. 
 
 Parameters: 
	 @intItemId: The item id where the g/l account may have an override. 
	 @intLocationId: The location is where "default" g/l account id is defined. If nothing is found in the item level and category level, this is the g/l account id used. 
	 @strAccountDescription: The specific account description to retrieve. For example: "Inventory", "Cost of Goods"
	 @intCommodityId: The specific commodity to use for Line of Business 
 
 Sample usage: 
 DECLARE @intItemId AS INT
		 ,@intLocationId AS INT
		 ,@intCommodityId AS INT;
		 
 SET @intItemId = 1;
 SET @intLocationId = 1;
 SET @intCommodityId = 1;
 
 SELECT	Inventory = dbo.fnGetItemCommodityGLAccount(@intItemId, @intLocationId, 'Inventory', @intCommodityId)
		,COGS = dbo.fnGetItemCommodityGLAccount(@intItemId, @intLocationId, 'Cost of Goods', @intCommodityId)
 
*/

CREATE FUNCTION [dbo].[fnGetItemCommodityGLAccount] (
	@intItemId INT
	,@intItemLocationId INT
	,@strAccountDescription NVARCHAR(255)
	,@intCommodityId INT 
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId_LocationSegment AS INT
			,@intGLAccountId_CompanySegment AS INT 
			,@intGLAccountId_LOBSegment AS INT 


	-- Generate the gl account id based on "location" segment. 
	SELECT @intGLAccountId_LocationSegment = dbo.fnGetItemBaseGLAccount(@intItemId, @intItemLocationId, @strAccountDescription)
	SELECT	@intGLAccountId_LocationSegment = 
				dbo.fnGetGLAccountIdFromProfitCenter(
					@intGLAccountId_LocationSegment
					,dbo.fnGetItemProfitCenter(tblICItemLocation.intLocationId)
				)	
	FROM	dbo.tblICItemLocation
			CROSS APPLY (
				SELECT TOP 1 
					ysnOverrideLocationSegment
				FROM 
					tblICCompanyPreference
			) preference 
	WHERE	intItemLocationId = @intItemLocationId
			AND (preference.ysnOverrideLocationSegment = 1 OR preference.ysnOverrideLocationSegment IS NULL) 

	-- Generate the gl account id based on "company" segment. 
	SELECT	@intGLAccountId_CompanySegment = 			
				dbo.fnGetGLAccountIdFromProfitCenter(
					@intGLAccountId_LocationSegment
					,dbo.fnGetItemCompanySegment(tblICItemLocation.intLocationId)
				)
	FROM	dbo.tblICItemLocation
			CROSS APPLY (
				SELECT TOP 1 
					ysnOverrideCompanySegment
				FROM 
					tblICCompanyPreference
			) preference 
	WHERE
			intItemLocationId = @intItemLocationId
			AND @intGLAccountId_LocationSegment IS NOT NULL 
			AND (preference.ysnOverrideCompanySegment = 1 OR preference.ysnOverrideCompanySegment IS NULL) 

	-- Generate the gl account id based on "lob" segment. 
	SELECT	@intGLAccountId_LOBSegment = 			
				dbo.fnGetGLAccountIdFromProfitCenter(
					ISNULL(@intGLAccountId_CompanySegment, @intGLAccountId_LocationSegment) 
					,lob.intSegmentCodeId
				)
	FROM	tblICCommodity c				
			CROSS APPLY
			(
				SELECT TOP 1 
					ysnOverrideLOBSegment
				FROM 
					tblICCompanyPreference
			) preference 
			CROSS APPLY (
				SELECT * 
				FROM 
					tblSMLineOfBusiness lob
				WHERE
					lob.intLineOfBusinessId = c.intLineOfBusinessId
					AND (preference.ysnOverrideLOBSegment = 1 OR preference.ysnOverrideLOBSegment IS NULL) 
			) lob
	WHERE
			c.intCommodityId = @intCommodityId
			AND @intCommodityId IS NOT NULL 
			AND (preference.ysnOverrideLOBSegment = 1) 
			AND (
				@intGLAccountId_LocationSegment IS NOT NULL 
				OR @intGLAccountId_CompanySegment IS NOT NULL 
			)

	RETURN COALESCE(@intGLAccountId_LOBSegment, @intGLAccountId_CompanySegment, @intGLAccountId_LocationSegment) 
END 