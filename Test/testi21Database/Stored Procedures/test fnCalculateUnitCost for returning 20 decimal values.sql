CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for returning 20 decimal values]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(38, 20) = 5.0
	DECLARE @dblUnitQty AS NUMERIC(38, 20) = 7.0
	DECLARE @result AS NUMERIC(38, 20)
	DECLARE @expected AS NUMERIC(38, 20) = 0.7142857142857143 -- (5.0 / 7.0) 

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END