CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intOrderId,
	Receipt.strReceiptType,
	strOrderNumber = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT ISNULL(strPurchaseOrderNumber, 'PO Number not found!') FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intOrderId)
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
				THEN (SELECT ISNULL(dtmDate, 'PO Number not found!') FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intOrderId)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		),
	strSourceNumber = 
		(
			CASE WHEN Receipt.intSourceType = 1 -- Scale
				THEN (SELECT CAST(ISNULL(intTicketNumber, 'Ticket Number not found!')AS NVARCHAR(50)) FROM tblSCTicket WHERE intTicketId = ReceiptItem.intSourceId)
			WHEN Receipt.intSourceType = 2 -- Inbound Shipment
				THEN (SELECT CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50)) FROM tblLGShipment WHERE intShipmentId = ReceiptItem.intSourceId)
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
						WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		),
	dblUnitQty = 
		(
			CASE WHEN Receipt.strReceiptType = 'Contract'
				THEN 0
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT tblICItemUOM.dblUnitQty FROM tblPOPurchaseDetail
						LEFT JOIN tblICItemUOM ON tblPOPurchaseDetail.intUnitOfMeasureId = tblICItemUOM.intItemUOMId
						WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo)
			WHEN Receipt.strReceiptType = 'Transfer Receipt'
				THEN 0
			WHEN Receipt.strReceiptType = 'Direct Transfer'
				THEN 0
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
				THEN ISNULL((SELECT ISNULL(dblOrderQty, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
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
				THEN ISNULL((SELECT ISNULL(dblReceived, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
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