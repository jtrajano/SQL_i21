CREATE VIEW [dbo].[vyuICGetUnpostedTransactions]
	AS 

SELECT 
	intTransactionId = intInventoryAdjustmentId
	, strTransactionId = strAdjustmentNo
	, strTransactionType = 'Inventory Adjustment'
	, dtmDate = dtmAdjustmentDate
FROM tblICInventoryAdjustment
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT 
	intTransactionId = intInventoryReceiptId
	, strTransactionId = strReceiptNumber
	, strTransactionType = 'Inventory Receipt'
	, dtmDate = dtmReceiptDate
FROM tblICInventoryReceipt
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryShipmentId
	, strTransactionId = strShipmentNumber
	, strTransactionType = 'Inventory Shipment'
	, dtmDate = dtmShipDate
FROM tblICInventoryShipment
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryTransferId
	, strTransactionId = strTransferNo
	, strTransactionType = 'Inventory Transfer'
	, dtmDate = dtmTransferDate
FROM tblICInventoryTransfer
WHERE ISNULL(ysnPosted, 0) = 0