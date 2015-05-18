CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 69 KG BAG to MT]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, metric ton scenario]
	
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3

	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = 0.069 -- (1 * 0.069000 ) -- One 69KG-BAG is 0.069 MT. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@69KG_BAG, @METRIC_TON, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END