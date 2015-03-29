CREATE PROCEDURE testi21Database.[test fnCalculateCostPerWeight with valid values]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 100 -- say 100 50kg bags. 
	DECLARE @dblCost AS NUMERIC(18,6) = 20 -- say each bag is $20. 
	DECLARE @dblWeight AS NUMERIC(18,6) = 3000 -- instead of 5,000 kgs (100 x 50), the actual weight is 3000 kgs. 
	DECLARE @expected AS NUMERIC(18,6) = @dblQty * @dblCost / @dblWeight 
	DECLARE @result AS NUMERIC(18,6)

	-- Act
	SELECT @result = dbo.fnCalculateCostPerWeight(@dblQty, @dblCost, @dblWeight);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END 