CREATE PROCEDURE testi21Database.[test fnCalculateStockUnitQty for the non-zero unit qty]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 3
	DECLARE @dblUOMQty AS NUMERIC(18,6) = 1.6843
	DECLARE @result AS NUMERIC(18,6)
	DECLARE @expected AS NUMERIC(18,6) = (3 * 1.6843)

	-- Act
	SELECT @result = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 