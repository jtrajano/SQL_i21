﻿CREATE PROCEDURE testi21Database.[test fnCalculateUnitCost for the non-zero unit qty]
AS 
BEGIN
	-- Arrange
	DECLARE @dblCost AS NUMERIC(38, 20) = 3.0
	DECLARE @dblUnitQty AS NUMERIC(18,6) = 1.60
	DECLARE @result AS NUMERIC(38,20)
	DECLARE @Expected AS NUMERIC(38,20) = 1.875000

	-- Act
	SELECT @result = dbo.fnCalculateUnitCost(@dblCost, @dblUnitQty);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals @Expected, @result;
END