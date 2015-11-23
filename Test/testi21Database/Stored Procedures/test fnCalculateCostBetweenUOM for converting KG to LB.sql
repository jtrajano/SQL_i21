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
		,@KGS_UnitQty AS NUMERIC(38, 20) = 0.453592
		,@50LBBag_UnitQty AS NUMERIC(38, 20) = 50.00
		,@20KGBag_UnitQty AS NUMERIC(38, 20) = 44.0925

	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6) = 25.00

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = (@dblCost / @KGS_UnitQty * @LBS_UnitQty) -- Equals 55.11561050459444. Rounded to 6 decimal places: 55.115611

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@KGS, @LBS, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END