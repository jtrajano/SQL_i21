﻿CREATE PROCEDURE testi21Database.[test fnCalculateCostPerWeight with valid values]
AS 
BEGIN
	-- Arrange
	DECLARE @dblQty AS FLOAT = 100 -- say 100 50kg bags. 
	DECLARE @dblCost AS FLOAT = 20.00 -- say each bag is $20. 
	DECLARE @dblWeight AS FLOAT = 3000 -- instead of 5,000 kgs (100 x 50), the actual weight is 3000 kgs. 
	DECLARE @expected AS NUMERIC(38, 20) = CAST( @dblQty * @dblCost / @dblWeight AS NUMERIC(38, 16)) -- 0.66666666666666660000; Truncated to 16 decimal. Window calculator result rounds it at 17th decimal places as 0.6666666666666667. Actual result is 0.666~ (infinity). So truncate is more favorable than rounding. 
	DECLARE @result AS NUMERIC(38, 20)

	-- Act
	SELECT @result = dbo.fnCalculateCostPerWeight(@dblQty * @dblCost, @dblWeight);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @expected, @result;
END