CREATE PROCEDURE testi21Database.[test fnCalculateCostPerLot for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE	@intItemUOMId AS INT
			,@intWeightUOMId AS INT
			,@intLotUOMId AS INT
			,@dblCostPerItemUOMId AS NUMERIC(38, 20)

	DECLARE @result AS FLOAT
	DECLARE @Expected AS FLOAT

	-- Act
	SELECT @result = dbo.fnCalculateCostPerLot(
			@intItemUOMId
			,@intWeightUOMId
			,@intLotUOMId
			,@dblCostPerItemUOMId
	);

	-- Assert 
	-- Result is the samve value of the current average cost. In this case, it is NULL. 
	EXEC tSQLt.AssertEquals @Expected, @result;
END