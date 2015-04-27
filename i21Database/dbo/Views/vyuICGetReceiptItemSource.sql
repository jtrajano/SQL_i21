CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intSourceId,
	Receipt.strReceiptType,
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
		),
	strUnitMeasure = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT strUnitMeasure FROM tblPOPurchaseDetail
						LEFT JOIN tblICItemUOM ON tblPOPurchaseDetail.intUnitOfMeasureId = tblICItemUOM.intItemUOMId
						LEFT JOIN tblICUnitMeasure ON tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId
						WHERE intPurchaseId = ReceiptItem.intSourceId AND intPurchaseDetailId = ReceiptItem.intLineNo)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		),
	dblOrdered = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL((SELECT ISNULL(dblOrderQty, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intSourceId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct'
				THEN 0.00
			ELSE 0.00
			END
		),
	dblReceived = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL((SELECT ISNULL(dblReceived, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intSourceId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct'
				THEN 0.00
			ELSE 0.00
			END
		)
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId