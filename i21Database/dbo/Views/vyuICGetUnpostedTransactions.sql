CREATE VIEW [dbo].[vyuICGetUnpostedTransactions]
	AS 

SELECT 
	intTransactionId = intInventoryAdjustmentId
	, strTransactionId = strAdjustmentNo
	, strTransactionType = 'Inventory Adjustment'
	, dtmDate = dtmAdjustmentDate
	, strDescription
	, intEntityId
	, strUserName
FROM tblICInventoryAdjustment Adjustment
LEFT JOIN tblSMUserSecurity [User] ON [User].intEntityUserSecurityId = Adjustment.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT 
	intTransactionId = intInventoryReceiptId
	, strTransactionId = strReceiptNumber
	, strTransactionType = 'Inventory Receipt'
	, dtmDate = dtmReceiptDate
	, strDescription = strReceiptNumber
	, intEntityId
	, strUserName
FROM tblICInventoryReceipt Receipt
LEFT JOIN tblSMUserSecurity [User] ON [User].intEntityUserSecurityId = Receipt.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryShipmentId
	, strTransactionId = strShipmentNumber
	, strTransactionType = 'Inventory Shipment'
	, dtmDate = dtmShipDate
	, strDescription = strShipmentNumber
	, intEntityId
	, strUserName
FROM tblICInventoryShipment Shipment
LEFT JOIN tblSMUserSecurity [User] ON [User].intEntityUserSecurityId = Shipment.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryTransferId
	, strTransactionId = strTransferNo
	, strTransactionType = 'Inventory Transfer'
	, dtmDate = dtmTransferDate
	, strDescription
	, intEntityId
	, strUserName
FROM tblICInventoryTransfer Transfer
LEFT JOIN tblSMUserSecurity [User] ON [User].intEntityUserSecurityId = Transfer.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0