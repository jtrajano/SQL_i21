--------------------------------------------------------------------------------------------------------------------------------------------------
-- Returns the selected option for an item and for a particular location. 
-- Values for "Allow Negative Inventory". 
--
-- 1 > Yes (Inventory is allowed to go less than zero and stay there) 
-- 2 > Yes with Auto Write-Off (Inventory is allowed to go negative. However as soon as it does, the system automatically adjusts the inventory back to 0 resulting in a  debit to inventory  and a credit to P&L (gain). )
-- 3 > No (The system will block any transaction that would result in inventory going into the negative)
--------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fnGetNegativeInventoryOption] (
	@intItemId INT
	,@intLocationId INT 
)
RETURNS INT 
AS
BEGIN
	DECLARE @AllowNegativeInventoryType AS INT


	SELECT	@AllowNegativeInventoryType = intAllowNegativeInventory 
	FROM	tblICItemLocation
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId

	RETURN @AllowNegativeInventoryType
END
