PRINT N'BEGIN: Clean the indexes used in the inventory valuation.'

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryTransaction_strBatchId' AND object_id = OBJECT_ID('tblICInventoryTransaction'))
	EXEC('DROP INDEX tblICInventoryTransaction.[IX_tblICInventoryTransaction_strBatchId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryTransaction_intItemId_intItemLocationId' AND object_id = OBJECT_ID('tblICInventoryTransaction'))
	EXEC('DROP INDEX tblICInventoryTransaction.[IX_tblICInventoryTransaction_intItemId_intItemLocationId]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICInventoryTransactionType_strName' AND object_id = OBJECT_ID('tblICInventoryTransactionType'))
	EXEC('DROP INDEX tblICInventoryTransactionType.[IX_tblICInventoryTransactionType_strName]')

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_tblICUnitMeasure_intUnitMeasureId_strUnitMeasure' AND object_id = OBJECT_ID('tblICUnitMeasure'))
	EXEC('DROP INDEX tblICUnitMeasure.[IX_tblICUnitMeasure_intUnitMeasureId_strUnitMeasure]')

PRINT N'END: Clean the indexes used in the inventory valuation.'