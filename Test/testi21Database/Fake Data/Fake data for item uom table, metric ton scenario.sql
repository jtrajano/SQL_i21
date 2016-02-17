CREATE PROCEDURE [testi21Database].[Fake data for item uom table, metric ton scenario]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
			,@LB AS INT = 4
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @METRIC_TON, 1						-- Metric ton is the stock unit. 
	UNION ALL SELECT @69KG_BAG, 0.069			-- One 69KG BAG is 0.069 mt
	UNION ALL SELECT @KG, 0.001					-- one KG is 0.001 mt
	UNION ALL SELECT @LB, 0.00045359237			-- one LB is 0.00045359237 mt
END