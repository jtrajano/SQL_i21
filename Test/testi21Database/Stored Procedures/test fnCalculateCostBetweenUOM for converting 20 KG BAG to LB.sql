CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting 20 KG BAG to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table]
	
	DECLARE @LBS AS INT = 1 
		,@KGS AS INT = 2
		,@50LB_BAG AS INT = 3
		,@20KG_BAG AS INT = 4	
		
		,@LBS_UnitQty AS FLOAT = 1
		,@KGS_UnitQty AS FLOAT = 0.453592
		,@50LBBag_UnitQty AS FLOAT = 50.00
		,@20KGBag_UnitQty AS FLOAT = 44.0925

	-- Arrange
	DECLARE @dblCost AS FLOAT = 25.00

	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = 0.5669904624 -- 25.00 / 44.092452437 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@20KG_BAG, @LBS, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END