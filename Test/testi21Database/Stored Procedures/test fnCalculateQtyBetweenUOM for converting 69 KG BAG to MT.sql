CREATE PROCEDURE testi21Database.[test fnCalculateQtyBetweenUOM for converting 69 KG BAG to MT]
AS 
BEGIN
	-- Call the fake data
	EXEC testi21Database.[Fake data for item uom table, metric ton scenario]
	
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3

	DECLARE @METRIC_TON_UnitQty AS NUMERIC(38,20) = 1						-- Metric ton is the stock unit. 
			,@69KG_BAG_UnitQty AS NUMERIC(38,20) = 0.069			-- One 69KG BAG is 0.069 mt
			,@KG_UnitQty AS NUMERIC(38,20) = 0.001					-- one KG is 0.001 mt
			,@LB_UnitQty AS NUMERIC(38,20) = 0.00045359237			-- one LB is 0.00045359237 mt

	-- Arrange
	DECLARE @dblQty AS NUMERIC(18,6) = 1

	DECLARE @result AS NUMERIC(18,6) 
	DECLARE @Expected AS NUMERIC(18,6) = 0.069 -- (1 * 0.069000 ) -- One 69KG-BAG is 0.069 MT. 

	-- Act
	SELECT @result = dbo.fnCalculateQtyBetweenUOM(@69KG_BAG, @METRIC_TON, @dblQty)

	-- Assert 
	EXEC tSQLt.AssertEquals @Expected, @result;
END