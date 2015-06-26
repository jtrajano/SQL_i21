CREATE PROCEDURE [testi21Database].[Fake data for item uom table, kg scenario]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @KGS AS INT = 1
			,@LBS AS INT = 2
			,@60KG_BAG AS INT = 3
		
	INSERT INTO dbo.tblICItemUOM(		
		intItemUOMId		
		, dblUnitQty
		, ysnStockUnit
		, intItemId
	)
	SELECT	@KGS, 1.00, 1, 1 				-- @KGS is the stock unit. 
	UNION ALL 
	SELECT	@LBS, 0.4535920, 0, 1			-- one LB is 0.456592 KG
	UNION ALL 
	SELECT	@60KG_BAG, 60.00, 0, 1			-- one 60-kg bag is 60 KGs. 
END
