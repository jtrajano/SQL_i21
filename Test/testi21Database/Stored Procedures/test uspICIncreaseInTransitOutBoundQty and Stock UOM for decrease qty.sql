﻿CREATE PROCEDURE [testi21Database].[test uspICIncreaseInTransitOutBoundQty and Stock UOM for decrease qty]
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

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

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
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) VALUES (@WetGrains, @Default_Location, 100)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) VALUES (@StickyGrains, @Default_Location, 150)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) VALUES (@PremiumGrains, @Default_Location, 200)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) VALUES (@ColdGrains, @Default_Location, 250)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) VALUES (@HotGrains, @Default_Location, 300)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @NewHaven, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @BetterHaven, 0)
		END

		-- Fake data for item pricing table
		BEGIN 
			EXEC tSQLt.FakeTable 'dbo.tblICItemPricing', @Identity = 1;

			-- Add pricing information for items under location 1 ('Default')
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @Default_Location, 22)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @Default_Location, 33)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @Default_Location, 44)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @Default_Location, 55)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @Default_Location, 66)

			-- Add pricing information for items under location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @NewHaven, 0)

			-- Add pricing information for items under location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @BetterHaven, 0)
		END

		-----------------------------------
		-- Create the test tables
		-----------------------------------
		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,dblInTransitOutbound NUMERIC(18,6)
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,dblInTransitOutbound NUMERIC(18,6)
		)

		-----------------------------------
		-- Create the test variables
		-----------------------------------
		DECLARE @Items AS InTransitTableType;
		
		---------------------------------------------------
		-- Setup the items to increase reserved qty
		---------------------------------------------------
		INSERT INTO @Items (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[dblQty] 
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId] 
		)
		SELECT 
			[intItemId] = @WetGrains
			,[intItemLocationId] = @Default_Location
			,[intItemUOMId] = @WetGrains_BushelUOMId
			,[intLotId] = NULL 
			,[intSubLocationId] = NULL  
			,[intStorageLocationId] = NULL 
			,[dblQty] = -20
			,[intTransactionId] = 1
			,[strTransactionId] = 'TRANS-000001'
			,[intTransactionTypeId] = @SalesType


		---------------------------------------------------
		-- Setup the expected data
		---------------------------------------------------
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,dblInTransitOutbound
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @Default_Location
				,dblInTransitOutbound = -20
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICIncreaseInTransitOutBoundQty @Items

		INSERT INTO actual (
				intItemId
				,intItemLocationId
				,dblInTransitOutbound
		)
		SELECT	intItemId
				,intItemLocationId
				,dblInTransitOutbound
		FROM	tblICItemStockUOM 
		WHERE	intItemId = @WetGrains
				AND intItemLocationId = @Default_Location
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