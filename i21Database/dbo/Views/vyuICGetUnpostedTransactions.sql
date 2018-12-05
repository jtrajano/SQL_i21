CREATE VIEW [dbo].[vyuICGetUnpostedTransactions]
	AS 

SELECT 
	intTransactionId = intInventoryAdjustmentId
	, strTransactionId = strAdjustmentNo
	, strTransactionType = 'Inventory Adjustment' COLLATE Latin1_General_CI_AS
	, dtmDate = dtmAdjustmentDate
	, strDescription
	, Adjustment.intEntityId
	, strUserName
FROM tblICInventoryAdjustment Adjustment
LEFT JOIN tblSMUserSecurity [User] ON [User].[intEntityId] = Adjustment.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT 
	intTransactionId = intInventoryReceiptId
	, strTransactionId = strReceiptNumber
	, strTransactionType = 'Inventory Receipt' COLLATE Latin1_General_CI_AS
	, dtmDate = dtmReceiptDate
	, strDescription = strReceiptNumber
	, Receipt.intEntityId
	, strUserName
FROM tblICInventoryReceipt Receipt
LEFT JOIN tblSMUserSecurity [User] ON [User].[intEntityId] = Receipt.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryShipmentId
	, strTransactionId = strShipmentNumber
	, strTransactionType = 'Inventory Shipment' COLLATE Latin1_General_CI_AS
	, dtmDate = dtmShipDate
	, strDescription = strShipmentNumber
	, Shipment.intEntityId
	, strUserName
FROM tblICInventoryShipment Shipment
LEFT JOIN tblSMUserSecurity [User] ON [User].[intEntityId] = Shipment.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0

UNION ALL
SELECT
	intTransactionId = intInventoryTransferId
	, strTransactionId = strTransferNo
	, strTransactionType = 'Inventory Transfer' COLLATE Latin1_General_CI_AS
	, dtmDate = dtmTransferDate
	, strDescription
	, Transfer.intEntityId
	, strUserName
FROM tblICInventoryTransfer Transfer
LEFT JOIN tblSMUserSecurity [User] ON [User].[intEntityId] = Transfer.intEntityId
WHERE ISNULL(ysnPosted, 0) = 0