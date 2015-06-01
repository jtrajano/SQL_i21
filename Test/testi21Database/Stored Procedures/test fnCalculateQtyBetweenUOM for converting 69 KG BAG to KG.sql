CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 69 KG BAG to KG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, metric ton scenario]
	
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3

	-- Arrange
	DECLARE @intItemUOMIdFrom AS INT = @69KG_BAG
	DECLARE @intItemUOMIdTo AS INT = @KG
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = (1 * 0.069000 / 0.001000) -- Equals to 69 KG. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@intItemUOMIdFrom, @intItemUOMIdTo, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END