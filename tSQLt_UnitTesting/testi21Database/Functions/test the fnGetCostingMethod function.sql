CREATE PROCEDURE testi21Database.[test the fnGetCostingMethod function]
AS 
BEGIN
	-- Arrange	
	DECLARE @AverageCost AS INT
			,@FIFO AS INT
			,@LIFO AS INT
			,@StandardCost AS INT
			,@LotCost AS INT

	SELECT	@AverageCost = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'Average Cost'

	SELECT	@FIFO = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'FIFO'

	SELECT	@LIFO = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'lifo'

	SELECT	@StandardCost = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'STANDARD COST'

	SELECT	@LotCost = intCostingMethodId
	FROM	dbo.tblICCostingMethod
	WHERE	strCostingMethod = 'Lot Cost'

	DECLARE @actual AS INT;
	
	DECLARE @Item1 AS INT = 1
			,@Item2 AS INT = 2
			,@Item3 AS INT = 3
			,@Item4 AS INT = 4
			,@LotItem1 AS INT = 5
			,@LotItem2 AS INT = 6
	
	DECLARE @LocationA AS INT = 100
			,@LocationB AS INT = 200
			,@LocationC AS INT = 300
			,@LocationD AS INT = 400
			
	DECLARE @Category_On_AverageCosting AS INT = 1
			,@Category_On_FIFO AS INT = 2
			,@Category_On_LIFO AS INT = 3
			,@Category_On_StandardCost AS INT = 4

	-- Setup the fake table and data 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICItemLocation';
		INSERT INTO tblICItemLocation(
			intItemId
			,intItemLocationId
			,intCostingMethod
			,intCategoryId
			,intLocationId
		)
		-- Add location for Item 1
		-- Add item-location, costing method is average cost
		SELECT	intItemId = @Item1
				,intItemLocationId = @LocationA
				,intCostingMethod = @AverageCost
				,intCategoryId = NULL
				,intLocationId = @LocationA * 100
		-- Add costing method for FIFO			
		UNION ALL
		SELECT	intItemId = @Item1
				,intItemLocationId = @LocationB
				,intCostingMethod = @FIFO	
				,intCategoryId = NULL
				,intLocationId = @LocationB * 100
		-- Add costing method for LIFO
		UNION ALL
		SELECT	intItemId = @Item1
				,intItemLocationId = @LocationC
				,intCostingMethod = @LIFO	
				,intCategoryId = NULL
				,intLocationId = @LocationC * 100
		-- Add costing method for Standard Cost
		UNION ALL
		SELECT	intItemId = @Item1
				,intItemLocationId = @LocationD
				,intCostingMethod = @StandardCost
				,intCategoryId = NULL
				,intLocationId = @LocationD * 100

		-- Add location for Item 2		
		-- Add item-location, costing method is average cost but category is set to FIFO. 
		-- Item must use FIFO costing because of the category. 
		UNION ALL 
		SELECT	intItemId = @Item2
				,intItemLocationId = @LocationA
				,intCostingMethod = NULL
				,intCategoryId = @Category_On_FIFO
				,intLocationId = @LocationA * 100
		-- Add costing method for FIFO			
		UNION ALL
		SELECT	intItemId = @Item2
				,intItemLocationId = @LocationB
				,intCostingMethod = NULL
				,intCategoryId = @Category_On_FIFO
				,intLocationId = @LocationB * 100
		-- Add costing method for LIFO
		UNION ALL
		SELECT	intItemId = @Item2
				,intItemLocationId = @LocationC
				,intCostingMethod = NULL
				,intCategoryId = @Category_On_FIFO
				,intLocationId = @LocationC * 100
		-- Add costing method for Standard Cost
		UNION ALL
		SELECT	intItemId = @Item2
				,intItemLocationId = @LocationD
				,intCostingMethod = NULL
				,intCategoryId = @Category_On_FIFO
				,intLocationId = @LocationD * 100

		-- Add location for Item 3
		-- Add item-location, costing method is average cost but category is set to LIFO. 
		-- It must use Costing method at item-location level. 
		UNION ALL 
		SELECT	intItemId = @Item3
				,intItemLocationId = @LocationA
				,intCostingMethod = @AverageCost
				,intCategoryId = @Category_On_LIFO
				,intLocationId = @LocationA * 100
		-- Add costing method for FIFO			
		UNION ALL
		SELECT	intItemId = @Item3
				,intItemLocationId = @LocationB
				,intCostingMethod = @AverageCost
				,intCategoryId = @Category_On_LIFO
				,intLocationId = @LocationB * 100
		-- Add costing method for LIFO
		UNION ALL
		SELECT	intItemId = @Item3
				,intItemLocationId = @LocationC
				,intCostingMethod = @AverageCost 
				,intCategoryId = @Category_On_LIFO
				,intLocationId = @LocationC * 100
		-- Add costing method for Standard Cost
		UNION ALL
		SELECT	intItemId = @Item3
				,intItemLocationId = @LocationD
				,intCostingMethod = @AverageCost 
				,intCategoryId = @Category_On_LIFO
				,intLocationId = @LocationD * 100
		
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
		DROP VIEW vyuAPRptPurchase
		EXEC tSQLt.FakeTable 'dbo.tblICItem', @Identity = 1;
		INSERT tblICItem (
			strDescription
			,strLotTracking
		)
		SELECT strDescription = 'I am item 1', strLotTracking = 'No'
		UNION ALL SELECT strDescription = 'I am item 2', strLotTracking = NULL
		UNION ALL SELECT strDescription = 'I am item 3', strLotTracking = 'No'
		UNION ALL SELECT strDescription = 'I am item 4', strLotTracking = 'No'
		UNION ALL SELECT strDescription = 'I am item 5', strLotTracking = 'Yes - Manual'
		UNION ALL SELECT strDescription = 'I am item 6', strLotTracking = 'Yes - Serial Number'
	END


	-- Test average cost
	BEGIN		
		-- Act
		-- Get costing method at Item Location 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @AverageCost, @actual;
	END

	-- Test FIFO
	BEGIN 
		-- Act
		-- Get costing method at Item Location 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, @LocationB);

		-- Assert
		EXEC tSQLt.AssertEquals @FIFO, @actual;
	END
	
	-- Test LIFO
	BEGIN 
		-- Act
		-- Get costing method at Item Location 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, @LocationC);

		-- Assert
		EXEC tSQLt.AssertEquals @LIFO, @actual;
	END
	
	-- Test Standard Cost
	BEGIN 
		-- Act
		-- Get costing method at Item Location 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, @LocationD);

		-- Assert
		EXEC tSQLt.AssertEquals @StandardCost, @actual;
	END	
	
	-- Test the part where item-location is missing
	BEGIN 
		-- Act
		-- Item 2 costing method is NULL. It is also category 2. 
		-- Use Costing method from Category (which is FIFO)
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item2, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @FIFO, @actual;
	END	
	
	-- Test the part where item-location is missing
	BEGIN 
		-- Act
		-- Item 3 costing method is Average Cost
		-- It also belong to in LIFO category
		-- When both are configured, it must use costing method at item-location level. 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item3, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @AverageCost, @actual;
	END		
	
	-- Test the part where item-location is missing
	BEGIN 
		-- Act
		-- Item 3 is set to Average Cost. It is also category 3 (using LIFO) 
		-- But location is NULL. Costing method returned must be NULL. 
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item3, NULL);

		-- Assert
		EXEC tSQLt.AssertEquals NULL, @actual;
	END
	
	-- Null must be returned if no costing method is found. 
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](NULL, NULL);

		-- Assert
		EXEC tSQLt.AssertEquals NULL, @actual;
	END			

	-- Test the Lot tracking: 'Yes - Manual'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@LotItem1, NULL);

		-- Assert
		EXEC tSQLt.AssertEquals @LotCost, @actual;
	END

	-- Test the Lot tracking: 'Yes - Manual'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@LotItem1, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @LotCost, @actual;
	END

	-- Test the Lot tracking: 'Yes - Serial Number'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@LotItem2, NULL);

		-- Assert
		EXEC tSQLt.AssertEquals @LotCost, @actual;
	END

	-- Test the Lot tracking: 'Yes - Serial Number'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@LotItem2, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @LotCost, @actual;
	END

	-- Test the Lot tracking: 'No'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, NULL);

		-- Assert
		EXEC tSQLt.AssertEquals NULL, @actual;
	END

	-- Test the Lot tracking: 'No'
	BEGIN 
		-- Act
		SELECT @actual = [dbo].[fnGetCostingMethod](@Item1, @LocationA);

		-- Assert
		EXEC tSQLt.AssertEquals @AverageCost, @actual;
	END
END