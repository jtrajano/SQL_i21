
-- Returns the account ids that can be used in item costing. 
-- The location of the item is important. It is used to determine the g/l account and profit center 
CREATE FUNCTION [dbo].[fnGetItemGLAccounts] (
	@intItemId INT
	,@intLocationId INT
)
RETURNS TABLE
AS 
RETURN 
	SELECT	-- Get the inventory GL Account id
			Inventory =  dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 'Inventory')
				,dbo.fnGetItemProfitCenter(@intLocationId)
			)

			-- Get the Sales GL Account id
			,CostOfGoods = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 'Cost of Goods')
				,dbo.fnGetItemProfitCenter(@intLocationId)
			)

			-- Get the Purchases GL Account id
			,PurchaseAccount = dbo.fnGetGLAccountIdFromProfitCenter(
				dbo.fnGetItemBaseGLAccount(@intItemId, @intLocationId, 'Purchase Account')
				,dbo.fnGetItemProfitCenter(@intLocationId)
			)

GO