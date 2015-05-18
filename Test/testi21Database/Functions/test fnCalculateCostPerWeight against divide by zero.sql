CREATE PROCEDURE testi21Database.[test fnCalculateCostPerWeight against divide by zero]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 100 -- say 100 50kg bags. 
	DECLARE @dblCost AS NUMERIC(18,6) = 20 -- say each bag is $20. 
	DECLARE @dblWeight AS NUMERIC(18,6) = 0 -- simulate a divide by zero
	DECLARE @expected AS NUMERIC(18,6) = 0
	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateCostPerWeight(@dblQty, @dblCost, @dblWeight);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 