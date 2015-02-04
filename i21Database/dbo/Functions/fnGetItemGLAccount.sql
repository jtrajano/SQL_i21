
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
	,@intLocationId INT
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SET @intGLAccountId = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, @strAccountDescription)
				,dbo.fnGetItemProfitCenter(@intLocationId)
		);		

	RETURN @intGLAccountId
END 