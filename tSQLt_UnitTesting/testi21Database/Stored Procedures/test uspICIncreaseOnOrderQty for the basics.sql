CREATE PROCEDURE [testi21Database].[test uspICIncreaseOnOrderQty for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		----------------------------------
		-- DECLARE THE CONSTANTS
		----------------------------------
		DECLARE @PurchaseType AS INT = 1
		DECLARE @SalesType AS INT = 2

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3

		DECLARE @USD AS INT = 1;		
		DECLARE @Each AS INT = 1;

		----------------------------------------
		-- Create the Fake data
		----------------------------------------
		EXEC testi21Database.[Fake inventory items];

		-- Fake data for item stock table
		BEGIN 
			EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;

			-- Add stock information for items under location 1 ('Default')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @Default_Location, 100, 22)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @Default_Location, 150, 33)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @Default_Location, 200, 44)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @Default_Location, 250, 55)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @Default_Location, 300, 66)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @NewHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @NewHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @NewHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @NewHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @NewHaven, 0, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @BetterHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @BetterHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @BetterHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @BetterHaven, 0, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @BetterHaven, 0, 0)
		END

		-----------------------------------
		-- Create the test tables
		-----------------------------------
		CREATE TABLE expected (
			intItemId INT
			,intLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		INSERT INTO expected (
				intItemId
				,intLocationId
				,dblOnOrder
		)
		SELECT	intItemId = @WetGrains
				,intLocationId = @Default_Location
				,dblOnOrder = NULL

		CREATE TABLE actual (
			intItemId INT
			,intLocationId INT
			,dblOnOrder NUMERIC(18,6)
		)

		-----------------------------------
		-- Create the test variables
		-----------------------------------

		DECLARE @Items AS ItemCostingTableType;
		
		---------------------------------------------------
		-- Setup the items to increase on-order qty
		---------------------------------------------------
		-- None
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseOnOrderQty @Items

		INSERT INTO actual (
				intItemId
				,intLocationId
				,dblOnOrder
		)
		SELECT	intItemId
				,intLocationId
				,dblOnOrder
		FROM	tblICItemStock 
		WHERE	intItemId = @WetGrains
				AND intLocationId = @Default_Location
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END