CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for category level]
AS 
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

	-- Arrange
	BEGIN 
		DECLARE @actual AS INT;

		-- Generate the fake data. 
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
	
	-- Get the base account in the category level 
	-- Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN)
	BEGIN                                                                                                                                                                                                                                                                                
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@HotGrains, @HotGrains_NewHaven, 'Inventory');

		-- Assert
		EXEC tSQLt.AssertEquals @Inventory_NewHaven, @actual; 

	END

	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@HotGrains, @HotGrains_NewHaven, 'Cost of Goods');

		-- Assert
		EXEC tSQLt.AssertEquals @CostOfGoods_NewHaven, @actual; 

	END

	-- Must return account id 50110-1001 (AP CLEARING WHEAT-HEW HAVEN GRAIN)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@HotGrains, @HotGrains_NewHaven, 'AP Clearing');

		-- Assert
		EXEC tSQLt.AssertEquals @APClearing_NewHaven, @actual; 

	END

END
