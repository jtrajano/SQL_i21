-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory Cost Adjustment Types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Adjust Inventory Terms *******************/')
GO
SET IDENTITY_INSERT dbo.tblICItemStockType ON;

-- Use UPSERT to populate the Item Stock Types
MERGE 
INTO	dbo.tblICItemStockType
WITH	(HOLDLOCK) 
AS		StockTypes
USING	(
		SELECT	id = 1
				,strName = 'On Order'
		UNION ALL 
		SELECT	id = 2
				,strName = 'On Storage'
		UNION ALL 
		SELECT	id = 3
				,strName = 'Order Committed'
		UNION ALL 
		SELECT	id = 4
				,strName = 'In-Transit Inbound'
		UNION ALL 
		SELECT	id = 5
				,strName = 'In-Transit Outbound'
		UNION ALL 
		SELECT	id = 6
				,strName = 'In-Transit Direct'
		UNION ALL 
		SELECT	id = 7
				,strName = 'Consigned Purchase'
		UNION ALL 
		SELECT	id = 8
				,strName = 'Consigned Sale'
		UNION ALL 
		SELECT	id = 9
				,strName = 'Reserved'
		UNION ALL
		SELECT id = 10
				,strName = 'Open Purchase Contract'
		UNION ALL
		SELECT id = 11
				,strName = 'Open Sales Contract'
		UNION ALL
		SELECT id = 12
				,strName = 'Usage Qty'


) AS ValuesForItemStockType
	ON  StockTypes.intItemStockTypeId = ValuesForItemStockType.id

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strName = ValuesForItemStockType.strName

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intItemStockTypeId
		,strName
	)
	VALUES (
		ValuesForItemStockType.id
		,ValuesForItemStockType.strName
	)
;

SET IDENTITY_INSERT dbo.tblICItemStockType OFF;


IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_ItemUOMId_IS_NOT_USED' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN 
	EXEC ('
		ALTER TABLE tblICItemUOM
		DROP CONSTRAINT CK_ItemUOMId_IS_NOT_USED		
	')
END

GO
print('/*******************  END Populate Adjust Inventory Terms *******************/')