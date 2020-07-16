PRINT N'START - Inventory Transaction Type is renamed. Update strTransactionType in tblGLDetail'
GO
UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Quantity'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Quantity Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - UOM'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - UOM Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Item'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Item Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Lot Status'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Lot Status Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Expiry Date'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Expiry Date Change'

UPDATE gd
SET	gd.strTransactionType = 'Revalue Item'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Revalue Item Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Ownership'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Ownership Change'

UPDATE gd
SET	gd.strTransactionType = 'Inventory Adjustment - Lot Weight'
FROM tblGLDetail gd 
WHERE gd.strTransactionType = 'Inventory Adjustment - Change Lot Weight'
GO

PRINT N'END - Inventory Transaction Type is renamed. Update strTransactionType in tblGLDetail'
GO