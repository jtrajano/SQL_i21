CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for the non-zero unit qty]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6) = 3
	DECLARE @dblUnitQty AS NUMERIC(18,6) = 1.6843
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = (3/1.6843)

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 