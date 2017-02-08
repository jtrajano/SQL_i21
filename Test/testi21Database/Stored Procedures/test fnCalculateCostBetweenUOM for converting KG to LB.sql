CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting KG to LB]
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
	DECLARE @dblCost AS FLOAT = 25.00 -- /Kgs
	DECLARE @result AS NUMERIC(38,20) 
	DECLARE @expected AS NUMERIC(38,20) = 11.339809240

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@KGS, @LBS, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;

	SET @expected = ROUND(@expected, 6)
	SET @result = ROUND(@result, 6) 

	-- Assert the rounded values 
	EXEC tSQLt.AssertEquals @expected, @result;
END