CREATE PROCEDURE testi21Database.[test the fnGetItemBaseGLAccount function]
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

	-- Act
	-- 1. Must return NULL if item id and location are both NULL. 
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		-- If item and location is null, expected is also NULL. 
		SET @expected = NULL;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- 2. Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	-- Get the base account in the item-location table
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN

		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 
	
	-- 3. Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN GRAIN)
	-- Get the base account in the item-location table
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 	
	
	-- 4. Must return account id 50110-1001 (PURCHASES WHEAT-NEW HAVEN GRAIN)
	-- Get the base account in the item-location table
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- 5. Must return account id 50110-1001 (PURCHASES WHEAT-NEW HAVEN GRAIN)
	-- Get the base account in the item-location table
	BEGIN 
		SET @intItemId = 2; -- STICKY GRAINS
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- 6. Must return account id 40100-1002 (SALES WHEAT-BETTER HAVEN GRAIN)
	-- Get the base account in the item-location table
	BEGIN 
		SET @intItemId = 3; -- PREMIUM GRAINS
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3002;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- 7. Must return account id 12040-1002 (INVENTORY WHEAT-BETTER HAVEN GRAIN)
	-- Get the base account in the category level 
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS 
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1002;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- 8. Must return account id 12040-1002 (INVENTORY WHEAT-)
	-- Item has no item-level g/l setup for BETTER HAVEN
	-- Item has setup in the category level
	-- Get the base account from the category level 
	BEGIN 
		SET @intItemId = 5; -- HOT GRAINS 
		SET @intLocationId = 3;	-- BETTER HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1000;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- 9. Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	-- Item has no item-level g/l setup for New Haven 
	-- Item has categorysetup but not for New Haven 
	-- Get the base account from the company location level 
	BEGIN 
		SET @intItemId = 5; -- HOT GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END
END 