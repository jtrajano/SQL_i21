CREATE PROCEDURE testi21Database.[test fnGetItemGLAccount function for purchase account]
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
		/*
			tblICItemLocation
			-------------------------------------------------------------
			Item Location Id	Item			Location
			----------------	-------------	-------------------------
			1					Wet Grains		Default Location
			2					Sticky Grains	Default Location
			3					Premium Grains	Default Location
			4					Cold Grains		Default Location
			5					Hot Grains		Default Location
			6					Wet Grains		New Haven
			7					Sticky Grains	New Haven
			8					Premium Grains	New Haven
			9					Cold Grains		New Haven
			10					Hot Grains		New Haven
			11					Wet Grains		Better Haven
			12					Sticky Grains	Better Haven
			13					Premium Grains	Better Haven
			14					Cold Grains		Better Haven
			15					Hot Grains		Better Haven		
		*/
	END 

	-- Test case: Get the contra account for "Purchase Account"
	BEGIN 
		DELETE FROM actual
		DELETE FROM expected
		
		SET @intItemId = 1; -- WET GRAINS
		SET @intItemLocationId = 6; -- NEW HAVEN
		
		INSERT actual (
			[Inventory]
			,[ContraInventory]
			,[RevalueSold]
			,[WriteOffSold]
			,[AutoNegative]
		)
		SELECT	[Inventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intItemLocationId, 'Inventory')
				,[ContraInventory] = [dbo].[fnGetItemGLAccount](@intItemId, @intItemLocationId, 'AP Clearing')
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
			[Inventory] = 1001	-- 12040-1001
			,[ContraInventory] = 3001	-- 50110-1001
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