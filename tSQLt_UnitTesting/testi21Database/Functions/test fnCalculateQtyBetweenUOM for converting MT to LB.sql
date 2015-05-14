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
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = (1 * 0.000454 ) -- One 69KG-BAG is 0.069 MT. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@METRIC_TON, @LB, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 