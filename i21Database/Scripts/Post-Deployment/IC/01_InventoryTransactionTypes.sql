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
				,name = 'Inventory Auto Variance'
				,form = NULL
		UNION ALL 
		SELECT	id = 2
				,name = 'Inventory Write-Off Sold'
				,form = NULL
		UNION ALL 
		SELECT	id = 3
				,name = 'Inventory Revalue Sold'
				,form = NULL
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
				,form = 'Consume'
		UNION ALL 
		SELECT	id = 9
				,name = 'Produce'
				,form = 'Produce'
		UNION ALL 
		SELECT	id = 10
				,name = 'Inventory Adjustment - Quantity'
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
				,name = 'Inventory Adjustment - UOM'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 15
				,name = 'Inventory Adjustment - Item'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 16
				,name = 'Inventory Adjustment - Lot Status'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 17
				,name = 'Inventory Adjustment - Split Lot'
				,form = 'Inventory Adjustment'
		UNION ALL 
		SELECT	id = 18
				,name = 'Inventory Adjustment - Expiry Date'
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
				,form = 'Pick Lots'
        UNION ALL 
        SELECT	id = 22
                ,name = 'Inbound Shipments'
                ,form = 'Inbound Shipments'
		UNION ALL 
        SELECT	id = 23
                ,name = 'Inventory Count'
                ,form = 'Inventory Count'
		UNION ALL 
        SELECT	id = 24
                ,name = 'Empty Out'
                ,form = 'Empty Out'
		UNION ALL 
        SELECT	id = 25
                ,name = 'Process Inventory Count'
                ,form = 'Process Inventory Count'
		UNION ALL 
		SELECT	id = 26
				,name = 'Cost Adjustment'
				,form = NULL
		UNION ALL 
		SELECT	id = 27
				,name = 'Bill'
				,form = 'Bill'
		UNION ALL 
		SELECT	id = 28
				,name = 'Revalue Consume'
				,form = NULL
		UNION ALL 
		SELECT	id = 29
				,name = 'Revalue Produce'
				,form = NULL
		UNION ALL 
		SELECT	id = 30
				,name = 'Revalue Transfer'
				,form = NULL
		UNION ALL 
		SELECT	id = 31
				,name = 'Revalue Build Assembly'
				,form = NULL 
		UNION ALL 
		SELECT	id = 32
				,name = 'iProcess'
				,form = 'iProcess' 
        UNION ALL 
        SELECT    id = 33
                ,name = 'Invoice'
                ,form = 'Invoice'
		UNION ALL 
		SELECT	id = 34
				,name = 'Pick List'
				,form = 'Pick List'
		UNION ALL 
		SELECT	id = 35
				,name = 'Inventory Auto Variance on Negatively Sold or Used Stock'
				,form = NULL
		UNION ALL 
		SELECT	id = 36
				,name = 'Revalue Item'
				,form = NULL 
		UNION ALL 
		SELECT	id = 37
				,name = 'Revalue Split Lot'
				,form = NULL 
		UNION ALL 
		SELECT	id = 38
				,name = 'Revalue Lot Merge'
				,form = NULL 
		UNION ALL 
		SELECT	id = 39
				,name = 'Revalue Lot Move'
				,form = NULL 
		UNION ALL 
		SELECT	id = 40
				,name = 'Revalue Shipment'
				,form = NULL 
		UNION ALL 
		SELECT	id = 41
				,name = 'SAP stock integration'
				,form = 'Inventory Adjustment - SAP' 
		UNION ALL 
		SELECT	id = 42
				,name = 'Inventory Return'
				,form = 'Inventory Receipt' 
		UNION ALL 
		SELECT	id = 43
				,name = 'Inventory Adjustment - Ownership'
				,form = 'Inventory Adjustment'
		UNION ALL
		SELECT id = 44
				,name = 'Storage Settlement'
				,form = 'Storage Settlement'
		UNION ALL
		SELECT id = 45
				,name = 'Credit Memo'
				,form = 'Credit Memo'
		UNION ALL
		SELECT id = 46
				,name = 'Outbound Shipment'
				,form = 'Outbound Shipment'
		UNION ALL
		SELECT id = 47
				,name = 'Inventory Adjustment - Opening Inventory'
				,form = 'Inventory Adjustment'
		UNION ALL
		SELECT id = 48
				,name = 'Inventory Adjustment - Lot Weight'
				,form = 'Inventory Adjustment'
		UNION ALL
		SELECT id = 49
				,name = 'Retail Mark Ups/Downs'
				,form = 'Mark Up and Down' 
		UNION ALL
		SELECT id = 50
				,name = 'Retail Write Offs'
				,form = 'Mark Up and Down' 
		UNION ALL
		SELECT id = 51
				,name = 'Sales Return'
				,form = NULL 
		UNION ALL
		SELECT id = 52
				,name = 'Scale Ticket'
				,form = 'Scale Ticket'
		UNION ALL
		SELECT id = 53
				,name = 'Delivery Sheet'
				,form = 'Delivery Sheet'
		UNION ALL
		SELECT id = 54
				,name = 'Storage Measurement Reading'
				,form = 'Storage Measurement Reading'
		UNION ALL
		SELECT id = 55
				,name = 'Maintain Storage'
				,form = 'Maintain Storage'
		UNION ALL
		SELECT id = 56
				,name = 'Transfer Storage'
				,form = 'Transfer Storage'
		UNION ALL
		SELECT id = 57
				,name = 'Inventory Count By Category'
				,form = 'Inventory Count By Category'
		UNION ALL
		SELECT id = 58
				,name = 'Inventory Adjustment - Closing Balance'
				,form = 'Inventory Adjustment'
		/****************************************************************************************************
		IMPORTANT! When adding a new transaction type, create a new jira to include it in the Stock Rebuild. 
		We don't want to lose those transaction types after the stock has been rebuilt.
		****************************************************************************************************/

		/****************************************************************************************************
		IMPORTANT! When adding a new transaction type, create a new jira to include it in the Stock Rebuild. 
		We don't want to lose those transaction types after the stock has been rebuilt.
		****************************************************************************************************/

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
