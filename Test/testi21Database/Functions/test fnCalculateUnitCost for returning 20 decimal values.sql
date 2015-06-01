CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for returning 20 decimal values]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6) = 5.0
	DECLARE @dblUnitQty AS NUMERIC(18,6) = 7.0
	DECLARE @result AS NUMERIC(38,20)
	DECLARE @expected AS NUMERIC(38,20) = 0.71428571428571428571 -- (5.0 / 7.0)

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 