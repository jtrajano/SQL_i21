CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
	AS

SELECT 
	ReceiptItem.intInventoryReceiptId,
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intOrderId,
	Receipt.strReceiptType,
	Receipt.intSourceType,
	strSourceType = (
		CASE WHEN Receipt.intSourceType = 1 THEN 'Scale'
			WHEN Receipt.intSourceType = 2 THEN 'Inbound Shipment'
			WHEN Receipt.intSourceType = 3 THEN 'Transport'
			WHEN Receipt.intSourceType = 4 THEN 'Settle Storage'
			WHEN Receipt.intSourceType = 5 THEN 'Delivery Sheet'
			WHEN Receipt.intSourceType = 0 THEN 'None'
		END),
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
				THEN ISNULL(LogisticsView.strLoadNumber, '')
			WHEN Receipt.intSourceType = 3 -- Transport
				THEN LoadReceipt.strTransaction 
			WHEN Receipt.intSourceType = 4 -- Settle Storage
				THEN ISNULL(vyuGRStorageSearchView.strStorageTicketNumber, '') 
			WHEN Receipt.intSourceType = 5 -- Delivery Sheet
				THEN (SELECT strDeliverySheetNumber FROM tblSCDeliverySheet WHERE intDeliverySheetId = ReceiptItem.intSourceId) COLLATE Latin1_General_CI_AS
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
						THEN ISNULL(LoadReceipt.dblOrderedQuantity, 0) 
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
			CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN (
						CASE 
							WHEN Receipt.intSourceType = 0 THEN -- None
								CASE	
									WHEN (ContractView.ysnLoad = 1) THEN 
										ISNULL(ContractView.intLoadReceived, 0)
									ELSE 
										ISNULL(ContractView.dblDetailQuantity, 0) - ISNULL(ContractView.dblBalance, 0) 
								END
							WHEN Receipt.intSourceType = 1 -- Scale
								THEN 0
							WHEN Receipt.intSourceType = 2 -- Inbound Shipment
								THEN ISNULL(LogisticsView.dblDeliveredQuantity, 0)
							WHEN Receipt.intSourceType = 3 -- Transport
								THEN ISNULL(LoadReceipt.dblReceivedQuantity, 0) 
							ELSE NULL
						END
					)
				WHEN Receipt.strReceiptType = 'Purchase Order'
					THEN ISNULL(POView.dblQtyReceived, 0.00)
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN 0.00
				WHEN Receipt.strReceiptType = 'Direct'
					THEN 0.00
				WHEN Receipt.strReceiptType = 'Inventory Return' 
					THEN rtn.dblQtyReturned -- Show how much was received less the returns. 
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
	, dblFranchise =
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN LogisticsView.dblFranchise
					ELSE 0.00
					END
				)
			ELSE 0.00
			END
		)
	, dblContainerWeightPerQty =
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN LogisticsView.dblContainerWeightPerQty
					ELSE 0.00
					END
				)
			ELSE 0.00
			END
		)
	, intContainerWeightUOMId = 
		(
			CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
				THEN (
					CASE WHEN Receipt.intSourceType = 2 -- Inbound Shipment
						THEN LogisticsView.intWeightUOMId 
					ELSE 0.00
					END
				)
				ELSE NULL 
			END
		)
	, strFieldNo = 
		CASE Receipt.intSourceType
			-- None
			WHEN 0 THEN ContractFarm.strFieldNumber
			-- Scale
			WHEN 1 THEN ScaleFarm.strFieldNumber
			ELSE NULL 
		END
FROM tblICInventoryReceiptItem ReceiptItem
LEFT JOIN tblICInventoryReceipt Receipt 
	ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN vyuICGetItemUOM ItemUOM 
	ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
LEFT JOIN vyuCTCompactContractDetailView ContractView
	ON ContractView.intContractDetailId = ReceiptItem.intLineNo
	AND strReceiptType = 'Purchase Contract'
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = ContractView.intContractDetailId
LEFT JOIN tblEMEntityFarm ContractFarm ON ContractFarm.intFarmFieldId = ContractDetail.intFarmFieldId
LEFT JOIN tblSCTicket ticket ON ticket.intTicketId = ReceiptItem.intSourceId
LEFT JOIN tblEMEntityFarm ScaleFarm ON ScaleFarm.intFarmFieldId = ticket.intFarmFieldId
LEFT JOIN vyuLGLoadContainerLookup LogisticsView --LEFT JOIN vyuLGLoadContainerReceiptContracts LogisticsView
	ON LogisticsView.intLoadDetailId = CASE WHEN Receipt.intSourceType = 2 THEN ReceiptItem.intSourceId ELSE NULL END 
	AND intLoadContainerId = ReceiptItem.intContainerId
	AND strReceiptType = 'Purchase Contract'
	AND Receipt.intSourceType = 2
OUTER APPLY (
	SELECT	LoadHeader.strTransaction
			, dblOrderedQuantity  = CASE WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Net' THEN LoadReceipt.dblNet
										WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Gross' THEN LoadReceipt.dblGross
										WHEN ISNULL(LoadSchedule.dblQuantity,0) != 0 THEN LoadSchedule.dblQuantity END
			, dblReceivedQuantity = CASE WHEN SupplyPoint.strGrossOrNet = 'Gross' THEN LoadReceipt.dblGross
										WHEN SupplyPoint.strGrossOrNet = 'Net' THEN LoadReceipt.dblNet END

	FROM	tblTRLoadReceipt LoadReceipt LEFT JOIN tblTRLoadHeader LoadHeader
				ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId	
			LEFT JOIN tblTRSupplyPoint SupplyPoint
				ON SupplyPoint.intSupplyPointId = LoadReceipt.intSupplyPointId
			LEFT JOIN tblLGLoadDetail LoadSchedule
				ON LoadSchedule.intLoadDetailId = LoadReceipt.intLoadDetailId
	WHERE	LoadReceipt.intLoadReceiptId = CASE WHEN Receipt.intSourceType = 3 THEN ReceiptItem.intSourceId ELSE NULL END 
			AND Receipt.intSourceType = 3
) LoadReceipt
LEFT JOIN vyuPODetails POView
	ON POView.intPurchaseId = ReceiptItem.intOrderId 
	AND intPurchaseDetailId = ReceiptItem.intLineNo
	AND Receipt.strReceiptType = 'Purchase Order'
LEFT JOIN vyuICGetInventoryTransferDetail TransferView
	ON TransferView.intInventoryTransferDetailId = ReceiptItem.intLineNo
	AND Receipt.strReceiptType = 'Transfer Order'
OUTER APPLY (
	SELECT	strStorageTicketNumber
	FROM	tblGRCustomerStorage
	WHERE	intCustomerStorageId = ReceiptItem.intSourceId 
			AND Receipt.intSourceType = 4
) vyuGRStorageSearchView
OUTER APPLY (
	SELECT	dblQtyReturned = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId				
	WHERE	r.intInventoryReceiptId = Receipt.intSourceInventoryReceiptId
			AND ri.intInventoryReceiptItemId = ReceiptItem.intSourceInventoryReceiptItemId
			AND Receipt.strReceiptType = 'Inventory Return'
) rtn

