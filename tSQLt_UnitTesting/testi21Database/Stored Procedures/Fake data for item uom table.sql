CREATE PROCEDURE [testi21Database].[Fake data for item uom table]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @LBS AS INT = 1 
			,@KGS AS INT = 2
			,@50LB_BAG AS INT = 3
			,@20KG_BAG AS INT = 4	
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @LBS, 1						-- @LBS is the stock unit. 
	UNION ALL SELECT @KGS, 0.453592		-- one KG is 0.453592 Lbs
	UNION ALL SELECT @50LB_BAG, 50		-- one 50-Lb bag is 50 Lbs
	UNION ALL SELECT @20KG_BAG, 44.0925	-- one 20-Kg bag is 44.0925 Lbs	
END 
