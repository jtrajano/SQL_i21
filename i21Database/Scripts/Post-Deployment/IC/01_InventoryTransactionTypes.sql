﻿-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Inventory Transaction Types *******************/')
GO
-- Use UPSERT to populate the inventory transaction types
MERGE 
INTO	dbo.tblICInventoryTransactionType
WITH	(HOLDLOCK) 
AS		InventoryTransactionTypes
USING	(
		SELECT	id = 1
				,name = 'Inventory Auto Negative'
		UNION ALL 
		SELECT	id = 2
				,name = 'Inventory Write-Off Sold'
		UNION ALL 
		SELECT	id = 3
				,name = 'Inventory Revalue Sold'
		UNION ALL 
		SELECT	id = 4
				,name = 'Inventory Receipt'
		UNION ALL 
		SELECT	id = 5
				,name = 'Inventory Shipment'
		UNION ALL 
		SELECT	id = 6
				,name = 'Purchase Order'
		UNION ALL 
		SELECT	id = 7
				,name = 'Sales Order'
		UNION ALL 
		SELECT	id = 8
				,name = 'Consume'
		UNION ALL 
		SELECT	id = 9
				,name = 'Produce'
		UNION ALL 
		SELECT	id = 10
				,name = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 11
				,name = 'Build Assembly'
		UNION ALL 
		SELECT	id = 12
				,name = 'Inventory Transfer'
		UNION ALL 
		SELECT	id = 13
				,name = 'Inventory Transfer with Shipment'

) AS InventoryTransactionTypeHardValues
	ON  InventoryTransactionTypes.intTransactionTypeId = InventoryTransactionTypeHardValues.id

-- When id is matched but name is not, then update the name. 
WHEN MATCHED AND InventoryTransactionTypes.strName <> InventoryTransactionTypeHardValues.name THEN 
	UPDATE 
	SET 	strName = InventoryTransactionTypeHardValues.name

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intTransactionTypeId
		,strName
	)
	VALUES (
		InventoryTransactionTypeHardValues.id
		,InventoryTransactionTypeHardValues.name
	)
;
GO
print('/*******************  END Populate Inventory Transaction Types *******************/')