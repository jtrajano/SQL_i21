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
	EXEC tSQLt.FakeTable 'dbo.tblICUnitMeasure', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM', @Identity = 1;

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

	-- Fake Unit of Measure
	INSERT INTO dbo.tblICUnitMeasure(
		strUnitMeasure
	)
	VALUES ('Bushel')

	-- Fake UOM 
	INSERT INTO dbo.tblICItemUOM(
			intItemId
			,intUnitMeasureId
			,dblUnitQty
	)
	SELECT	intItemId = @WetGrains
			,intUnitMeasureId = 1
			,dblUnitQty = 1
			
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
			,intItemUOMId
			,dblStockIn
			,dblStockOut
			,dblCost		
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 10
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 2
			,dblStockOut = 1
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 500
			,dblStockOut = 0
			,dblCost = 2.25

	-- Add fake data in the lifo table. 
	INSERT INTO dbo.tblICInventoryLot (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblStockIn
			,dblStockOut
			,dblCost
	)
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,intLotId = 12345
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,intLotId = 12345
			,dblStockIn = 90
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
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