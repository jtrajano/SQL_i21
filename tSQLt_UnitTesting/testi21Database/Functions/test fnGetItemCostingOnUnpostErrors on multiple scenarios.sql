CREATE PROCEDURE testi21Database.[test fnGetItemCostingOnUnpostErrors on multiple scenarios]
AS 
BEGIN
	-- Arrange
	BEGIN 
		-- Create the mock data 
		EXEC testi21Database.[Fake inventory items]

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

				,@WetGrains_PoundUOMId AS INT = 8
				,@StickyGrains_PoundUOMId AS INT = 9
				,@PremiumGrains_PoundUOMId AS INT = 10
				,@ColdGrains_PoundUOMId AS INT = 11
				,@HotGrains_PoundUOMId AS INT = 12
				,@ManualLotGrains_PoundUOMId AS INT = 13
				,@SerializedLotGrains_PoundUOMId AS INT = 14

		-- Declare Item-Locations
		DECLARE @WetGrains_DefaultLocation AS INT = 1
				,@StickyGrains_DefaultLocation AS INT = 2
				,@PremiumGrains_DefaultLocation AS INT = 3
				,@ColdGrains_DefaultLocation AS INT = 4
				,@HotGrains_DefaultLocation AS INT = 5

				,@WetGrains_NewHaven AS INT = 6
				,@StickyGrains_NewHaven AS INT = 7
				,@PremiumGrains_NewHaven AS INT = 8
				,@ColdGrains_NewHaven AS INT = 9
				,@HotGrains_NewHaven AS INT = 10

				,@WetGrains_BetterHaven AS INT = 11
				,@StickyGrains_BetterHaven AS INT = 12
				,@PremiumGrains_BetterHaven AS INT = 13
				,@ColdGrains_BetterHaven AS INT = 14
				,@HotGrains_BetterHaven AS INT = 15

				,@ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17		

		-- SubLocation 
		DECLARE @WetGrains_DefaultLocation_SubLocation AS INT

		-- Storage Location 
		DECLARE @WetGrains_DefaultLocation_StorageLocation AS INT

		-- Lot id
		DECLARE @intLotId AS INT 

		-- Fake data for item stock table
		BEGIN 
			-- Add stock information for items under location 1 ('Default')
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_DefaultLocation, 100)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @WetGrains_DefaultLocation, 22)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @WetGrains_DefaultLocation, @WetGrains_BushelUOMId, 100)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_DefaultLocation, 150)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @StickyGrains_DefaultLocation, 33)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @StickyGrains_DefaultLocation, @StickyGrains_BushelUOMId, 150)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_DefaultLocation, 200)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @PremiumGrains_DefaultLocation, 44)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @PremiumGrains_DefaultLocation, @PremiumGrains_BushelUOMId, 200)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_DefaultLocation, 250)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @ColdGrains_DefaultLocation, 55)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @ColdGrains_DefaultLocation, @ColdGrains_BushelUOMId, 250)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_DefaultLocation, 300)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @HotGrains_DefaultLocation, 66)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @HotGrains_DefaultLocation, @HotGrains_BushelUOMId, 300)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @WetGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @WetGrains_NewHaven, @WetGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @StickyGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @StickyGrains_NewHaven, @StickyGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @PremiumGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @PremiumGrains_NewHaven, @PremiumGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @ColdGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @ColdGrains_NewHaven, @ColdGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @HotGrains_NewHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @HotGrains_NewHaven, @HotGrains_BushelUOMId, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, @WetGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains, @WetGrains_BetterHaven, @WetGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, @StickyGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains, @StickyGrains_BetterHaven, @StickyGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, @PremiumGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains, @PremiumGrains_BetterHaven, @PremiumGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, @ColdGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains, @ColdGrains_BetterHaven, @ColdGrains_BushelUOMId, 0)

			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, @HotGrains_BetterHaven, 0)
			INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains, @HotGrains_BetterHaven, @HotGrains_BushelUOMId, 0)
		END
		
		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- Negative stock is not allowed 	
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029		
	END

	-- Act
	BEGIN 
		INSERT INTO actual
		-- 1: Valid item and valid location. 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(@WetGrains, @WetGrains_DefaultLocation, @WetGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, NULL, @intLotId)
		
		-- 2: Invalid item and valid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(-1, @WetGrains_DefaultLocation, @WetGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, NULL, @intLotId)

		-- 3: Valid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(@StickyGrains, -1, @StickyGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, NULL, @intLotId)

		-- 4: Invalid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(-1, -1, NULL, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, NULL, @intLotId)

		-- 5: Postive stock 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(@WetGrains, @WetGrains_NewHaven, @WetGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, 10, @intLotId)

		-- 6: Negative stock is not allowed 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(@WetGrains, @WetGrains_BetterHaven, @WetGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, -10, @intLotId)
		
		-- 7: Negative stock is allowed
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnUnpostErrors(@WetGrains, @WetGrains_NewHaven, @WetGrains_BushelUOMId, @WetGrains_DefaultLocation_SubLocation, @WetGrains_DefaultLocation_StorageLocation, -10, @intLotId)					
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected	
END 