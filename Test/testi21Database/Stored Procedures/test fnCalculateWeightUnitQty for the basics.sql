CREATE PROCEDURE testi21Database.[test fnCalculateWeightUnitQty for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE	@dblQty AS NUMERIC(18,6)
			,@dblTotalWeight AS NUMERIC(38,20)

			,@expected AS NUMERIC(18,6) = 0
			,@result AS NUMERIC(18,6) 
	
	-- Act
	SELECT @result = dbo.[fnCalculateWeightUnitQty](
		@dblQty
		,@dblTotalWeight
	);

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END