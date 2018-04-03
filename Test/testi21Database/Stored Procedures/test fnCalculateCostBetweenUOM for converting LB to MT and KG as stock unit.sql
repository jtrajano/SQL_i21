CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting LB to MT and KG as stock unit]
AS 
BEGIN
	-- Call the fake data
	EXEC [testi21Database].[Fake data for item uom table, kg stock unit]
	
	DECLARE @MT AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
			,@LB AS INT = 4
		
		,@MT_UnitQty AS NUMERIC(38, 20) = 1000
		,@69KgBag_UnitQty AS NUMERIC(38, 20) = 69
		,@Kg_UnitQty AS NUMERIC(38, 20) = 1
		,@LB_UnitQty AS NUMERIC(38, 20) = 0.453592

	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6) = 100.00

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = 100.00 / 0.453592 * 1000

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@LB, @MT, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END