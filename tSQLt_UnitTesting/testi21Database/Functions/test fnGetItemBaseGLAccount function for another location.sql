CREATE PROCEDURE testi21Database.[test fnGetItemBaseGLAccount function for another location]
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

	-- Item has no item-level g/l setup for New Haven 
	-- Item has categorysetup but not for New Haven 
	-- Get the base account from the company location level 

	-- Must return account id 12040-1002 (INVENTORY WHEAT-BETTER HAVEN GRAINS)
	BEGIN                                                                                                                                                                                                                                                                               
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, @BetterHaven, @InventoryDescription);

		-- Assert
		SET @expected = 1002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 40100-1002 (COST OF GOODS WHEAT-BETTER HAVEN GRAINS)
	BEGIN                                                                                                                                                                                                                                                                                
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, @BetterHaven, @CostOfGoodsDescription);

		-- Assert
		SET @expected = 2002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- Must return account id 50110-1002 (PURCHASES WHEAT-BETTER HAVEN GRAINS)
	BEGIN 
		SELECT @actual = [dbo].[fnGetItemBaseGLAccount](@ColdGrains, @BetterHaven, @PurchasesDescription);

		-- Assert
		SET @expected = 3002;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END
END 