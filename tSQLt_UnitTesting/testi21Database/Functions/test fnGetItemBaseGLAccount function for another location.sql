CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for another location]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryDescription AS NVARCHAR(50) = 'Inventory';
		DECLARE @CostOfGoodsDescription AS NVARCHAR(50) = 'Cost of Goods';
		DECLARE @PurchasesDescription AS NVARCHAR(50) = 'Purchase Account';
				
		-- Generate the fake data. 
		EXEC testi21Database.[Fake data for simple Items]
	END

	-- Item has no item-level g/l setup for New Haven 
	-- Item has categorysetup but not for New Haven 
	-- Get the base account from the company location level 

	-- Must return account id 12040-1002 (INVENTORY WHEAT-BETTER HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1002 (COST OF GOODS WHEAT-BETTER HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1002 (PURCHASES WHEAT-BETTER HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 3;	-- BETTER HAVEN

		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END 