CREATE PROCEDURE testi21Database.[test fnRecalculateAverageCost for average cost from FIFO]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6)

	-- Setup the fake data
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemLocation', @Identity = 1;

	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1
		
	-- Declare the costing methods
	DECLARE @AverageCosting AS INT = 1
	DECLARE @FIFO AS INT = 2
	DECLARE @LIFO AS INT = 3			
			
	-- Add fake data to the item location table
	INSERT INTO dbo.tblICItemLocation (
			intItemId
			,intLocationId
			,intCostingMethod
	)
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,intCostingMethod = @AverageCosting
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @NewHaven
			,intCostingMethod = @AverageCosting	
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @BetterHaven
			,intCostingMethod = @AverageCosting				
	
	-- Add fake data to the fifo table
	INSERT INTO dbo.tblICInventoryFIFO (
			intItemId
			,intLocationId
			,dblStockIn
			,dblStockOut
			,dblCost		
	)
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 20
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 50
			,dblStockOut = 0
			,dblCost = 2.25

	-- There are data in the lifo table. 
	-- This should be ignored
	INSERT INTO dbo.tblICInventoryLIFO (
			intItemId
			,intLocationId
			,dblStockIn
			,dblStockOut
			,dblCost		
	)
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 90
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intLocationId = @Default_Location
			,dblStockIn = 26
			,dblStockOut = 0
			,dblCost = 2.25

	-- Act
	SET @expected = ( ((20 - 10) * 2.50) + (50 * 2.25) ) / (20 - 10 + 50)
	SELECT @result = dbo.fnRecalculateAverageCost(@WetGrains, @Default_Location);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result 
END 