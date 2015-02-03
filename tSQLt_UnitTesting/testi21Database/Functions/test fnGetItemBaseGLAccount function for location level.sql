CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for location level]
AS 
BEGIN
	-- Arrange
	BEGIN 
		-- Declare the account ids
		DECLARE @Inventory_Default AS INT = 1000
		DECLARE @CostOfGoods_Default AS INT = 2000
		DECLARE @APClearing_Default AS INT = 3000
		DECLARE @WriteOffSold_Default AS INT = 4000
		DECLARE @RevalueSold_Default AS INT = 5000 
		DECLARE @AutoNegative_Default AS INT = 6000
		DECLARE @InventoryInTransit_Default AS INT = 7000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001
		DECLARE @InventoryInTransit_NewHaven AS INT = 7001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002
		DECLARE @InventoryInTransit_BetterHaven AS INT = 7002

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

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryDescription AS NVARCHAR(50) = 'Inventory';
		DECLARE @CostOfGoodsDescription AS NVARCHAR(50) = 'Cost of Goods';
		DECLARE @PurchasesDescription AS NVARCHAR(50) = 'AP Clearing';
				
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

	-- Item has no item-level g/l setup for New Haven 
	-- Item has categorysetup but not for New Haven 
	-- Get the base account from the company location level 

	-- Must return account id 12040-1000 (INVENTORY WHEAT-)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 4, @InventoryDescription);

		-- Assert
		SET @expected = @Inventory_Default;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1000 (COST OF GOODS WHEAT-)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 4, @CostOfGoodsDescription);

		-- Assert
		SET @expected = @CostOfGoods_Default;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1000 (AP CLEARING WHEAT-)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 4, @PurchasesDescription);

		-- Assert
		SET @expected = @APClearing_Default;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 9, @InventoryDescription);

		-- Assert
		SET @expected = @Inventory_NewHaven;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 9, @CostOfGoodsDescription);

		-- Assert
		SET @expected = @CostOfGoods_NewHaven;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1001 (AP CLEARING WHEAT-NEW HAVEN GRAINS)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, 9, @PurchasesDescription);

		-- Assert
		SET @expected = @APClearing_NewHaven;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END