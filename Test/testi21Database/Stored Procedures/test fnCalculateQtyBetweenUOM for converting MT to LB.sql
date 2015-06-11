CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting MT to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, metric ton scenario]
	
	DECLARE @METRIC_TON AS INT = 1
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
			,@LB AS INT = 4

	-- Arrange
	DECLARE @dblQty AS NUMERIC(38,20) = 1

	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = 2202.643171 -- One metric ton is 2204.63171 pounds. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@METRIC_TON, @LB, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END