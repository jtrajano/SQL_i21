CREATE PROCEDURE testi21Database.[test the fnGetItemGLAccounts function]
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
			Inventory INT
			,Sales INT
			,Purchases INT
		)

		CREATE TABLE actual(
			Inventory INT
			,Sales INT
			,Purchases INT
		)

		-- Create the Fake data 
		EXEC [testi21Database].[Fake data for simple Items]
	END 

	-- Test case
	-- 1. Will return empty table since item id and location id are NULL. 
	BEGIN 
		-- Act
		INSERT actual (
			Inventory
			,Sales
			,Purchases
		)
		SELECT	*
		FROM	[dbo].[fnGetItemGLAccounts](@intItemId, @intLocationId)

		-- expects a row with NULL values on all fields. 
		INSERT expected (
			Inventory
			,Sales
			,Purchases
		)
		SELECT				
			Inventory = NULL 
			,Sales = NULL 
			,Purchases = NULL 
			
		-- Assert
		EXEC tSQLt.AssertObjectExists 'actual';
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END
	
	-- Test case 2: 
	BEGIN 
		DELETE FROM actual
		DELETE FROM expected
		
		SET @intItemId = 1; -- WET GRAINS
		SET @intLocationId = 2; -- NEW HAVEN
		
		INSERT actual (
			Inventory
			,Sales
			,Purchases
		)
		SELECT	*
		FROM	[dbo].[fnGetItemGLAccounts](@intItemId, @intLocationId)		
		
		-- expects a row with NULL values on all fields. 
		INSERT expected (
			Inventory
			,Sales
			,Purchases
		)
		SELECT				
			Inventory = 1001	-- 12040-1001
			,Sales = 2001		-- 40100-1001
			,Purchases = 3001	-- 50110-1001
			
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