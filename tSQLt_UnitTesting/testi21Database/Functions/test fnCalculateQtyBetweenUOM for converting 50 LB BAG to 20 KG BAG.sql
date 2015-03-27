CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 50 LB BAG to 20 KG BAG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	

	-- Arrange
	DECLARE @intItemUOMIdFrom AS INT = @50LB_BAG
	DECLARE @intItemUOMIdTo AS INT = @20KG_BAG
	DECLARE @dblQty AS NUMERIC(18,6) = 15.25

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = (15.25 * 50 / 44.0925) -- Equals 17.293190451 but rounded to 6 decimal places. Final result is 17.293190

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@intItemUOMIdFrom, @intItemUOMIdTo, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 
