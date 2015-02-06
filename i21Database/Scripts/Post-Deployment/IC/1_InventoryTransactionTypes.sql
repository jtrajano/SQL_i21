-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Inventory Transaction Types *******************/')
GO

INSERT INTO dbo.[tblICInventoryTransactionType] (
	[intTransactionTypeId],
	[strName]
)
SELECT 
	[intTransactionTypeId] = 1,
	[strName] = 'Inventory Auto Negative'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 1)
UNION ALL
SELECT 
	[intTransactionTypeId] = 2,
	[strName] = 'Inventory Write-Off Sold'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 2)
UNION ALL
SELECT 
	[intTransactionTypeId] = 3,
	[strName] = 'Inventory Revalue Sold'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 3)
UNION ALL 
SELECT 
	[intTransactionTypeId] = 4,
	[strName] = 'Inventory Receipt'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 4)
UNION ALL 
SELECT 
	[intTransactionTypeId] = 5,
	[strName] = 'Inventory Shipment'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 5)

GO
print('/*******************  END Populate Inventory Transaction Types *******************/')