CREATE PROCEDURE [testi21Database].[Fake Item Stock Path]
AS
BEGIN
	EXEC testi21Database.[Fake inventory items]

	-- Create the fake table for the stock path
	EXEC tSQLt.FakeTable 'dbo.tblICItemStockPath', @Identity = 1;

	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICItem';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICItemLocation';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICInventoryTransaction_Ancestor';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICInventoryTransaction_Descendant';
END 
