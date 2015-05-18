CREATE PROCEDURE testi21Database.[test fnCalculateLotQty for reducing a Qty value]
AS 
BEGIN
	DECLARE @Lb AS INT = 1
			,@Kg AS INT = 2
			,@10LbBag AS INT = 3
			,@20KgBag AS INT = 4

	-- Arrange
	DECLARE @intLotItemUOMId AS INT = @10LbBag						
			,@intCostingItemUOMId AS INT = @10LbBag
			,@dblLotQty AS NUMERIC(18,6) = 7						-- There are 7 10Lb Bags
			,@dblLotWeight AS NUMERIC(18,6) = 250.75				-- Actual weight of all the bags is 250.75. 
			,@dblCostingQty AS NUMERIC(18,6) = -3					-- Take away 3 bags. 
			,@dblLotWeightPerQty AS NUMERIC(38,20) = (250.75 / 7)	-- Each bag is 35.821428571428571428571428571429 Lb. 
			,@expected AS NUMERIC(18,6) = 4							-- Expected result is a change in Qty to 4 bags. 
			,@result AS NUMERIC(18,6)
	
	-- Act
	SELECT @result = dbo.fnCalculateLotQty(
		@intLotItemUOMId
		,@intCostingItemUOMId
		,@dblLotQty
		,@dblLotWeight
		,@dblCostingQty
		,@dblLotWeightPerQty	
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 