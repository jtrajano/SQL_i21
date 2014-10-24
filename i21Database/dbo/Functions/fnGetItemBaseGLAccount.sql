CREATE FUNCTION [dbo].[fnGetItemBaseGLAccount]
(
	@intItemId INT 
	,@intLocationId INT
	,@intType INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	--Hierarchy:
	--1. Item-location is checked first. 
	--2. If account id is not found in item-location, try the category 
	--3. If account id is not found in category, try the company location. 

	-- GL Account types used in inventory costing
	DECLARE @InventoryAccountType AS INT = 1,
			@InventoryDescription AS NVARCHAR(50) = 'Inventory';

	DECLARE @SalesAccountType AS INT = 2,
			@SalesDescription AS NVARCHAR(50) = 'Sales';

	DECLARE @PurchaseAccountType AS INT = 3,
			@PurchasesDescription AS NVARCHAR(50) = 'Purchases';

	-- 1: Try to get the account id from the item (G/L Setup tab)
	SELECT	@intGLAccountId = intAccountId
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

	IF @intGLAccountId IS NOT NULL 
		RETURN @intGLAccountId

	-- 2: Try to get the account id from the category (G/L Setup tab)
	SELECT	@intGLAccountId = CatGLAccounts.intAccountId
	FROM	tblICItem Item INNER JOIN tblICCategory Cat
				ON Item.intTrackingId = Cat.intCategoryId
			INNER JOIN tblICCategoryAccount CatGLAccounts
				ON Cat.intCategoryId = CatGLAccounts.intCategoryId
	WHERE	Item.intItemId = @intItemId
			AND CatGLAccounts.intLocationId = @intLocationId
			AND 1 = (
				CASE	WHEN @intType = @InventoryAccountType AND CatGLAccounts.strAccountDescription = @InventoryDescription THEN 1
						WHEN @intType = @SalesAccountType AND CatGLAccounts.strAccountDescription = @SalesDescription THEN 1
						WHEN @intType = @PurchaseAccountType AND CatGLAccounts.strAccountDescription = @PurchasesDescription THEN 1
						ELSE 0
				END
			)

	IF @intGLAccountId IS NOT NULL 
		RETURN @intGLAccountId
	
	-- 3: Try to get the account id from the Company Location (G/L Setup tab)
	SELECT	@intGLAccountId = intAccountId
	FROM	tblSMCompanyLocationAccount
	WHERE	intCompanyLocationId = @intLocationId
			AND 1 = (
				CASE	WHEN @intType = @InventoryAccountType AND strAccountDescription = @InventoryDescription THEN 1
						WHEN @intType = @SalesAccountType AND strAccountDescription = @SalesDescription THEN 1
						WHEN @intType = @PurchaseAccountType AND strAccountDescription = @PurchasesDescription THEN 1
						ELSE 0
				END
			)
	
	RETURN @intGLAccountId 
END
GO