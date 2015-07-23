CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intOrderId,
	Receipt.strReceiptType,
	strOrderNumber = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (SELECT CAST(ISNULL(intContractNumber, 'PO Number not found!') AS NVARCHAR) FROM tblCTContractHeader WHERE intContractHeaderId = ReceiptItem.intOrderId)
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
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (SELECT ISNULL(dtmContractDate, 'PO Number not found!') FROM tblCTContractHeader WHERE intContractHeaderId = ReceiptItem.intOrderId)
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
				THEN (SELECT CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50)) FROM vyuLGShipmentContainerReceiptContracts WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId)
			ELSE NULL
			END
		),
	strUnitMeasure = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN (SELECT ISNULL(strItemUOM, 'Ticket Number not found!') FROM vyuCTContractDetailView
							WHERE intContractDetailId = ReceiptItem.intLineNo)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN (SELECT ISNULL(strUnitMeasure, 'Inbound Shipment not found!') FROM vyuLGShipmentContainerReceiptContracts
						WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId
						)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN (SELECT strUnitMeasure FROM tblPOPurchaseDetail
						LEFT JOIN tblICItemUOM ON tblPOPurchaseDetail.intUnitOfMeasureId = tblICItemUOM.intItemUOMId
						LEFT JOIN tblICUnitMeasure ON tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId
						WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo)
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN NULL
			WHEN Receipt.strReceiptType = 'Direct'
				THEN NULL
			ELSE NULL
			END
		),
	dblUnitQty = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN (SELECT ISNULL(1, 0) FROM vyuCTContractDetailView
							WHERE intContractDetailId = ReceiptItem.intLineNo)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN (SELECT ISNULL(dblItemUOMCF, 0) FROM vyuLGShipmentContainerReceiptContracts
						WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId
						)
					ELSE NULL
					END
				)
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
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN (SELECT ISNULL(dblOrderQty, 0) FROM vyuCTContractDetailView
							WHERE intContractDetailId = ReceiptItem.intLineNo)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN (SELECT ISNULL(dblQuantity, 0) FROM vyuLGShipmentContainerReceiptContracts
						WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId
						)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL((SELECT ISNULL(dblOrderQty, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct'
				THEN 0.00
			ELSE 0.00
			END
		),
	dblReceived = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN (SELECT ISNULL(dblReceived, 0) FROM vyuCTContractDetailView
							WHERE intContractDetailId = ReceiptItem.intLineNo)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN (SELECT ISNULL(dblReceivedQty, 0) FROM vyuLGShipmentContainerReceiptContracts
						WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId
						)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL((SELECT ISNULL(dblReceived, 0.00) FROM tblPOPurchaseDetail WHERE intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo), 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN 0.00
			WHEN Receipt.strReceiptType = 'Direct'
				THEN 0.00
			ELSE 0.00
			END
		),
	strContainer = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN NULL
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN (SELECT strContainerNumber FROM vyuLGShipmentContainerReceiptContracts
						WHERE intShipmentContractQtyId = ReceiptItem.intSourceId AND intShipmentBLContainerId = ReceiptItem.intContainerId
						)
					ELSE NULL
					END
				)
			END
		)
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId