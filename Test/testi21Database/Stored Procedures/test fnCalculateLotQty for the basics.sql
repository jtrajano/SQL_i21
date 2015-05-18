CREATE PROCEDURE testi21Database.[test fnCalculateLotQty for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intLotItemUOMId AS INT
			,@intCostingItemUOMId AS INT 
			,@dblLotQty AS NUMERIC(18,6)
			,@dblLotWeight AS NUMERIC(18,6)
			,@dblCostingQty AS NUMERIC(18,6)
			,@dblLotWeightPerQty AS NUMERIC(38,20)
			,@expected AS NUMERIC(18,6) 
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