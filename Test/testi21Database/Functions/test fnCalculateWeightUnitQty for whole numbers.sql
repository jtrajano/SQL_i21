CREATE PROCEDURE testi21Database.[test fnCalculateWeightUnitQty for whole numbers]
AS 
BEGIN
	-- Arrange
	DECLARE	@dblQty AS NUMERIC(18,6) = 100
			,@dblTotalWeight AS NUMERIC(38,20) = 250

			,@expected AS NUMERIC(18,6) = 2.5
			,@result AS NUMERIC(18,6) 
	
	-- Act
	SELECT @result = dbo.[fnCalculateWeightUnitQty](
		@dblQty
		,@dblTotalWeight
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 