CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting 20 KG BAG to 50 LB BAG]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	
		
		,@LBS_UnitQty AS NUMERIC(38, 20) = 1
		,@KGS_UnitQty AS NUMERIC(38, 20) = 0.453592
		,@50LBBag_UnitQty AS NUMERIC(38, 20) = 50.00
		,@20KGBag_UnitQty AS NUMERIC(38, 20) = 44.0925

	-- Arrange
	DECLARE @dblCost AS NUMERIC(38,20) = 25.00

	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = CAST( (CAST(@dblCost AS FLOAT) / CAST(@20KGBag_UnitQty AS FLOAT) * CAST(@50LBBag_UnitQty AS FLOAT)) AS NUMERIC(38, 14)) -- Equals 28.34949254408346. (Rounded to 14 decimal places)

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@20KG_BAG, @50LB_BAG, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END