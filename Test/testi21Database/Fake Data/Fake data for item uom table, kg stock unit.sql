CREATE PROCEDURE [testi21Database].[Fake data for item uom table, kg stock unit]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @METRIC_TON AS INT = 1 
			,@69KG_BAG AS INT = 2
			,@KG AS INT = 3
			,@LB AS INT = 4
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @METRIC_TON, 1000					-- MT is 1,000 kg. 
	UNION ALL SELECT @69KG_BAG, 69			-- 69KG BAG is 69 kg
	UNION ALL SELECT @KG, 1						-- KG is stock unit. 
	UNION ALL SELECT @LB, 0.453592			    -- one LB is 0.00045359237 mt
END