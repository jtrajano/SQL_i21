CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for bad inputs]
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

	-- Act
	-- Test for bad inputs
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](NULL, NULL, @InventoryDescription);

		-- Assert
		-- If item and location is null, expected is also NULL. 
		SET @expected = NULL;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END 