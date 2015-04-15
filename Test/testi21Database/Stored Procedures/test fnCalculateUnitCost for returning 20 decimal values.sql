CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for returning 20 decimal values]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(38, 20) = 5.000000000000000000000
	DECLARE @dblUnitQty AS NUMERIC(18,6) = 7.000000
	DECLARE @result AS NUMERIC(38,20)
	DECLARE @expected AS NUMERIC(38,20) = @dblCost / @dblUnitQty 
		
	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END