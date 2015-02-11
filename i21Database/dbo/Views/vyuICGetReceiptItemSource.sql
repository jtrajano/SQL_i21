CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intSourceId,
	strSourceId = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT ISNULL(strPurchaseOrderNumber, 'PO Number not found!') FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intSourceId)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		),
	dtmDate = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT ISNULL(dtmDate, 'PO Number not found!') FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intSourceId)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		)
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId