CREATE PROCEDURE testi21Database.[test fnCalculateWeightUnitQty for correct arguments]
AS 
BEGIN
	-- Arrange
	DECLARE	@dblQty AS NUMERIC(18,6) = 7
			,@dblTotalWeight AS NUMERIC(38,20) = 250.75

			,@expected AS NUMERIC(18,6) = 35.821428571428571428571428571429
			,@result AS NUMERIC(18,6) 
	
	-- Act
	SELECT @result = dbo.[fnCalculateWeightUnitQty](
		@dblQty
		,@dblTotalWeight
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 