CREATE PROCEDURE testi21Database.[test fnRecalculateAverageCost for average cost from Lot]
AS 
BEGIN
	-- Arrange
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6)

	-- Setup the fake data
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLot', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemLocation';
	EXEC tSQLt.FakeTable 'dbo.tblICItem';

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
	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@STANDARDCOST AS INT = 4 	
			,@LOTCOST AS INT = 5	

	-- Add fake data for the items
	INSERT INTO dbo.tblICItem (intItemId) 
	SELECT	@WetGrains
	UNION ALL SELECT @StickyGrains
	UNION ALL SELECT @PremiumGrains
	UNION ALL SELECT @ColdGrains
	UNION ALL SELECT @HotGrains		
			
	-- Add fake data to the item location table
	INSERT INTO dbo.tblICItemLocation (
			intItemId
			,intItemLocationId
			,intLocationId
			,intCostingMethod
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intLocationId = @Default_Location * 100
			,intCostingMethod = @LOTCOST
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @NewHaven
			,intLocationId = @NewHaven * 100
			,intCostingMethod = @LOTCOST	
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @BetterHaven
			,intLocationId = @BetterHaven * 100
			,intCostingMethod = @LOTCOST				
	
	-- Add fake data to the fifo table
	-- The function fnRecalculateAverageCost should ignore this data. 
	INSERT INTO dbo.tblICInventoryFIFO (
			intItemId
			,intItemLocationId
			,dblStockIn
			,dblStockOut
			,dblCost		
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,dblStockIn = 10
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,dblStockIn = 2
			,dblStockOut = 1
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,dblStockIn = 500
			,dblStockOut = 0
			,dblCost = 2.25

	-- Add fake data in the lifo table. 
	INSERT INTO dbo.tblICInventoryLot (
			intItemId
			,intItemLocationId
			,intLotId
			,dblStockIn
			,dblStockOut
			,dblCost
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intLotId = 12345
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intLotId = 12345
			,dblStockIn = 90
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intLotId = 12345
			,dblStockIn = 26
			,dblStockOut = 0
			,dblCost = 2.25

	-- Act
	SET @expected = ( ((90 - 10) * 2.50) + (26 * 2.25) ) / (90 - 10 + 26)
	SELECT @result = dbo.fnRecalculateAverageCost(@WetGrains, @Default_Location, 0);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result 
END