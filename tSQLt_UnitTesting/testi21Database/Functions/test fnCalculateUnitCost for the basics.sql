CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6)
	DECLARE @dblUnitQty AS NUMERIC(18,6)
	DECLARE @result AS NUMERIC(38,20)

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 0, @result;
END 