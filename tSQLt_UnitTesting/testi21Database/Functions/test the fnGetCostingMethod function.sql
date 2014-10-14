CREATE PROCEDURE testi21Database.[test the fnGetCostingMethod function]
AS 
BEGIN
	-- Arrange
	DECLARE @intItemId AS INT
	DECLARE @intLocationId AS INT
	
	DECLARE @AverageCost AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@StandardCost AS INT = 4 	

	DECLARE @actual AS INT;

	-- Setup the fake table and data 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICItemLocationStore';
		INSERT INTO tblICItemLocationStore(
			intItemLocationStoreId
			,intItemId
			,intLocationId
			,intCostingMethod
		)
		-- Add item-location, costing method is average cost
		SELECT	intItemLocationStoreId = 1
				,intItemId = 1
				,intLocationId = 100
				,intCostingMethod = @AverageCost
		-- Add costing method for FIFO			
		UNION ALL
		SELECT	intItemLocationStoreId = 2
				,intItemId = 1
				,intLocationId = 200
				,intCostingMethod = @FIFO	
		-- Add costing method for LIFO
		UNION ALL
		SELECT	intItemLocationStoreId = 3
				,intItemId = 1
				,intLocationId = 300
				,intCostingMethod = @LIFO	
		-- Add costing method for Standard Cost
		UNION ALL
		SELECT	intItemLocationStoreId = 4
				,intItemId = 1
				,intLocationId = 400
				,intCostingMethod = @StandardCost
		
		-- Setup a fake table and data for tblICCategory
		EXEC tSQLt.FakeTable 'dbo.tblICCategory', @Identity = 1;
		INSERT tblICCategory (
			intCostingMethod
		)
		SELECT intCostingMethod = @AverageCost -- Category 1
		UNION ALL SELECT intCostingMethod = @FIFO -- Category 2 
		UNION ALL SELECT intCostingMethod = @LIFO -- Category 3
		UNION ALL SELECT intCostingMethod = @StandardCost -- Category 4
		
		-- Setup a fake table and data for tblICItem
		EXEC tSQLt.FakeTable 'dbo.tblICItem', @Identity = 1;
		INSERT tblICItem (
			intTrackingId
		)
		SELECT intTrackingId = 2 -- Item 1 with category 2
		UNION ALL SELECT intTrackingId = 2 -- Item 2 with category 2
		UNION ALL SELECT intTrackingId = 3 -- Item 3 with category 3
		UNION ALL SELECT intTrackingId = 4 -- Item 4 with category 4
	END
	
	-- Test average cost
	BEGIN		
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 100
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @AverageCost, @actual;
	END
	
	-- Test FIFO
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 200
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @FIFO, @actual;
	END
	
	-- Test LIFO
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 300
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @LIFO, @actual;
	END
	
	-- Test Standard Cost
	BEGIN 
		-- Act
		SET @intItemId = 1
		SET @intLocationId = 400
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @StandardCost, @actual;
	END	
	
	-- Test the part where item-location is missing
	BEGIN 
		-- Act
		SET @intItemId = 2 -- Item 2 is category 2. Costing method used in @FIFO
		SET @intLocationId = 100
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @FIFO, @actual;
	END	
	
	-- Test the part where item-location is missing
	BEGIN 
		-- Act
		SET @intItemId = 3 -- Item 3 is category 2. Costing method used in @FIFO
		SET @intLocationId = NULL
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals @LIFO, @actual;
	END
	
	-- Null must be returned if no costing method is found. 
	BEGIN 
		-- Act
		SET @intItemId = NULL
		SET @intLocationId = NULL
		SELECT @actual = [dbo].[fnGetCostingMethod](@intItemId, @intLocationId);

		-- Assert
		EXEC tSQLt.AssertEquals NULL, @actual;
	END			
END 