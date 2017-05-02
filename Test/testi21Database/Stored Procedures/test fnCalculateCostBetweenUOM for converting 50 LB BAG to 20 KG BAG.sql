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
		,@KGS_UnitQty AS NUMERIC(38, 20) = 2.20462262185
		,@50LBBag_UnitQty AS NUMERIC(38, 20) = 50.00
		,@20KGBag_UnitQty AS NUMERIC(38, 20) = 44.092452437

	-- Arrange
	DECLARE @dblCost AS NUMERIC(38, 20) = 25.00 -- / 50lb Bag 

	DECLARE @result AS NUMERIC(38, 20) 
	DECLARE @expected AS NUMERIC(38, 20) = dbo.fnDivide(dbo.fnMultiply(@dblCost, @50LBBag_UnitQty), @20KGBag_UnitQty)  -- Equals 28.34952312490 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@50LB_BAG, @20KG_BAG, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
	
	-- Assert it again in rounded values. 
	SET @expected = ROUND(@expected, 6)
	SET @result = ROUND(@result, 6)
	EXEC tSQLt.AssertEquals @expected, @result;
END