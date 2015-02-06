CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intSourceId,
	strSourceId = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN 'Not Yet Implemented'
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT ISNULL(strPurchaseOrderNumber, 'PO Number not found!') FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intSourceId)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN 'Not Yet Implemented'
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN 'Not Yet Implemented'
			WHEN Receipt.strReceiptType = 'Direct'
				THEN ''
			ELSE ''
			END
		)
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId