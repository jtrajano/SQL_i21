
-- Returns the account ids that can be used in item costing. 
CREATE FUNCTION [dbo].[fnGetItemGLAccounts] (
	@intItemId INT
	,@intLocationId INT
)
RETURNS TABLE
AS 
RETURN 
	/*
		The natural account is retrieved from the item-location level. 
		Profit centers will provide the segments. 

		Hierarchy:
		1. Item-location is checked first. 
		2. If account id is not found in item-location, try the category 
		3. If account id is not found in category, try the location. 
	*/

	SELECT	-- Get the inventory g/l account id
			intInventoryAccount = 
				ISNULL(dbo.fnGetGLAccountIdFromItemLocation(@intItemId, @intLocationId, 1),
					ISNULL(dbo.fnGetGLAccountIdFromCategory(@intItemId, @intLocationId, 1),
						dbo.fnGetGLAccountIdFromLocation(@intItemId, @intLocationId, 1)))
			-- Get the COGS g/l account id
			,intCOGSAccount = 
				ISNULL(dbo.fnGetGLAccountIdFromItemLocation(@intItemId, @intLocationId, 2),
					ISNULL(dbo.fnGetGLAccountIdFromCategory(@intItemId, @intLocationId, 2),
						dbo.fnGetGLAccountIdFromLocation(@intItemId, @intLocationId, 2)))
			-- Get the Revalue Cost g/l account id
			,intRevalueCostAccount = 
				ISNULL(dbo.fnGetGLAccountIdFromItemLocation(@intItemId, @intLocationId, 3),
					ISNULL(dbo.fnGetGLAccountIdFromCategory(@intItemId, @intLocationId, 3),
						dbo.fnGetGLAccountIdFromLocation(@intItemId, @intLocationId, 3)))
			-- Get the Write-Off Cost g/l account id
			,intWriteOffCostAccount = 
				ISNULL(dbo.fnGetGLAccountIdFromItemLocation(@intItemId, @intLocationId, 3),
					ISNULL(dbo.fnGetGLAccountIdFromCategory(@intItemId, @intLocationId, 3),
						dbo.fnGetGLAccountIdFromLocation(@intItemId, @intLocationId, 3)))
			-- Get the Auto-negative g/l account  id 
			,intAutoNegativeAccount = 				
				ISNULL(dbo.fnGetGLAccountIdFromItemLocation(@intItemId, @intLocationId, 4),
					ISNULL(dbo.fnGetGLAccountIdFromCategory(@intItemId, @intLocationId, 4),
						dbo.fnGetGLAccountIdFromLocation(@intItemId, @intLocationId, 4)))

GO