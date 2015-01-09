CREATE PROCEDURE testi21Database.[test fnGetItemGLAccount function for purchase account]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

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
		EXEC [testi21Database].[Fake data for simple Items]
	END 

	-- Test case: Get the contra account for "Purchase Account"
	BEGIN 
		DELETE FROM actual
		DELETE FROM expected
		
		SET @intItemId = 1; -- WET GRAINS
		SET @intLocationId = 2; -- NEW HAVEN
		
		INSERT actual (
			[Inventory]
			,[ContraInventory]
			,[RevalueSold]
			,[WriteOffSold]
			,[AutoNegative]
		)
		SELECT	[Inventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intLocationId, 'Inventory')
				,[ContraInventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intLocationId, 'AP Account')
				,[RevalueSold] = NULL 
				,[WriteOffSold] = NULL 
				,[AutoNegative] = NULL 	
		
		-- expects a row with NULL values on all fields. 
		INSERT expected (
			[Inventory]
			,[ContraInventory]
			,[RevalueSold]
			,[WriteOffSold]
			,[AutoNegative]
		)
		SELECT				
			[Inventory] = 1000	-- 12040-1000
			,[ContraInventory] = 3000	-- 50110-1000
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
			DROP TABLE dbo.expected
	END 
END