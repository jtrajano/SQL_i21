﻿CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting KG to KG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	

	-- Arrange
	DECLARE @intItemUOMIdFrom AS INT = @KGS
	DECLARE @intItemUOMIdTo AS INT = @KGS
	DECLARE @dblQty AS NUMERIC(18,6) = 12.75

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = 12.75

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@intItemUOMIdFrom, @intItemUOMIdTo, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END 