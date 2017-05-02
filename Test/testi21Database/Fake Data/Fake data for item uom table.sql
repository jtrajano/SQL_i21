CREATE PROCEDURE [testi21Database].[Fake data for item uom table]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @LBS AS INT = 1 
			,@KGS AS INT = 2
			,@50LB_BAG AS INT = 3
			,@20KG_BAG AS INT = 4
		
	INSERT INTO dbo.tblICItemUOM(		
		intItemUOMId		
		, dblUnitQty
		, ysnStockUnit
		, intItemId
	)
	SELECT	@LBS, 1, 1, 1 				-- @LBS is the stock unit. 
	UNION ALL 
	SELECT	@KGS, 2.20462262185, 0, 1	-- one KG is 2.20462262185 Lbs
	UNION ALL 
	SELECT	@50LB_BAG, 50, 0, 1			-- one 50-Lb bag is 50 Lbs
	UNION ALL 
	SELECT	@20KG_BAG, 44.092452437, 0, 1	-- one 20-Kg bag is 44.0925 Lbs	
END
