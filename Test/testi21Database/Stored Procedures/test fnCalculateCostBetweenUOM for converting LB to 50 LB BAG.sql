CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting LB to 50 LB BAG]
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
	DECLARE @dblCost AS NUMERIC(18,6) = 25.00

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @Expected AS NUMERIC(18,6) = (@dblCost * @50LBBag_UnitQty) 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@LBS, @50LB_BAG, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END