CREATE PROCEDURE [testi21Database].[Fake data for item uom table, metric ton scenario]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @METRIC_TON, 1						-- Metric ton is the stock unit. 
	UNION ALL SELECT @69KG_BAG, 0.069			-- One 69KG BAG IS 0.069 Metric Ton
	UNION ALL SELECT @KG, 0.001					-- one KG is 0.001 Metric Ton
END 
