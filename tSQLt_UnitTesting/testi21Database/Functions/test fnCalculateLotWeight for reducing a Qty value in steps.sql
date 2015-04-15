CREATE PROCEDURE testi21Database.[test fnCalculateLotWeight for reducing a Qty value in steps]
AS 
BEGIN
	DECLARE @Lb AS INT = 1
			,@Kg AS INT = 2
			,@10LbBag AS INT = 3
			,@20KgBag AS INT = 4

	-- Step 1
	BEGIN 
		-- Arrange 1
		DECLARE @intLotItemUOMId AS INT = @10LbBag
				,@intLotWeightUOMId AS INT = @Lb
				,@intCostingItemUOMId AS INT = @10LbBag
				,@dblLotWeight AS NUMERIC(18,6)	= 250.75										-- Actual weight for all 7 bags is 250.75. 
				,@dblCostingQty AS NUMERIC(18,6) = -2											-- Take away 2 bags
				,@dblLotWeightPerQty AS NUMERIC(38,20) = 35.821428571428571428571428571429		-- Each bag is 35.821428571428571428571428571429 Lb. 

				,@expected AS NUMERIC(18,6) = 179.107143										-- Expected result is a change in weight to 179.xxxxxx
				,@result AS NUMERIC(18,6)
	
		-- Act 1
		SELECT @result = dbo.fnCalculateLotWeight(
			@intLotItemUOMId
			,@intLotWeightUOMId
			,@intCostingItemUOMId
			,@dblLotWeight
			,@dblCostingQty
			,@dblLotWeightPerQty	
		);

		-- Assert  1
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Step 2
	BEGIN
		-- Arrange 2
		SELECT	 @intLotItemUOMId = @10LbBag
				,@intLotWeightUOMId = @Lb
				,@intCostingItemUOMId = @10LbBag
				,@dblLotWeight = 179.107143									-- Actual weight for all 5 bags is 250.75. 
				,@dblCostingQty = -2										-- Take away 2 bags
				,@dblLotWeightPerQty = 35.821428571428571428571428571429	-- Each bag is 35.821428571428571428571428571429 Lb. 

				,@expected = 107.464286										-- Expected result is a change in weight to 179.xxxxxx
				,@result = NULL 
	
		-- Act 2
		SELECT @result = dbo.fnCalculateLotWeight(
			@intLotItemUOMId
			,@intLotWeightUOMId
			,@intCostingItemUOMId
			,@dblLotWeight
			,@dblCostingQty
			,@dblLotWeightPerQty	
		);

		-- Assert  2
		EXEC tSQLt.AssertEquals @expected, @result;
	END 

	-- Step 3
	BEGIN
		-- Arrange 3
		SELECT	 @intLotItemUOMId = @10LbBag
				,@intLotWeightUOMId = @Lb
				,@intCostingItemUOMId = @10LbBag
				,@dblLotWeight = 107.464286									-- Actual weight for all 3 bags is 250.75. 
				,@dblCostingQty = -3										-- Take away the remaining bags
				,@dblLotWeightPerQty = 35.821428571428571428571428571429	-- Each bag is 35.821428571428571428571428571429 Lb. 

				,@expected = 0												-- Expected result is a change in weight to 0.00
				,@result = NULL 
	
		-- Act 3
		SELECT @result = dbo.fnCalculateLotWeight(
			@intLotItemUOMId
			,@intLotWeightUOMId
			,@intCostingItemUOMId
			,@dblLotWeight
			,@dblCostingQty
			,@dblLotWeightPerQty	
		);

		-- Assert  3
		EXEC tSQLt.AssertEquals @expected, @result;
	END 
END 