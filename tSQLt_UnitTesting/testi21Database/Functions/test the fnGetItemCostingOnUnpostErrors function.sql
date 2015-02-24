CREATE PROCEDURE testi21Database.[test the fnGetItemCostingOnUnpostErrors function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5
				,@ManualLotGrains_BushelUOMId AS INT = 6
				,@SerializedLotGrains_BushelUOMId AS INT = 7

		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		-- Create the mock data 
		EXEC testi21Database.[Fake inventory items]

		-- Fake data for item stock table
		BEGIN 
			EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
			EXEC tSQLt.FakeTable 'dbo.tblICItemStockUOM', @Identity = 1;
			EXEC tSQLt.FakeTable 'dbo.tblICItemPricing', @Identity = 1;

			-- Add stock information for items under location 1 ('Default')
			DECLARE @intItemLocationId_1 AS INT 
			SELECT @intItemLocationId_1 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @intItemLocationId_1, 100)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_1, 22)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @intItemLocationId_1, @WetGrains_BushelUOMId, 100)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			DECLARE @intItemLocationId_2 AS INT 
			SELECT @intItemLocationId_2 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @intItemLocationId_2, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_2, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @intItemLocationId_2, @WetGrains_BushelUOMId, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			DECLARE @intItemLocationId_3 AS INT 
			SELECT @intItemLocationId_3 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @intItemLocationId_3, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_3, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @intItemLocationId_3, @WetGrains_BushelUOMId, 0)
		END

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- 2: Negative stock is not allowed 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @intItemLocationId_3
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
	END

	-- Act
	BEGIN 
		INSERT INTO actual
		-- 1: Postive stock 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_2, @WetGrains_BushelUOMId, 10)

		-- 2: Negative stock is not allowed 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_3, @WetGrains_BushelUOMId, -10)

		-- 3: Negative stock is allowed
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_2, @WetGrains_BushelUOMId, -10)
		
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected	
END 