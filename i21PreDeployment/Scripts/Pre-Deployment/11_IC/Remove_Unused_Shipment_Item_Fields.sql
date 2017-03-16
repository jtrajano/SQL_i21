
/*
	Remove dblForeignUnitPrice since all fields are now in dblUnitPrice. 
*/

-- 1. Remove any constraints linked with dblForeignUnitPrice
DECLARE @ConstraintName varchar(MAX)
SELECT	@ConstraintName = name 
FROM	sys.default_constraints
WHERE	parent_object_id = OBJECT_ID('tblICInventoryShipmentItem')
		AND parent_column_id = (SELECT column_id FROM sys.columns WHERE name = N'dblForeignUnitPrice' AND object_id = OBJECT_ID(N'tblICInventoryShipmentItem'))

IF @ConstraintName IS NOT NULL
BEGIN
	EXEC('ALTER TABLE tblICInventoryShipmentItem DROP CONSTRAINT ' + @ConstraintName)
END 
GO  

-- 2. Remove the dblForeignUnitPrice column. 
IF EXISTS (SELECT column_id FROM sys.columns WHERE name = N'dblForeignUnitPrice' AND object_id = OBJECT_ID(N'tblICInventoryShipmentItem'))
BEGIN 
	ALTER TABLE [dbo].[tblICInventoryShipmentItem]
	DROP COLUMN dblForeignUnitPrice
END 
