CREATE PROCEDURE testi21Database.[test fnRecalculateAverageCost for average cost from FIFO]
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
	DECLARE @AverageCosting AS INT = 1
	DECLARE @FIFO AS INT = 2
	DECLARE @LIFO AS INT = 3			

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
			,intCostingMethod = @AverageCosting
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @NewHaven
			,intLocationId = @NewHaven * 100
			,intCostingMethod = @AverageCosting	
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @BetterHaven
			,intLocationId = @BetterHaven * 100
			,intCostingMethod = @AverageCosting				
	
	-- Add fake data to the fifo table
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
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 20
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 50
			,dblStockOut = 0
			,dblCost = 2.25

	-- There are data in the lifo table. 
	-- This should be ignored
	INSERT INTO dbo.tblICInventoryLIFO (
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
			,dblStockIn = 100
			,dblStockOut = 100
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 90
			,dblStockOut = 10
			,dblCost = 2.50
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @Default_Location
			,intItemUOMId = 1
			,dblStockIn = 26
			,dblStockOut = 0
			,dblCost = 2.25

	-- Act
	SET @expected = ( ((20 - 10) * 2.50) + (50 * 2.25) ) / (20 - 10 + 50)
	SELECT @result = dbo.fnRecalculateAverageCost(@WetGrains, @Default_Location, 0);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result 
END 
