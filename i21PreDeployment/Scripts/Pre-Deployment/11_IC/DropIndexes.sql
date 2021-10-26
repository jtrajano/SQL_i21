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

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_forDPR' AND object_id = OBJECT_ID('tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_forDPR] ON tblICInventoryTransaction
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_intItemLocationId' AND object_id = OBJECT_ID('tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_intItemLocationId] ON tblICInventoryTransaction
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_detail' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_detail] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransaction_strTransactionId' AND object_id = OBJECT_ID('dbo.tblICInventoryTransaction'))
	DROP INDEX [IX_tblICInventoryTransaction_strTransactionId] ON tblICInventoryTransaction 
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryFIFO' AND object_id = OBJECT_ID('dbo.tblICInventoryFIFO'))
	DROP INDEX [IX_tblICInventoryFIFO] ON tblICInventoryFIFO
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICItemPricingLevel' AND object_id = OBJECT_ID('dbo.tblICItemPricingLevel'))
	DROP INDEX [IX_tblICItemPricingLevel] ON tblICItemPricingLevel
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryFIFO_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryFIFO'))
	DROP INDEX [IX_tblICInventoryFIFO_Posting] ON tblICInventoryFIFO
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryLIFO_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryLIFO'))
	DROP INDEX [IX_tblICInventoryLIFO_Posting] ON tblICInventoryLIFO
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryLot_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryLot'))
	DROP INDEX [IX_tblICInventoryLot_Posting] ON tblICInventoryLot
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryActualCost_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryActualCost'))
	DROP INDEX [IX_tblICInventoryActualCost_Posting] ON tblICInventoryActualCost
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryFIFOStorage_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryFIFOStorage'))
	DROP INDEX [IX_tblICInventoryFIFOStorage_Posting] ON tblICInventoryFIFOStorage
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryLIFOStorage_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryLIFOStorage'))
	DROP INDEX [IX_tblICInventoryLIFOStorage_Posting] ON tblICInventoryLIFOStorage
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryLotStorage_Posting' AND object_id = OBJECT_ID('dbo.tblICInventoryLotStorage'))
	DROP INDEX [IX_tblICInventoryLotStorage_Posting] ON tblICInventoryLotStorage
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryReceiptChargePerItem' AND object_id = OBJECT_ID('dbo.tblICInventoryReceiptChargePerItem'))
	DROP INDEX [IX_tblICInventoryReceiptChargePerItem] ON tblICInventoryReceiptChargePerItem
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryReceiptChargePerItem_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId' AND object_id = OBJECT_ID('dbo.tblICInventoryReceiptChargePerItem'))
	DROP INDEX [IX_tblICInventoryReceiptChargePerItem_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId] ON tblICInventoryReceiptChargePerItem
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICItemPricing_Posting' AND object_id = OBJECT_ID('dbo.tblICItemPricing'))
	DROP INDEX [IX_tblICItemPricing_Posting] ON tblICItemPricing
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICItemCache' AND object_id = OBJECT_ID('dbo.tblICItemCache'))
	DROP INDEX [IX_tblICItemCache] ON tblICItemCache
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tblICInventoryTransactionStorage_intTransactionId' AND object_id = OBJECT_ID('dbo.tblICInventoryTransactionStorage'))
	DROP INDEX [IX_tblICInventoryTransactionStorage_intTransactionId] ON tblICInventoryTransactionStorage
GO