﻿CREATE PROCEDURE testi21Database.[test fnGetCostingMethodAsTable for retrieving the costing method at category level]
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
				,@SerialLotGrains AS INT = 7

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3

		-- Declare the costing methods
		DECLARE @AverageCost AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@StandardCost AS INT = 4
				,@LotCost AS INT = 5

		CREATE TABLE expected(
			CostingMethod INT NULL
		)

		CREATE TABLE actual(
			CostingMethod INT NULL
		)

		INSERT INTO expected 
		SELECT @LIFO

		-- Call SP to create the fake data
		EXEC testi21Database.[Fake data for the Costing Method];
	END

	-- Act
	BEGIN 		
		/***************************************************************************************************************************************************************************************************************
			Below is the matrix that shows that data generated by [Fake data for the Costing Method]
			---------------------------------------------------------------------------------------------------------
			Item Location Id			Item			Location			Category	Expected Costing Method		Level Type
			-----------------------		--------------	------------------	-----------	--------------------------	---------------
			1							WetGrains		Default_Location	NULL		Average Cost				Item level
			6							WetGrains		NewHaven			NULL		Average Cost				Item level
			11							WetGrains		BetterHaven			NULL		NULL						None
			2							StickyGrains	Default_Location	NULL		Average Cost				Item level
			7							StickyGrains	NewHaven			NULL		Average Cost				Item level
			11							StickyGrains	BetterHaven			NULL		NULL						None
			3							PremiumGrains	Default_Location	NULL		Average Cost				Item level
			8							PremiumGrains	NewHaven			NULL		Average Cost				Item level
			13							PremiumGrains	BetterHaven			NULL		NULL						None
			4							ColdGrains		Default_Location	ColdItems	Average Cost				Item level
			9							ColdGrains		NewHaven			ColdItems	LIFO						Category level
			14							ColdGrains		BetterHaven			ColdItems	LIFO						Category level
			5							HotGrains		Default_Location	HotItems	Average Cost				Item level
			10							HotGrains		NewHaven			HotItems	FIFO						Category level
			15							HotGrains		BetterHaven			HotItems	FIFO						Category level
		***************************************************************************************************************************************************************************************************************/
		INSERT INTO actual
		SELECT CostingMethod 
		FROM dbo.fnGetCostingMethodAsTable(@ColdGrains, 14)
	END 

	-- Assert 
	BEGIN 			
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