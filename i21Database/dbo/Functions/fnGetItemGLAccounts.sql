
-- Returns the account ids that can be used in item costing. 
-- The location of the item is important. It is used to determine the g/l account and profit center 
CREATE FUNCTION [dbo].[fnGetItemGLAccounts] (
	@intItemId INT
	,@intLocationId INT
)
RETURNS TABLE
AS 
RETURN 
	SELECT	-- Get the inventory g/l account id
			Inventory =  dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 1)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 1)
			)

			-- Get the COGS g/l account id
			,Sales = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 2)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 2)
			)

			-- Get the Revalue Cost g/l account id
			,Purchases = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 3)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 3)
			)

GO