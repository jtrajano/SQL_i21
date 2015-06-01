CREATE PROCEDURE testi21Database.[test fnCalculateLotWeight for adding a Qty value]
AS 
BEGIN
	DECLARE @Lb AS INT = 1
			,@Kg AS INT = 2
			,@10LbBag AS INT = 3
			,@20KgBag AS INT = 4

	-- Arrange
	DECLARE @intLotItemUOMId AS INT = @10LbBag
			,@intLotWeightUOMId AS INT = @Lb
			,@intCostingItemUOMId AS INT = @10LbBag
			,@dblLotWeight AS NUMERIC(18,6)	= 250.75										-- Actual weight for all 7 bags is 250.75. 
			,@dblCostingQty AS NUMERIC(18,6) = 2											-- Add 2 more bags
			,@dblLotWeightPerQty AS NUMERIC(38,20) = 35.821428571428571428571428571429		-- Each bag is 35.821428571428571428571428571429 Lb. 

			,@expected AS NUMERIC(18,6) = 322.392857										-- Expected result is a change in weight to 322.xxxxxx
			,@result AS NUMERIC(18,6)
	
	-- Act
	SELECT @result = dbo.fnCalculateLotWeight(
		@intLotItemUOMId
		,@intLotWeightUOMId
		,@intCostingItemUOMId
		,@dblLotWeight
		,@dblCostingQty
		,@dblLotWeightPerQty	
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END