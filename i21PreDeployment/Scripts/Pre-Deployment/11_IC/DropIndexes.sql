-- Drop the following indexes to force the system to re-generate it during install. 
IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_intItemId' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_intItemId] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_intInventoryTransactionId' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_intInventoryTransactionId] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_forGLEntries' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_forGLEntries] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_detail' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_detail] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_strTransactionId' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_strTransactionId] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_forDPR' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_forDPR] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryFIFO' AND object_id = OBJECT_ID('dbo.tblICInventoryFIFO'))
	DROP INDEX [IX_tblICInventoryFIFO] ON tblICInventoryFIFO
GO