
/*
 fnGetItemGLAccount is a function that returns the GL account id. 
 
 Parameters: 
	 @intItemId: The item id where the g/l account may have an override. 
	 @intLocationId: The location is where "default" g/l account id is defined. If nothing is found in the item level and category level, this is the g/l account id used. 
	 @strAccountDescription: The specific account description to retrieve. For example: "Inventory", "Cost of Goods"
 
 Sample usage: 
 DECLARE @intItemId AS INT
		 ,@intLocationId AS INT;
		 
 SET @intItemId = 1;
 SET @intLocationId = 1;
 
 SELECT	Inventory = dbo.fnGetItemGLAccount(@intItemId, @intLocationId, 'Inventory')
		,COGS = dbo.fnGetItemGLAccount(@intItemId, @intLocationId, 'Cost of Goods')
 
*/

CREATE FUNCTION [dbo].[fnGetItemGLAccount] (
	@intItemId INT
	,@intItemLocationId INT
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId_LocationSegment AS INT
			,@intGLAccountId_CompanySegment AS INT 


	-- Generate the gl account id based on "location" segment. 
	SELECT	@intGLAccountId_LocationSegment = 
				dbo.fnGetGLAccountIdFromProfitCenter(
					dbo.fnGetItemBaseGLAccount(@intItemId, @intItemLocationId, @strAccountDescription)
					,dbo.fnGetItemProfitCenter(tblICItemLocation.intLocationId)
				)	
	FROM	dbo.tblICItemLocation
	WHERE	intItemLocationId = @intItemLocationId

	-- Generate the gl account id based on "company" segment. 
	SELECT	@intGLAccountId_CompanySegment = 			
				dbo.fnGetGLAccountIdFromProfitCenter(
					@intGLAccountId_LocationSegment
					,dbo.fnGetItemCompanySegment(tblICItemLocation.intLocationId)
				)
	FROM	dbo.tblICItemLocation
	WHERE
			intItemLocationId = @intItemLocationId
			AND @intGLAccountId_LocationSegment IS NOT NULL 

	IF @intGLAccountId_CompanySegment IS NOT NULL 
		RETURN @intGLAccountId_CompanySegment
	
	RETURN @intGLAccountId_LocationSegment
END 