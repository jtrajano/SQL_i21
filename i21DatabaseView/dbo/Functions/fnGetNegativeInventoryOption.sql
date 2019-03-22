--------------------------------------------------------------------------------------------------------------------------------------------------
-- Returns the selected option for an item and for a particular location. 
-- Values for "Allow Negative Inventory". 
--
-- 1 > Yes (Inventory is allowed to go less than zero and stay there) 
-- 3 > No (The system will block any transaction that would result in inventory going into the negative)

-- Obsolete and no-longer supported values:
-- 2 > Yes with Auto Write-Off. 
---		Why? This value is now merged with Inventory Option 'Yes'. Auto-Negative concept is now removed. It is now replaced by Auto-Variance. 
--------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnGetNegativeInventoryOption] (
	@intItemId INT
	,@intItemLocationId INT 
)
RETURNS INT 
AS
BEGIN
	DECLARE @AllowNegativeInventoryType AS INT

	SELECT	@AllowNegativeInventoryType = intAllowNegativeInventory 
	FROM	tblICItemLocation
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	RETURN @AllowNegativeInventoryType
END
