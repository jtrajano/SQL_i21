PRINT N'BEGIN: Clean the indexes in the cost bucket tables.'
   
-- Lot Cost Bucket
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLot_intItemId_intLocationId' AND object_id = OBJECT_ID('tblICInventoryLot'))
	EXEC('DROP INDEX tblICInventoryLot.[IX_tblICInventoryLot_intItemId_intLocationId]')
    
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLotCostAdjustmentLog_intInventoryLotId' AND object_id = OBJECT_ID('tblICInventoryLotCostAdjustmentLog'))
	EXEC('DROP INDEX tblICInventoryLotCostAdjustmentLog.[IX_tblICInventoryLotCostAdjustmentLog_intInventoryLotId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLotOut_intInventoryTransactionId' AND object_id = OBJECT_ID('tblICInventoryLotOut'))
	EXEC('DROP INDEX tblICInventoryLotOut.[IX_tblICInventoryLotOut_intInventoryTransactionId]')

-- FIFO/AVG Cost Bucket	
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryFIFO_intItemId_intLocationId' AND object_id = OBJECT_ID('tblICInventoryFIFO'))
	EXEC('DROP INDEX tblICInventoryFIFO.[IX_tblICInventoryFIFO_intItemId_intLocationId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryFIFO_strTransactionId' AND object_id = OBJECT_ID('tblICInventoryFIFO'))
	EXEC('DROP INDEX tblICInventoryFIFO.[IX_tblICInventoryFIFO_strTransactionId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryFIFOCostAdjustmentLog_intInventoryFIFOId' AND object_id = OBJECT_ID('tblICInventoryFIFOCostAdjustmentLog'))
	EXEC('DROP INDEX tblICInventoryFIFOCostAdjustmentLog.[IX_tblICInventoryFIFOCostAdjustmentLog_intInventoryFIFOId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryFIFOOut_intInventoryTransactionId' AND object_id = OBJECT_ID('tblICInventoryFIFOOut'))
	EXEC('DROP INDEX tblICInventoryFIFOOut.[IX_tblICInventoryFIFOOut_intInventoryTransactionId]')	

-- LIFO Cost Bucket	
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLIFO_intItemId_intItemLocationId' AND object_id = OBJECT_ID('tblICInventoryLIFO'))
	EXEC('DROP INDEX tblICInventoryLIFO.[IX_tblICInventoryLIFO_intItemId_intItemLocationId]')	

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLIFOCostAdjustmentLog_intInventoryLIFOId' AND object_id = OBJECT_ID('tblICInventoryLIFOCostAdjustmentLog'))
	EXEC('DROP INDEX tblICInventoryLIFOCostAdjustmentLog.[IX_tblICInventoryLIFOCostAdjustmentLog_intInventoryLIFOId]')	

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryLIFOOut_intInventoryTransactionId' AND object_id = OBJECT_ID('tblICInventoryLIFOOut'))
	EXEC('DROP INDEX tblICInventoryLIFOOut.[IX_tblICInventoryLIFOOut_intInventoryTransactionId]')	

-- Actual Cost Bucket
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryActualCost_intItemId_intLocationId' AND object_id = OBJECT_ID('tblICInventoryActualCost'))
	EXEC('DROP INDEX tblICInventoryActualCost.[IX_tblICInventoryActualCost_intItemId_intLocationId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryActualCostAdjustmentLog_intInventoryActualCostId' AND object_id = OBJECT_ID('tblICInventoryActualCostAdjustmentLog'))
	EXEC('DROP INDEX tblICInventoryActualCostAdjustmentLog.[IX_tblICInventoryActualCostAdjustmentLog_intInventoryActualCostId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryActualCost_intInventoryTransactionId' AND object_id = OBJECT_ID('tblICInventoryActualCostOut'))
	EXEC('DROP INDEX tblICInventoryActualCostOut.[IX_tblICInventoryActualCost_intInventoryTransactionId]')
	
PRINT N'END: Clean the indexes in the cost bucket tables.'