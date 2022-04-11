-- ----------------------------------------------------------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction posting integration
-- ----------------------------------------------------------------------------------------------------

print('/*******************  BEGIN Populate Inventory Transaction Posting Integration *******************/')
GO

-- Use UPSERT to populate the inventory transaction posting integrations
MERGE 
INTO	dbo.tblICInventoryTransactionPostingIntegration
WITH	(HOLDLOCK) 
AS		A
USING	(
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment%'
				AND LinkedTransaction.strName = 'Consume'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment%'
				AND LinkedTransaction.strName = 'Produce'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment%'
				AND LinkedTransaction.strName = 'iProcess'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment%'
				AND LinkedTransaction.strName = 'SAP stock integration'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment - Quantity'
				AND LinkedTransaction.strName = 'Inventory Shipment'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment - Quantity'
				AND LinkedTransaction.strName = 'Delivery Sheet'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment - Quantity'
				AND LinkedTransaction.strName = 'Maintain Storage'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment - Quantity'
				AND LinkedTransaction.strName = 'Scale Ticket'
		UNION ALL 
		SELECT	intTransactionTypeId = HostTransaction.intTransactionTypeId
				,intLinkAllowedTransactionTypeId = LinkedTransaction.intTransactionTypeId
		FROM	dbo.tblICInventoryTransactionType HostTransaction
				,dbo.tblICInventoryTransactionType LinkedTransaction
		WHERE	HostTransaction.strName like 'Inventory Adjustment - Quantity'
				AND LinkedTransaction.strName = 'Bill'
) AS B
	ON  A.intTransactionTypeId = B.intTransactionTypeId
		AND A.intLinkAllowedTransactionTypeId = B.intLinkAllowedTransactionTypeId

-- When id is matched but name is not, then update the name. 
WHEN MATCHED THEN 
	-- Do nothing (update the same thing)
	UPDATE 
	SET 	intTransactionTypeId = B.intTransactionTypeId
			,intLinkAllowedTransactionTypeId = B.intLinkAllowedTransactionTypeId

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intTransactionTypeId
		,intLinkAllowedTransactionTypeId
	)
	VALUES (
		B.intTransactionTypeId
		,B.intLinkAllowedTransactionTypeId
	)
;
GO
print('/*******************  END Populate Inventory Transaction Posting Integration *******************/')
