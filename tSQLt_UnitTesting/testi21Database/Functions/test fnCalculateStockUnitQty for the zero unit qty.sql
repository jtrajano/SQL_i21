CREATE PROCEDURE testi21Database.[test fnCalculateStockUnitQty for the zero unit qty]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 100
	DECLARE @dblUOMQty AS NUMERIC(18,6) = 0
	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblQty, @dblUOMQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 100, @result;
END 