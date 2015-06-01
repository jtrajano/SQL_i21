CREATE PROCEDURE testi21Database.[test fnCalculateStockUnitQty for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6)
	DECLARE @dblUOMQty AS NUMERIC(18,6)
	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 0, @result;
END 