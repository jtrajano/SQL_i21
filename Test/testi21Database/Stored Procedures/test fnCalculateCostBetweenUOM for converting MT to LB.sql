CREATE PROCEDURE testi21Database.[test fnCalculateCostBetweenUOM for converting MT to LB]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, metric ton scenario]
	
	DECLARE @MT AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
			,@LB AS INT = 4
		
		,@MT_UnitQty AS NUMERIC(38, 20) = 1
		,@69KgBag_UnitQty AS NUMERIC(38, 20) = 0.069
		,@Kg_UnitQty AS NUMERIC(38, 20) = 0.001
		,@LB_UnitQty AS NUMERIC(38, 20) = 0.00045359237

	-- Arrange
	DECLARE @dblCost AS NUMERIC(18,6) = 100.00

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @expected AS NUMERIC(18,6) = 100.00 * 0.00045359237 

	-- Act
	SELECT @result = dbo.fnCalculateCostBetweenUOM(@MT, @LB, @dblCost)

	-- Assert 
	EXEC tSQLt.AssertEquals @expected, @result;
END