﻿CREATE PROCEDURE testi21Database.[test fnCalculateLotQty for reducing a Weight value]
AS 
BEGIN
	DECLARE @Lb AS INT = 1
			,@Kg AS INT = 2
			,@10LbBag AS INT = 3
			,@20KgBag AS INT = 4

	-- Arrange
	DECLARE @intLotItemUOMId AS INT = @10LbBag
			,@intCostingItemUOMId AS INT = @Lb
			,@dblLotQty AS NUMERIC(18,6) = 7											-- There are 7 bags
			,@dblLotWeight AS NUMERIC(18,6) = 250.75									-- Actual weight of all bags is 250.75 Lb. 
			,@dblCostingQty AS NUMERIC(18,6) = -70										-- Take away 70 lb
			,@dblLotWeightPerQty AS NUMERIC(38,20) = 35.821428571428571428571428571429	-- Each bag is 35.xxxx Lb.  
			,@expected AS NUMERIC(18,6) = (250.75 - 70) / 35.821428571428571428571428571429	-- Expected result is a change in Qty to 5.xxx bags.
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
