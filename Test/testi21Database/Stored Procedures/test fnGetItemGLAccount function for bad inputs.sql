﻿CREATE PROCEDURE testi21Database.[test fnGetItemGLAccount function for bad inputs]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intItemLocationId AS INT

		-- GL Account types used in inventory costing
		DECLARE @Inventory AS INT = 1;
		DECLARE @Sales AS INT = 2;
		DECLARE @Purchases AS INT = 3;
		
		CREATE TABLE expected(
			[Inventory] INT NULL
			,[ContraInventory] INT NULL
			,[RevalueSold] INT NULL
			,[WriteOffSold] INT NULL
			,[AutoNegative] INT NULL
		)

		CREATE TABLE actual(
			[Inventory] INT NULL
			,[ContraInventory] INT NULL
			,[RevalueSold] INT NULL
			,[WriteOffSold] INT NULL
			,[AutoNegative] INT NULL
		)

		-- Create the Fake data 
		EXEC testi21Database.[Fake inventory items]
	END 

	-- Act
	-- Will return empty table since item id and location id are NULL. 
	BEGIN 
		INSERT actual (
				[Inventory]
				,[ContraInventory]
				,[RevalueSold]
				,[WriteOffSold]
				,[AutoNegative]
		)
		SELECT	[Inventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intItemLocationId, 'Inventory')
				,[ContraInventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intItemLocationId, 'Cost of Goods')
				,[RevalueSold] = NULL 
				,[WriteOffSold] = NULL 
				,[AutoNegative] = NULL 	
	END

	-- Assert
	BEGIN 
		INSERT expected (
			[Inventory]
			,[ContraInventory]
			,[RevalueSold]
			,[WriteOffSold]
			,[AutoNegative]
		)
		SELECT				
			[Inventory] = NULL 
			,[ContraInventory] = NULL 
			,[RevalueSold] = NULL 
			,[WriteOffSold] = NULL 
			,[AutoNegative] = NULL 
			
		-- Assert
		EXEC tSQLt.AssertObjectExists 'actual';
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	BEGIN
		IF OBJECT_ID('actual') IS NOT NULL 
			DROP TABLE actual

		IF OBJECT_ID('expected') IS NOT NULL 
			DROP TABLE expected
	END 
END