CREATE PROCEDURE testi21Database.[test fnCalculateWeightUnitQty for correct arguments 2]
AS 
BEGIN
	-- Arrange
	DECLARE	@dblQty AS NUMERIC(18,6) = 40
			,@dblTotalWeight AS NUMERIC(38,20) = 2204.62

			,@Expected AS NUMERIC(18,6) = CAST(2204.62 AS FLOAT) / CAST(40 AS FLOAT) 
			,@result AS NUMERIC(18,6) 
	
	-- Act
	SELECT @result = dbo.[fnCalculateWeightUnitQty](
		@dblQty
		,@dblTotalWeight
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END