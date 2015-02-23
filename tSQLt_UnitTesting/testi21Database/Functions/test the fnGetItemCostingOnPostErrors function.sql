CREATE PROCEDURE testi21Database.[test the fnGetItemCostingOnPostErrors function]
AS 
BEGIN
	-- Arrange
	BEGIN 
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

			DECLARE @intItemLocationId_2 AS INT 
			SELECT @intItemLocationId_2 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @StickyGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @intItemLocationId_2, 150)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @intItemLocationId_2, 33)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @intItemLocationId_2, @StickyGrains_BushelUOMId, 150)

			DECLARE @intItemLocationId_3 AS INT 
			SELECT @intItemLocationId_3 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @PremiumGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @intItemLocationId_3, 200)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @intItemLocationId_3, 44)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @intItemLocationId_3, @PremiumGrains_BushelUOMId, 200)

			DECLARE @intItemLocationId_4 AS INT 
			SELECT @intItemLocationId_4 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @ColdGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @intItemLocationId_4, 250)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @intItemLocationId_4, 55)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @intItemLocationId_4, @ColdGrains_BushelUOMId, 250)

			DECLARE @intItemLocationId_5 AS INT 
			SELECT @intItemLocationId_5 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @HotGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @intItemLocationId_5, 300)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @intItemLocationId_5, 66)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @intItemLocationId_5, @HotGrains_BushelUOMId, 300)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			DECLARE @intItemLocationId_6 AS INT 
			SELECT @intItemLocationId_6 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @intItemLocationId_6, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_6, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @intItemLocationId_6, @WetGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_7 AS INT 
			SELECT @intItemLocationId_7 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @StickyGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @intItemLocationId_7, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @intItemLocationId_7, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @intItemLocationId_7, @StickyGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_8 AS INT 
			SELECT @intItemLocationId_8 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @PremiumGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @intItemLocationId_8, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @intItemLocationId_8, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @intItemLocationId_8, @PremiumGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_9 AS INT 
			SELECT @intItemLocationId_9 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @ColdGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @intItemLocationId_9, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @intItemLocationId_9, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @intItemLocationId_9, @ColdGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_10 AS INT 
			SELECT @intItemLocationId_10 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @HotGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @intItemLocationId_10, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @intItemLocationId_10, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @intItemLocationId_10, @HotGrains_BushelUOMId, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			DECLARE @intItemLocationId_11 AS INT 
			SELECT @intItemLocationId_11 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @intItemLocationId_11, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_11, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @intItemLocationId_11, @WetGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_12 AS INT 
			SELECT @intItemLocationId_12 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @StickyGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @intItemLocationId_12, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @intItemLocationId_12, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @intItemLocationId_12, @StickyGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_13 AS INT 
			SELECT @intItemLocationId_13 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @PremiumGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @intItemLocationId_13, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @intItemLocationId_13, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @intItemLocationId_13, @PremiumGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_14 AS INT 
			SELECT @intItemLocationId_14 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @ColdGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @intItemLocationId_14, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @intItemLocationId_14, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @intItemLocationId_14, @ColdGrains_BushelUOMId, 0)

			DECLARE @intItemLocationId_15 AS INT 
			SELECT @intItemLocationId_15 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @HotGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @intItemLocationId_15, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @intItemLocationId_15, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @intItemLocationId_15, @HotGrains_BushelUOMId, 0)
		END
		
		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- 2: Invalid item and valid location
		SELECT	intItemId = @InvalidItem
				,intItemLocationId = @intItemLocationId_1
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027

		-- 4: Invalid item and invalid location
		UNION ALL		
		SELECT	intItemId = @InvalidItem
				,intItemLocationId = @InvalidLocation
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027

		-- 6: Negative stock is not allowed 
		UNION ALL
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @intItemLocationId_11
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029		
	END

	-- Act
	BEGIN 
		INSERT INTO actual
		-- 1: Valid item and valid location. 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_1, @WetGrains_BushelUOMId, NULL)
		
		-- 2: Invalid item and valid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@InvalidItem, @intItemLocationId_1, NULL, NULL)

		-- 3: Valid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@StickyGrains, @InvalidLocation, @StickyGrains_BushelUOMId, NULL)

		-- 4: Invalid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@InvalidItem, @InvalidLocation, NULL, NULL)

		-- 5: Postive stock 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_6, @WetGrains_BushelUOMId, 10)

		-- 6: Negative stock is not allowed 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_11, @WetGrains_BushelUOMId, -10)


		-- 7: Negative stock is allowed
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_6, @WetGrains_BushelUOMId, -10)		
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected	
END 