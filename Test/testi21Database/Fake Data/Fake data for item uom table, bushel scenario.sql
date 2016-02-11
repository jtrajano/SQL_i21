CREATE PROCEDURE [testi21Database].[Fake data for item uom table, bushel scenario]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @BUSHEL AS INT = 1 
			,@LB AS INT = 2
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @BUSHEL, 1											-- Bushel is the stock unit. A bushel is 56 lb. 
	UNION ALL SELECT @LB,  0.01785714285714285714285714285714	-- 1 lb is 0.01785714285714285714285714285714 bushel. 
END