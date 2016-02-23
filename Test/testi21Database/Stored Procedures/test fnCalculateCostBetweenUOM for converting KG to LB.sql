﻿CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting KG to LB]
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
	DECLARE @expected AS NUMERIC(38,20) = 55.11561050459440000000 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@KGS, @LBS, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END