CREATE PROCEDURE testi21Database.[test fnGetItemGLAccount function for getting the gl account from category]
AS 
BEGIN
	-- Declare the variables used in the fake data stored procedures
	BEGIN 
		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
				,@CornCommodity AS INT = 8
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

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

				,@CornCommodity_DefaultLocation AS INT = 18
				,@CornCommodity_NewHaven AS INT = 19
				,@CornCommodity_BetterHaven AS INT = 20

			-- Declare the account ids
			DECLARE @Inventory_Default AS INT = 1000
			DECLARE @CostOfGoods_Default AS INT = 2000
			DECLARE @APClearing_Default AS INT = 3000
			DECLARE @WriteOffSold_Default AS INT = 4000
			DECLARE @RevalueSold_Default AS INT = 5000 
			DECLARE @AutoNegative_Default AS INT = 6000
			DECLARE @InventoryInTransit_Default AS INT = 7000
			DECLARE @AccountReceivable_Default AS INT = 8000
			DECLARE @InventoryAdjustment_Default AS INT = 9000

			DECLARE @Inventory_NewHaven AS INT = 1001
			DECLARE @CostOfGoods_NewHaven AS INT = 2001
			DECLARE @APClearing_NewHaven AS INT = 3001
			DECLARE @WriteOffSold_NewHaven AS INT = 4001
			DECLARE @RevalueSold_NewHaven AS INT = 5001
			DECLARE @AutoNegative_NewHaven AS INT = 6001
			DECLARE @InventoryInTransit_NewHaven AS INT = 7001
			DECLARE @AccountReceivable_NewHaven AS INT = 8001
			DECLARE @InventoryAdjustment_NewHaven AS INT = 9001

			DECLARE @Inventory_BetterHaven AS INT = 1002
			DECLARE @CostOfGoods_BetterHaven AS INT = 2002
			DECLARE @APClearing_BetterHaven AS INT = 3002
			DECLARE @WriteOffSold_BetterHaven AS INT = 4002
			DECLARE @RevalueSold_BetterHaven AS INT = 5002
			DECLARE @AutoNegative_BetterHaven AS INT = 6002
			DECLARE @InventoryInTransit_BetterHaven AS INT = 7002
			DECLARE @AccountReceivable_BetterHaven AS INT = 8002
			DECLARE @InventoryAdjustment_BetterHaven AS INT = 9002
	END 

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
	-- Test case: Get the contra account for "Cost of Goods"
	BEGIN 	
		INSERT actual (
				[Inventory]
				,[ContraInventory]
				,[RevalueSold]
				,[WriteOffSold]
				,[AutoNegative]
		)
		SELECT	[Inventory] = [dbo].[fnGetItemGLAccount](@ColdGrains, @ColdGrains_DefaultLocation, 'Inventory')
				,[ContraInventory] = [dbo].[fnGetItemGLAccount](@ColdGrains, @ColdGrains_DefaultLocation, 'Cost of Goods')
				,[RevalueSold] = NULL 
				,[WriteOffSold] = NULL 
				,[AutoNegative] = NULL 	
	END

	-- Assert
	BEGIN 		
		-- expects a row with NULL values on all fields. 
		INSERT expected (
			[Inventory]
			,[ContraInventory]
			,[RevalueSold]
			,[WriteOffSold]
			,[AutoNegative]
		)
		SELECT				
			[Inventory] = @Inventory_Default
			,[ContraInventory] = @CostOfGoods_Default
			,[RevalueSold] = NULL
			,[WriteOffSold] = NULL
			,[AutoNegative] = NULL
			
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
