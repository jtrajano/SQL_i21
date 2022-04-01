CREATE VIEW [dbo].[vyuICGetReceiptItemSourceSearch]
AS

SELECT 
	  ReceiptItem.intInventoryReceiptId
	, ReceiptItem.intInventoryReceiptItemId
	, ReceiptItem.intOrderId
	, Receipt.strReceiptType
	, Receipt.intSourceType
	, dblAvailableQty = NULL
	, [Contract].ysnLoad
	, [Contract].strERPPONumber
	, [Contract].strERPItemNumber
	, [Contract].strOrigin
	, [Contract].strPurchasingGroup
	, [Contract].strINCOShipTerm
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
			WHEN Receipt.intSourceType = 9 THEN 'Transfer Shipment'
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
FROM tblICInventoryReceiptItem ReceiptItem
	INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
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
	LEFT OUTER JOIN (
		SELECT
			  ContractDetail.intContractDetailId
			, [ContractHeader].strContractNumber
			, [ContractHeader].dtmContractDate
			, [ContractHeader].ysnLoad
			, [ContractHeader].intNoOfLoad
			, [ContractDetail].dblQuantity
			, [ContractDetail].dblBalance
			, [ContractDetail].strERPPONumber
			, [ContractDetail].strERPItemNumber
			, strOrigin = ISNULL(CountryContract.strCountry,CountryOrigin.strCountry)
			, strPurchasingGroup = PurchasingGroup.strName
			, strINCOShipTerm = ContractBasis.strContractBasis
			, [ContractDetail].intContractSeq
			, [ContractDetail].intFarmFieldId
			, ContractUnitMeasure.strUnitMeasure
		FROM tblCTContractDetail ContractDetail 
			INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
			INNER JOIN tblICItem Item ON Item.intItemId = ContractDetail.intItemId
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
			, LogisticsLookup.strUnitMeasure
			, LogisticsLookup.strContainerNumber
		FROM vyuICLoadContainersSearch LogisticsLookup
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
	OUTER APPLY (
		SELECT t.strTransferNo, t.strSourceNumber, t.strUnitMeasure
		FROM vyuICGetInventoryTransferDetail t
		WHERE t.intInventoryTransferDetailId = ReceiptItem.intInventoryTransferDetailId
		AND Receipt.strReceiptType = 'Transfer Order'
	) InventoryTransfer
	OUTER APPLY (
		SELECT LoadHeader.strTransaction
		FROM tblTRLoadReceipt LoadReceipt
			INNER JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId	
		WHERE LoadReceipt.intLoadReceiptId = CASE WHEN Receipt.intSourceType = 3 THEN ReceiptItem.intSourceId ELSE NULL END
			AND Receipt.intSourceType = 3
	) LoadReceipt