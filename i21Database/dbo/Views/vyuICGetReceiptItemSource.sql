CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intOrderId,
	Receipt.strReceiptType,
	strOrderNumber = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN ISNULL(ContractView.strContractNumber, 'Contract No not found!')
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL(POView.strPurchaseOrderNumber, 'PO Number not found!')
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
				THEN ContractView.dtmContractDate
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
				THEN (SELECT strTicketNumber FROM tblSCTicket WHERE intTicketId = ReceiptItem.intSourceId)
			WHEN Receipt.intSourceType = 2 -- Inbound Shipment
				THEN CAST(ISNULL(LogisticsView.intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50))
			WHEN Receipt.intSourceType = 3 -- Transport
				THEN (SELECT CAST(ISNULL(strTransaction, 'Transport not found!')AS NVARCHAR(50)) FROM vyuTRTransportReceipt WHERE intTransportReceiptId = ReceiptItem.intSourceId)
			ELSE NULL
			END
		),
	strUnitMeasure = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN ISNULL(ContractView.strItemUOM, 'Contract No not found!') 
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.strUnitMeasure, 'Inbound Shipment not found!')
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(strUnitMeasure, 'Transport not found!')  FROM tblICItemUOM LEFT JOIN tblICUnitMeasure ON tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId WHERE intItemUOMId = ReceiptItem.intUnitMeasureId)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN POView.strUOM
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
						THEN 1
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.dblItemUOMCF, 0)
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(dblUnitQty, 'Transport not found!')  FROM tblICItemUOM WHERE intItemUOMId = ReceiptItem.intUnitMeasureId)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN POView.dblItemUOMCF
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
						THEN (
							CASE WHEN ContractView.ysnLoad = 1 THEN ISNULL(ContractView.intNoOfLoad, 0)
								ELSE ISNULL(ContractView.dblDetailQuantity, 0) END
						)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.dblQuantity, 0)
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(dblOrderedQuantity, 0) FROM vyuTRTransportReceipt
						WHERE intTransportReceiptId = ReceiptItem.intSourceId)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL(POView.dblQtyOrdered, 0.00)
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
						THEN (
							CASE WHEN ContractView.ysnLoad = 1 THEN ISNULL(ContractView.intNoOfLoad, 0) - ISNULL(ContractView.dblBalance, 0)
								ELSE ISNULL(ContractView.dblDetailQuantity, 0) - ISNULL(ContractView.dblBalance, 0) END
						)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.dblReceivedQty, 0)
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN (SELECT ISNULL(dblReceivedQuantity, 0) FROM vyuTRTransportReceipt
						WHERE intTransportReceiptId = ReceiptItem.intSourceId)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL(POView.dblQtyReceived, 0.00)
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
						THEN LogisticsView.strContainerNumber
					ELSE NULL
					END
				)
			END
		)
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN vyuCTContractDetailView ContractView
	ON ContractView.intContractDetailId = ReceiptItem.intLineNo
		AND strReceiptType = 'Purchase Contract'
LEFT JOIN vyuLGShipmentContainerReceiptContracts LogisticsView
	ON LogisticsView.intShipmentContractQtyId = ReceiptItem.intSourceId
		AND intShipmentBLContainerId = ReceiptItem.intContainerId
		AND strReceiptType = 'Purchase Contract'
		AND intSourceType = 2
LEFT JOIN vyuPODetails POView
	ON POView.intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo
		AND strReceiptType = 'Purchase Order'