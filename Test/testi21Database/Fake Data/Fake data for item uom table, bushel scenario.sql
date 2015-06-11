CREATE PROCEDURE [testi21Database].[Fake data for item uom table, bushel scenario]
AS
BEGIN
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM';	
		
	DECLARE @BUSHEL AS INT = 1 
			,@LB AS INT = 2
		
	INSERT INTO dbo.tblICItemUOM(intItemUOMId, dblUnitQty)
	
	SELECT @BUSHEL, 1								-- Bushel is the stock unit. 
	UNION ALL SELECT @LB,  0.017857142857142		-- one bushel is 56 pounds. 
END