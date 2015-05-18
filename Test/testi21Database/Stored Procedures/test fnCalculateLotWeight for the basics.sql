CREATE PROCEDURE testi21Database.[test fnCalculateLotWeight for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @intLotItemUOMId AS INT
			,@intLotWeightUOMId AS INT
			,@intCostingItemUOMId AS INT 
			,@dblLotWeight AS NUMERIC(18,6)
			,@dblCostingQty AS NUMERIC(18,6)
			,@dblLotWeightPerQty AS NUMERIC(38,20)

			,@expected AS NUMERIC(18,6) 
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