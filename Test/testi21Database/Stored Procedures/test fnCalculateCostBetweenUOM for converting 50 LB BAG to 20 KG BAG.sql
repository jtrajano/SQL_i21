CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting 50 LB BAG to 20 KG BAG]
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
	DECLARE @dblCost AS NUMERIC(38, 20) = 25.00 -- / 50lb Bag 

	DECLARE @result AS NUMERIC(38, 20) 
	DECLARE @Expected AS NUMERIC(38, 20) = 28.34949254408346000000 -- @dblCost * @50LBBag_UnitQty / @20KGBag_UnitQty  -- Equals 22.04625 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@50LB_BAG, @20KG_BAG, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END