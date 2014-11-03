CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for item-level]
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

	-- Get the base account from the item level 
	-- Must return account id 12040-1000 (INVENTORY WHEAT-)	
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS

		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1000;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 
	
	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-)
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2000;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 	
	
	-- Must return account id 50110-1001 (PURCHASES WHEAT-)
	BEGIN 
		SET @intItemId = 1; -- WET GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3000;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 2; -- STICKY GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 2; -- STICKY GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 50110-1001 (PURCHASES WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 2; -- STICKY GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 12040-1002 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 3; -- PREMIUM GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1002;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 40100-1002 (COST OF GOODS WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 3; -- PREMIUM  GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2002;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 50110-1002 (PURCHASES WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 3; -- PREMIUM  GRAINS
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3002;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END
END 