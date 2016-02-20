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
	DECLARE @expected AS NUMERIC(38,20) = 2204.62262184000000000000 -- 1 / 0.00045359237	 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@METRIC_TON, @LB, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END