
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
			intInventoryAccount =  dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 1)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 1)
			)

			-- Get the COGS g/l account id
			,intCOGSAccount = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 2)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 2)
			)

			-- Get the Revalue Cost g/l account id
			,intRevalueCostAccount = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 3)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 3)
			)

			-- Get the Write-Off Cost g/l account id
			,intWriteOffCostAccount = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 4)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 4)
			)

			-- Get the Auto-negative g/l account  id 
			,intAutoNegativeAccount = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 5)
				,dbo.fnGetItemProfitCenter(@intItemId, @intLocationId, 5)
			)

GO