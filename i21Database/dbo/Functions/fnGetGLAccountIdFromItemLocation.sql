-- Retrieves the G/L Account for the item, location, and type of g/l account (e.g. Inventory, COGS, Sales, and so forth). 
CREATE FUNCTION [dbo].[fnGetGLAccountIdFromItemLocation](
	@intItemId INT
	,@intLocationId INT
	,@intType INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	-- GL Account types used in inventory costing
	DECLARE @InventoryAccountId AS INT = 1,
			@InventoryDescription AS NVARCHAR(50) = 'Inventory';

	DECLARE @SalesAccountId AS INT = 2,
			@SalesDescription AS NVARCHAR(50) = 'Sales';

	DECLARE @PurchaseAccountId AS INT = 3,
			@PurchasesDescription AS NVARCHAR(50) = 'Purchases';


	SELECT	@intGLAccountId = intAccountId
	FROM	tblICItemAccount
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND 1 = (
				CASE	WHEN @intType = @InventoryAccountId AND strAccountDescription = @InventoryDescription THEN 1
						WHEN @intType = @SalesAccountId AND strAccountDescription = @SalesDescription THEN 1
						WHEN @intType = @PurchaseAccountId AND strAccountDescription = @PurchasesDescription THEN 1
						ELSE 0
				END
			)

	-- TODO: Get the "profit center" - segement id. 
	-- TODO: Call [dbo].[fnGetGLAccountIdFromProfitCenter] so that it will override "profit center" from selected g/l account from item-location.
	
	RETURN @intGLAccountId 
END
GO