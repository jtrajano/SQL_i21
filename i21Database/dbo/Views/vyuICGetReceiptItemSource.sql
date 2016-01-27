CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intOrderId,
	Receipt.strReceiptType,
	strOrderNumber = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN ContractView.strContractNumber
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN POView.strPurchaseOrderNumber
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN TransferView.strTransferNo
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
				THEN (SELECT dtmDate FROM tblPOPurchase WHERE intPurchaseId = ReceiptItem.intOrderId)
			WHEN Receipt.strReceiptType = 'Transfer Order'
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
				THEN CAST(ISNULL(LogisticsView.intTrackingNumber, '')AS NVARCHAR(50))
			WHEN Receipt.intSourceType = 3 -- Transport
				THEN TransportView.strTransaction
			ELSE NULL
			END
		),
	strUnitMeasure = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 0 -- None
						THEN ContractView.strItemUOM
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN LogisticsView.strUnitMeasure
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN ItemUOM.strUnitMeasure
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN POView.strUOM
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN TransferView.strUnitMeasure
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
						THEN ItemUOM.dblUnitQty
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN POView.dblItemUOMCF
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN TransferView.dblItemUOMCF
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
							CASE WHEN (ContractView.ysnLoad = 1) THEN ISNULL(ContractView.intNoOfLoad, 0)
								ELSE ISNULL(ContractView.dblDetailQuantity, 0) END
						)
						 
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.dblQuantity, 0)
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN ISNULL(TransportView.dblOrderedQuantity, 0)
					ELSE NULL
					END
				)
			WHEN Receipt.strReceiptType = 'Purchase Order'
				THEN ISNULL(POView.dblQtyOrdered, 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Order'
				THEN ISNULL(TransferView.dblQuantity, 0.00)
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
							CASE WHEN (ContractView.ysnLoad = 1) THEN ISNULL(ContractView.intLoadReceived, 0)
								ELSE ISNULL(ContractView.dblDetailQuantity, 0) - ISNULL(ContractView.dblBalance, 0) END
						)
					WHEN Receipt.intSourceType = 1 -- Scale
						THEN 0
					WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN ISNULL(LogisticsView.dblReceivedQty, 0)
					WHEN Receipt.intSourceType = 3 -- Transport
						THEN ISNULL(TransportView.dblReceivedQuantity, 0)
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
	, ContractView.ysnLoad
	, ContractView.dblAvailableQty
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
LEFT JOIN vyuCTContractDetailView ContractView
	ON ContractView.intContractDetailId = ReceiptItem.intLineNo
		AND strReceiptType = 'Purchase Contract'
LEFT JOIN vyuLGShipmentContainerReceiptContracts LogisticsView
	ON LogisticsView.intShipmentContractQtyId = ReceiptItem.intSourceId
		AND intShipmentBLContainerId = ReceiptItem.intContainerId
		AND strReceiptType = 'Purchase Contract'
		AND intSourceType = 2
LEFT JOIN vyuTRTransportReceipt TransportView
	ON TransportView.intTransportReceiptId = ReceiptItem.intSourceId
		AND intSourceType = 3
LEFT JOIN vyuPODetails POView
	ON POView.intPurchaseId = ReceiptItem.intOrderId AND intPurchaseDetailId = ReceiptItem.intLineNo
		AND strReceiptType = 'Purchase Order'
LEFT JOIN vyuICGetInventoryTransferDetail TransferView
	ON TransferView.intInventoryTransferDetailId = ReceiptItem.intLineNo
		AND strReceiptType = 'Transfer Order'