CREATE VIEW [dbo].[vyuICGetReceiptItemSource]
AS

SELECT 
	  ReceiptItem.intInventoryReceiptId
	, ReceiptItem.intInventoryReceiptItemId
	, intOrderId = 
		CASE 
			WHEN Receipt.intSourceType = 3 THEN COALESCE(ReceiptItem.intOrderId, LoadReceipt.intLoadHeaderId) 
			ELSE COALESCE(ReceiptItem.intOrderId, ReceiptItem.intSourceId)
		END 
	, Receipt.strReceiptType
	, Receipt.intSourceType
	, dblAvailableQty = [Contract].dblAvailableQty
	, ysnLoad = [Contract].ysnLoad
	, strERPPONumber = [Contract].strERPPONumber
	, strERPItemNumber = [Contract].strERPItemNumber
	, strOrigin =[Contract].strOrigin
	, strPurchasingGroup = [Contract].strPurchasingGroup
	, strINCOShipTerm = [Contract].strINCOShipTerm
	, strSourceType = 
		CASE 
			WHEN Receipt.intSourceType = 0 THEN 'None'
			WHEN Receipt.intSourceType = 1 THEN 'Scale'
			WHEN Receipt.intSourceType = 2 THEN 'Inbound Shipment'
			WHEN Receipt.intSourceType = 3 THEN 'Transport'
			WHEN Receipt.intSourceType = 4 THEN 'Settle Storage'
			WHEN Receipt.intSourceType = 5 THEN 'Delivery Sheet'
			WHEN Receipt.intSourceType = 6 THEN 'Purchase Order'
			WHEN Receipt.intSourceType = 7 THEN 'Store'
		END COLLATE Latin1_General_CI_AS
	, strOrderNumber = 
		CASE
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN [Contract].strContractNumber
			WHEN Receipt.strReceiptType = 'Purchase order' THEN PurchaseOrder.strPurchaseOrderNumber
			WHEN Receipt.strReceiptType = 'Transfer Order' THEN InventoryTransfer.strTransferNo
			ELSE NULL
		END COLLATE Latin1_General_CI_AS
	, dtmDate = 
		CASE
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN [Contract].dtmContractDate
			WHEN Receipt.strReceiptType = 'Purchase Order' THEN
				CASE WHEN PurchaseOrderHeader.intPurchaseId = ReceiptItem.intSourceId THEN PurchaseOrderHeader.dtmDate ELSE NULL END
			ELSE NULL
		END
	, strSourceNumber =
		CASE
			-- Scale
			WHEN Receipt.intSourceType = 1 THEN
				CASE WHEN Receipt.strReceiptType = 'Transfer Order' THEN InventoryTransfer.strSourceNumber ELSE Ticket.strTicketNumber END
			-- Inbound Shipment
			WHEN Receipt.intSourceType = 2 THEN ISNULL(Logistics.strLoadNumber, '')
			-- Transport
			WHEN Receipt.intSourceType = 3 THEN LoadReceipt.strTransaction
			-- Settle Storage
			WHEN Receipt.intSourceType = 4 THEN ISNULL(GrainStorage.strStorageTicketNumber, '')
			-- Delivery Sheet
			WHEN Receipt.intSourceType = 5 THEN DeliverySheet.strDeliverySheetNumber
			-- Purchase Order
			WHEN Receipt.intSourceType = 6 THEN
				CASE WHEN PurchaseOrder.intPurchaseId = ReceiptItem.intSourceId THEN PurchaseOrder.strPurchaseOrderNumber ELSE NULL END
			ELSE NULL
		END
	, dblOrdered =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					 -- None or Purchase Order
					WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 6 THEN
						CASE WHEN [Contract].ysnLoad = 1 THEN ISNULL([Contract].intNoOfLoad, 0) ELSE ISNULL([Contract].dblQuantity, 0) END
					-- Scale
					WHEN Receipt.intSourceType = 1 THEN 0.00
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN ISNULL(Logistics.dblQuantity, 0.00)
					-- Transport
					WHEN Receipt.intSourceType = 3 THEN ISNULL(LoadReceipt.dblOrderedQuantity, 0.00)
					ELSE NULL
				END
			WHEN Receipt.strReceiptType = 'Purchase Order' THEN ISNULL(PurchaseOrder.dblQtyOrdered, 0.00)
			WHEN Receipt.strReceiptType = 'Transfer Order' THEN ISNULL(InventoryTransfer.dblQuantity, 0.00)
			ELSE 0.00
		END
	, dblReceived =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					 -- None or Purchase Order
					WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 6 THEN
						CASE WHEN [Contract].ysnLoad = 1 THEN ISNULL([Contract].intLoadReceived, 0) ELSE ISNULL([Contract].dblQuantity, 0.00) - ISNULL([Contract].dblBalance, 0.00) END
					-- Scale
					WHEN Receipt.intSourceType = 1 THEN 0.00
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN ISNULL(Logistics.dblDeliveredQuantity, 0.00)
					-- Transport
					WHEN Receipt.intSourceType = 3 THEN LoadReceipt.dblReceivedQuantity
					ELSE NULL
				END
			WHEN Receipt.strReceiptType = 'Purchase Order' THEN ISNULL(PurchaseOrder.dblQtyReceived, 0.00)
			WHEN Receipt.strReceiptType = 'Inventory Return' THEN InventoryReturn.dblQtyReturned
			ELSE 0.00
		END
	, strUnitMeasure =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- None or Purchase Order
					WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 6 THEN [Contract].strUnitMeasure
					-- Scale
					WHEN Receipt.intSourceType = 1 THEN NULL
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.strUnitMeasure
					-- Transport
					WHEN Receipt.intSourceType = 3 THEN 'Transport'
					ELSE NULL
				END
			WHEN Receipt.strReceiptType = 'Purchase Order' THEN PurchaseOrder.strUOM
			WHEN Receipt.strReceiptType = 'Transfer Order' THEN InventoryTransfer.strUnitMeasure
			ELSE NULL
		END
	, dblUnitQty =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- None
					WHEN Receipt.intSourceType = 0 THEN 1.0
					-- Scale
					WHEN Receipt.intSourceType = 1 THEN 0.0
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN ISNULL(Logistics.dblItemUOMCF, 0)
					-- Transport
					WHEN Receipt.intSourceType = 3 THEN 0.0
					-- Purchase Order
					WHEN Receipt.intSourceType = 6 THEN PurchaseOrder.dblItemUOMCF
					ELSE NULL
				END
			WHEN Receipt.strReceiptType = 'Purchase Order' THEN PurchaseOrder.dblItemUOMCF
			WHEN Receipt.strReceiptType = 'Transfer Order' THEN InventoryTransfer.dblItemUOMCF
			ELSE NULL
		END
	, strFieldNo = 
		CASE Receipt.intSourceType
			-- None
			WHEN 0 THEN ContractFarm.strLocationName
			-- Scale
			WHEN 1 THEN ScaleFarm.strFieldNumber
			ELSE NULL 
		END			
	, intContractSeq =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN [Contract].intContractSeq
			-- Inventory Return
			WHEN Receipt.strReceiptType = 'Inventory Return' THEN
				CASE
					-- Purchase contract
					WHEN InventoryReturn.strReceiptType = 'Purchase Contract' THEN [Contract].intContractSeq
					ELSE NULL 
				END
			ELSE NULL
		END
	, intContainerWeightUOMId =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.intWeightUOMId
					ELSE 0.00
				END
			ELSE NULL
		END
	, dblContainerWeightPerQty =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.dblContainerWeightPerQty
					ELSE 0.00
				END
			ELSE NULL
		END
	, dblFranchise =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.dblFranchise
					ELSE 0.00
				END
			ELSE NULL
		END
	, strContainer =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.strContainerNumber
					ELSE NULL
				END
			ELSE NULL
		END
	, strMarkings =
		CASE
			-- Purchase Contract
			WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
				CASE
					-- Inbound Shipment
					WHEN Receipt.intSourceType = 2 THEN Logistics.strMarks
					ELSE NULL
				END
			ELSE NULL
		END
FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	OUTER APPLY (
		SELECT dblQtyReturned = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
			, r.strReceiptType
			,r.strReceiptNumber
		FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId				
		WHERE r.intInventoryReceiptId = Receipt.intSourceInventoryReceiptId
			AND ri.intInventoryReceiptItemId = ReceiptItem.intSourceInventoryReceiptItemId
			AND Receipt.strReceiptType = 'Inventory Return'
	) InventoryReturn
	LEFT OUTER JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
	LEFT OUTER JOIN (
		SELECT
			  ContractDetail.intContractDetailId
			, [ContractHeader].strContractNumber
			, [ContractHeader].dtmContractDate
			, [ContractHeader].ysnLoad
			, [ContractHeader].intNoOfLoad
			, [ContractDetail].dblQuantity
			, intLoadReceived = CAST(ISNULL([ContractDetail].intNoOfLoad,0) - ISNULL([ContractDetail].dblBalanceLoad,0) AS INT)
			, [ContractDetail].dblBalance
			, [ContractDetail].strERPPONumber
			, [ContractDetail].strERPItemNumber
			, strOrigin = ISNULL(CountryContract.strCountry,CountryOrigin.strCountry)
			, strPurchasingGroup = PurchasingGroup.strName
			, strINCOShipTerm = ContractBasis.strContractBasis
			, [ContractDetail].intContractSeq
			, dblAvailableQty = ISNULL([ContractDetail].dblBalance,0) - ISNULL([ContractDetail].dblScheduleQty,0)
			, [ContractDetail].intFarmFieldId
			, ContractUnitMeasure.strUnitMeasure
		FROM tblCTContractDetail ContractDetail 
			INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
			LEFT OUTER JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
			LEFT OUTER JOIN tblICCommodityAttribute CommodityAttribute ON CommodityAttribute.intCommodityAttributeId = Item.intOriginId
				AND	CommodityAttribute.strType = 'Origin'	
			LEFT OUTER JOIN tblSMCountry CountryOrigin ON CountryOrigin.intCountryID = CommodityAttribute.intCountryID
			LEFT OUTER JOIN tblICItemContract ItemContract ON ItemContract.intItemContractId = ContractDetail.intItemContractId
			LEFT OUTER JOIN tblSMCountry CountryContract ON CountryContract.intCountryID = ItemContract.intCountryId
			LEFT OUTER JOIN tblSMPurchasingGroup PurchasingGroup ON PurchasingGroup.intPurchasingGroupId = ContractDetail.intPurchasingGroupId
			LEFT OUTER JOIN tblCTContractBasis ContractBasis ON ContractBasis.intContractBasisId = ContractHeader.intContractBasisId
			LEFT OUTER JOIN tblICItemUOM ContractItemUOM ON ContractItemUOM.intItemUOMId = ContractDetail.intItemUOMId
			LEFT OUTER JOIN tblICUnitMeasure ContractUnitMeasure ON ContractUnitMeasure.intUnitMeasureId = ContractItemUOM.intUnitMeasureId
	) [Contract] ON [Contract].intContractDetailId = ReceiptItem.intLineNo
		AND Receipt.strReceiptType = 'Purchase Contract'
	LEFT OUTER JOIN tblEMEntityLocation ContractFarm ON ContractFarm.intEntityLocationId = [Contract].intFarmFieldId
	LEFT OUTER JOIN tblSCTicket Ticket ON Ticket.intTicketId = ReceiptItem.intSourceId AND Receipt.intSourceType = 1
	LEFT OUTER JOIN tblEMEntityFarm ScaleFarm ON ScaleFarm.intFarmFieldId = Ticket.intFarmFieldId
	LEFT OUTER JOIN vyuPODetails PurchaseOrder ON PurchaseOrder.intPurchaseId = ReceiptItem.intOrderId
		AND PurchaseOrder.intPurchaseDetailId = ReceiptItem.intLineNo
		AND Receipt.strReceiptType = 'Purchase Order'
	LEFT OUTER JOIN tblPOPurchase PurchaseOrderHeader ON PurchaseOrderHeader.intPurchaseId = PurchaseOrder.intPurchaseId
	OUTER APPLY (
		SELECT
			  LogisticsLookup.strLoadNumber
			, LogisticsLookup.dblQuantity
			, LogisticsLookup.dblDeliveredQuantity
			, LogisticsLookup.strUnitMeasure
			, LogisticsLookup.dblItemUOMCF
			, LogisticsLookup.intWeightUOMId
			, LogisticsLookup.dblContainerWeightPerQty
			, LogisticsLookup.dblFranchise
			, LogisticsLookup.strContainerNumber
			, LogisticsLookup.strMarks
		FROM vyuICLoadContainers LogisticsLookup
		WHERE LogisticsLookup.intLoadDetailId = ReceiptItem.intSourceId 
			AND LogisticsLookup.intLoadContainerId = ReceiptItem.intContainerId
			AND Receipt.intSourceType = 2
			AND (Receipt.strReceiptType = 'Purchase Contract'
				OR (Receipt.strReceiptType = 'Inventory Return'
					AND InventoryReturn.strReceiptType = 'Purchase Contract'))
	) Logistics
	OUTER APPLY (
		SELECT strDeliverySheetNumber 
		FROM tblSCDeliverySheet 
		WHERE intDeliverySheetId = ReceiptItem.intSourceId 
			AND Receipt.intSourceType = 5
	) DeliverySheet
	OUTER APPLY (
		SELECT strStorageTicketNumber
		FROM tblGRCustomerStorage
		WHERE intCustomerStorageId = ReceiptItem.intSourceId 
			AND Receipt.intSourceType = 4
	) GrainStorage
	--LEFT JOIN vyuICGetInventoryTransferDetail InventoryTransfer ON InventoryTransfer.intInventoryTransferDetailId = ReceiptItem.intInventoryTransferDetailId
	--	AND Receipt.strReceiptType = 'Transfer Order'
	LEFT OUTER JOIN (
		SELECT
			  td.intInventoryTransferDetailId
			, strTransferNo = t.strTransferNo
			, strSourceNumber = CASE t.intSourceType
				WHEN 1 THEN sourceTicket.strSourceNumber 
				WHEN 2 THEN LGShipmentSource.strSourceNumber
				WHEN 3 THEN transportSource.strSourceNumber 
				ELSE NULL END
			, strUnitMeasure = M.strUnitMeasure
			, dblQuantity = td.dblQuantity
			, dblItemUOMCF = ItemUOM.dblUnitQty
		FROM tblICInventoryTransfer t
			INNER JOIN tblICInventoryTransferDetail td ON td.intInventoryTransferId = t.intInventoryTransferId
			INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = td.intItemUOMId
			INNER JOIN tblICUnitMeasure M ON M.intUnitMeasureId = ItemUOM.intUnitMeasureId
			OUTER APPLY (
				SELECT TOP 1 strSourceNumber = s1.strTicketNumber
				FROM tblSCTicket s1
				WHERE s1.intTicketId = td.intSourceId
					AND t.intSourceType = 1
			) sourceTicket
			OUTER APPLY (
				SELECT TOP 1 strSourceNumber = CAST(ISNULL(s2.intTrackingNumber, 'Inbound Shipment not found!') AS NVARCHAR(50))
				FROM tblLGShipment s2
				WHERE s2.intShipmentId = td.intSourceId
					AND t.intSourceType = 2
			) LGShipmentSource
			OUTER APPLY (
				SELECT TOP 1 strSourceNumber = CAST(ISNULL(s3header.strTransaction, 'Transport not found!') AS NVARCHAR(50))
				FROM tblTRLoadReceipt s3
					INNER JOIN tblTRLoadHeader s3header ON s3header.intLoadHeaderId = s3.intLoadHeaderId
				WHERE s3.intLoadReceiptId = td.intSourceId
					AND t.intSourceType = 3
			) transportSource

	) InventoryTransfer ON InventoryTransfer.intInventoryTransferDetailId = (COALESCE(ReceiptItem.intInventoryTransferDetailId, ReceiptItem.intOrderId))
		AND Receipt.strReceiptType = 'Transfer Order'
	OUTER APPLY (
		SELECT
			  LoadHeader.intLoadHeaderId
			, LoadHeader.strTransaction
			, dblOrderedQuantity = 
				CASE
					WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Net' THEN LoadReceipt.dblNet
					WHEN ISNULL(LoadSchedule.dblQuantity,0) = 0 AND SupplyPoint.strGrossOrNet = 'Gross' THEN LoadReceipt.dblGross
					WHEN ISNULL(LoadSchedule.dblQuantity,0) != 0 THEN LoadSchedule.dblQuantity
				END
			, dblReceivedQuantity =
				CASE WHEN SupplyPoint.strGrossOrNet = 'Gross' THEN LoadReceipt.dblGross
					WHEN SupplyPoint.strGrossOrNet = 'Net' THEN LoadReceipt.dblNet
				END
		FROM tblTRLoadReceipt LoadReceipt
			LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId	
			LEFT JOIN tblTRSupplyPoint SupplyPoint ON SupplyPoint.intSupplyPointId = LoadReceipt.intSupplyPointId
			LEFT JOIN tblLGLoadDetail LoadSchedule ON LoadSchedule.intLoadDetailId = LoadReceipt.intLoadDetailId
		WHERE LoadReceipt.intLoadReceiptId =
				CASE
					WHEN Receipt.intSourceType = 3 THEN ReceiptItem.intSourceId ELSE NULL
				END
			AND Receipt.intSourceType = 3
	) LoadReceipt