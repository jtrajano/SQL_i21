﻿-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Inventory Transaction Types *******************/')

INSERT INTO dbo.[tblICInventoryTransactionType] (
	[intTransactionTypeId],
	[strName]
)ment
SELECT 
	[intTransactionTypeId] = 1,
	[strName] = 'Inventory Adjustment'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICInventoryTransactionType] WHERE [intTransactionTypeId] = 1)

print('/*******************  END Populate Inventory Transaction Types *******************/')