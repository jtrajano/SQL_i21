CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for category level]
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

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryDescription AS NVARCHAR(50) = 'Inventory';
		DECLARE @CostOfGoodsDescription AS NVARCHAR(50) = 'Cost of Goods';
		DECLARE @PurchasesDescription AS NVARCHAR(50) = 'AP Account';
				
		-- Generate the fake data. 
		EXEC testi21Database.[Fake data for simple Items]
	END
	
	-- Get the base account in the category level 
	-- Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	BEGIN                                                                                                                                                                                                                                                                                
		SELECT @actual =[dbo].[fnGetItemBaseGLAccount](@HotGrains, @Default_Location, @InventoryDescription);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 40100-1001 (COST OF GOODS WHEAT-NEW HAVEN GRAIN)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@HotGrains, @Default_Location, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

	-- Must return account id 50110-1001 (PURCHASES WHEAT-HEW HAVEN GRAIN)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@HotGrains, @Default_Location, @PurchasesDescription);

		-- Assert
		SET @expected = 3001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END

END