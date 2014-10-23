CREATE FUNCTION [dbo].[fnGetItemProfitCenter]
(
	@intItemId INT
	,@intLocationId INT
	,@intType INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intProfitCenter AS INT

	-- GL Account types used in inventory costing
	DECLARE @InventoryAccountType AS INT = 1,
			@InventoryDescription AS NVARCHAR(50) = 'Inventory';

	DECLARE @SalesAccountType AS INT = 2,
			@SalesDescription AS NVARCHAR(50) = 'Sales';

	DECLARE @PurchaseAccountType AS INT = 3,
			@PurchasesDescription AS NVARCHAR(50) = 'Purchases';

	-- Profit center is retrieved by a hierarchy:
	-- 1. Item (G/L Setup tab)
	-- 2. Category 
	-- 3. Company Location 

	-- Get profit center id from the item (G/L Setup tab)
	SELECT	@intProfitCenter = intProfitCenterId
	FROM	tblICItemAccount
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND 1 = (
				CASE	WHEN @intType = @InventoryAccountType AND strAccountDescription = @InventoryDescription THEN 1
						WHEN @intType = @SalesAccountType AND strAccountDescription = @SalesDescription THEN 1
						WHEN @intType = @PurchaseAccountType AND strAccountDescription = @PurchasesDescription THEN 1
						ELSE 0
				END
			)

	IF @intProfitCenter IS NOT NULL 
		RETURN @intProfitCenter
	
	-- TODO: The profit center field in the category table is missing. Need to add it. 
	/*

	-- Get the profit center from the item category
	SELECT	@intProfitCenter = NULL
	FROM	tblICCategory INNER JOIN tblICItem
				ON tblICCategory.intCategoryId = tblICItem.intTrackingId
	WHERE	tblICItem.intItemId = @intItemId

	IF @intProfitCenter IS NOT NULL 
		RETURN @intProfitCenter
	
	*/

	-- Get the profit center from the company location
	SELECT	@intProfitCenter = intProfitCenter
	FROM	tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @intLocationId

	RETURN @intProfitCenter 
END
GO