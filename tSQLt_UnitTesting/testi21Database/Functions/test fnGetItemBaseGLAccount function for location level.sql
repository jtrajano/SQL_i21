﻿CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for location level]
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

	-- Must return account id 12040-1000 (INVENTORY WHEAT-)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 1;	-- "DEFAULT"
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1000;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1000 (COST OF GOODS WHEAT-)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 1;	-- "DEFAULT"
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2000;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1000 (PURCHASES WHEAT-)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 1;	-- "DEFAULT"
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3000;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @InventoryDescription);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2001;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1001 (PURCHASES WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SET @intItemId = 4; -- COLD GRAINS
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@intItemId, @intLocationId, @PurchasesDescription);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END 