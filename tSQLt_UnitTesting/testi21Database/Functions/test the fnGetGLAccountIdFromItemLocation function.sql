CREATE PROCEDURE testi21Database.[test the fnGetGLAccountIdFromItemLocation function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryAccountId AS INT = 1,
				@InventoryDescription AS NVARCHAR(50) = 'Inventory';

		DECLARE @SalesAccountId AS INT = 2,
				@SalesDescription AS NVARCHAR(50) = 'Sales';

		DECLARE @PurchaseAccountId AS INT = 3,
				@PurchasesDescription AS NVARCHAR(50) = 'Purchases';
				
		-- Generate the fake data. 
		EXEC testi21Database.[Fake data for simple Items]
	END

	-- Act
	-- 1. Must return NULL if item id and location are both NULL. 
	BEGIN 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @InventoryAccountId);

		-- Assert
		-- If item and location is null, expected is also NULL. 
		SET @expected = NULL;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- 2. Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 1; -- BANANA
		SET @intLocationId = 2;	-- NEW HAVEN

		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @InventoryAccountId);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 
	
	-- 3. Must return account id 40100-1001 (SALES WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 1; -- BANANA
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @SalesAccountId);

		-- Assert
		SET @expected = 2001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 	
	
	-- 3. Must return account id 50110-1001 (PURCHASES WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 1; -- BANANA
		SET @intLocationId = 2;	-- NEW HAVEN
                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @PurchaseAccountId);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END
END 