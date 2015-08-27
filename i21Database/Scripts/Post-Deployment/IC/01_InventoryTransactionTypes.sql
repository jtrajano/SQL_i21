-- --------------------------------------------------
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
				,form = null
		UNION ALL 
		SELECT	id = 2
				,name = 'Inventory Write-Off Sold'
				,form = null
		UNION ALL 
		SELECT	id = 3
				,name = 'Inventory Revalue Sold'
				,form = null
		UNION ALL 
		SELECT	id = 4
				,name = 'Inventory Receipt'
				,form = 'Inventory Receipt'
		UNION ALL 
		SELECT	id = 5
				,name = 'Inventory Shipment'
				,form = 'Inventory Shipment'
		UNION ALL 
		SELECT	id = 6
				,name = 'Purchase Order'
				,form = 'Purchase Order'
		UNION ALL 
		SELECT	id = 7
				,name = 'Sales Order'
				,form = 'Sales Order'
		UNION ALL 
		SELECT	id = 8
				,name = 'Consume'
				,form = null
		UNION ALL 
		SELECT	id = 9
				,name = 'Produce'
				,form = null
		UNION ALL 
		SELECT	id = 10
				,name = 'Inventory Adjustment - Quantity Change'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 11
				,name = 'Build Assembly'
				,form = 'Build Assembly'
		UNION ALL 
		SELECT	id = 12
				,name = 'Inventory Transfer'
				,form = 'Inventory Transfer'
		UNION ALL 
		SELECT	id = 13
				,name = 'Inventory Transfer with Shipment'
				,form = 'Inventory Transfer'
		UNION ALL 
		SELECT	id = 14
				,name = 'Inventory Adjustment - UOM Change'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 15
				,name = 'Inventory Adjustment - Item Change'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 16
				,name = 'Inventory Adjustment - Lot Status Change'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 17
				,name = 'Inventory Adjustment - Split Lot'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 18
				,name = 'Inventory Adjustment - Expiry Date Change'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 19
				,name = 'Inventory Adjustment - Lot Merge'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 20
				,name = 'Inventory Adjustment - Lot Move'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 21
				,name = 'Pick Lots'
				,form = null

) AS InventoryTransactionTypeHardValues
	ON  InventoryTransactionTypes.intTransactionTypeId = InventoryTransactionTypeHardValues.id

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strName = InventoryTransactionTypeHardValues.name
			,strTransactionForm = InventoryTransactionTypeHardValues.form

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intTransactionTypeId
		,strName
		,strTransactionForm
	)
	VALUES (
		InventoryTransactionTypeHardValues.id
		,InventoryTransactionTypeHardValues.name
		,InventoryTransactionTypeHardValues.form
	)
;
GO
print('/*******************  END Populate Inventory Transaction Types *******************/')