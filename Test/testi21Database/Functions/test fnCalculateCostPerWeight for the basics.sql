CREATE PROCEDURE testi21Database.[test fnCalculateCostPerWeight for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6)
	DECLARE @dblCost AS NUMERIC(18,6)
	DECLARE @dblWeight AS NUMERIC(18,6)
	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateCostPerWeight(@dblQty, @dblCost, @dblWeight);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 0, @result;
END 