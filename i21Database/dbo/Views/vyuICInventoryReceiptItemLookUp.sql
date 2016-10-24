CREATE VIEW [dbo].[vyuICInventoryReceiptItemLookUp]
	AS

SELECT	ReceiptItem.intInventoryReceiptId
		, ReceiptItem.intInventoryReceiptItemId
		, Item.strItemNo
		, strItemDescription = Item.strDescription
		, Item.strLotTracking
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, strUnitType = ItemUnitMeasure.strUnitType
		, SubLocation.strSubLocationName
		, strStorageLocationName = StorageLocation.strName
		, strGrade = Grade.strDescription
		, Item.intCommodityId
		, strWeightUOM = WeightUOM.strUnitMeasure
		, dblItemUOMConvFactor = ISNULL(ItemUOM.dblUnitQty, 0)
		, dblWeightUOMConvFactor = ISNULL(ItemWeightUOM.dblUnitQty, 0)
		, dblGrossMargin = (
			CASE	WHEN ISNULL(dblUnitRetail, 0) = 0 THEN 0
					ELSE ((ISNULL(dblUnitRetail, 0) - ISNULL(dblUnitCost, 0)) / dblUnitRetail) * 100 END
		)
		, Item.strLifeTimeType
		, Item.intLifeTime
		, strCostUOM = CostUOM.strUnitMeasure
		, dblCostUOMConvFactor = ISNULL(ItemCostUOM.dblUnitQty, 0)
		, strDiscountSchedule = DiscountSchedule.strDiscountId
		, strSubCurrency = CASE WHEN ReceiptItem.ysnSubCurrency = 1 THEN SubCurrency.strCurrency ELSE TransactionCurrency.strCurrency END

		, strOrderNumber =  (
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
			)

		, strSourceNumber = (
				CASE WHEN Receipt.intSourceType = 1 THEN -- Scale
					SCTicket.strTicketNumber 

				WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
					ISNULL(LogisticsView.strLoadNumber, '')

				WHEN Receipt.intSourceType = 3 -- Transport
					THEN ISNULL(TransportView_New.strTransaction, TransportView_Old.strTransaction) 

				WHEN Receipt.intSourceType = 4 -- Settle Storage
					THEN ISNULL(vyuGRStorageSearchView.strStorageTicketNumber, '') 					

				ELSE CAST(NULL AS NVARCHAR(50)) 
				END
			)
		, dtmDate = (
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
			)

		, strOrderUOM =  (
				CASE	WHEN Receipt.strReceiptType = 'Purchase Contract' THEN (
							CASE	WHEN Receipt.intSourceType = 0 THEN -- None
										ContractView.strItemUOM
									WHEN Receipt.intSourceType = 1 THEN -- Scale
										NULL
									WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
										LogisticsView.strUnitMeasure
									WHEN Receipt.intSourceType = 3 THEN -- Transport
										ItemUnitMeasure.strUnitMeasure
									ELSE 
										NULL
							END
						)
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN 
							POView.strUOM
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN 
							TransferView.strUnitMeasure
						WHEN Receipt.strReceiptType = 'Direct' THEN 
							NULL
						ELSE 
							NULL
				END
			)

		, dblOrdered = (
				CASE	WHEN Receipt.strReceiptType = 'Purchase Contract' THEN 
							CASE	WHEN Receipt.intSourceType = 0 THEN -- None
										CASE	WHEN (ContractView.ysnLoad = 1) THEN 
													ISNULL(ContractView.intNoOfLoad, 0)
												ELSE 
													ISNULL(ContractView.dblDetailQuantity, 0) 
										END
									WHEN Receipt.intSourceType = 1 THEN -- Scale
										0 
									WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
										ISNULL(LogisticsView.dblQuantity, 0)
									WHEN Receipt.intSourceType = 3 THEN -- Transport
										ISNULL(ISNULL(TransportView_New.dblOrderedQuantity, TransportView_Old.dblOrderedQuantity), 0) 
									ELSE 
										NULL
							END
						
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN 
							ISNULL(POView.dblQtyOrdered, 0.00)
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN 
							ISNULL(TransferView.dblQuantity, 0.00)
						WHEN Receipt.strReceiptType = 'Direct' THEN 
							0.00
						ELSE 0.00
				END
		)
		, dblReceived = (
				CASE	WHEN Receipt.strReceiptType = 'Purchase Contract' THEN
							CASE	WHEN Receipt.intSourceType = 0 THEN -- None
										CASE	WHEN (ContractView.ysnLoad = 1) THEN 
													ISNULL(ContractView.intLoadReceived, 0)
												ELSE ISNULL(ContractView.dblDetailQuantity, 0) - ISNULL(ContractView.dblBalance, 0) 
										END
									WHEN Receipt.intSourceType = 1 THEN -- Scale
										0
									WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
										ISNULL(LogisticsView.dblDeliveredQuantity, 0)
									WHEN Receipt.intSourceType = 3 THEN -- Transport
										ISNULL(ISNULL(TransportView_New.dblReceivedQuantity, TransportView_Old.dblReceivedQuantity), 0) 
									ELSE NULL
							END
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN 
							ISNULL(POView.dblQtyReceived, 0.00)
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN 
							0.00
						WHEN Receipt.strReceiptType = 'Direct' THEN 
							0.00
						ELSE 
							0.00
				END
		)
		, dblOrderUOMConvFactor = (
			CASE	WHEN Receipt.strReceiptType = 'Purchase Contract' THEN 
						CASE	WHEN Receipt.intSourceType = 0  THEN -- None
									1
								WHEN Receipt.intSourceType = 1 THEN -- Scale
									0
								WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
									ISNULL(LogisticsView.dblItemUOMCF, 0)
								WHEN Receipt.intSourceType = 3 THEN -- Transport
									ItemUOM.dblUnitQty
								ELSE 
									0
						END
						
					WHEN Receipt.strReceiptType = 'Purchase Order' THEN 
						POView.dblItemUOMCF
					WHEN Receipt.strReceiptType = 'Transfer Order' THEN 
						TransferView.dblItemUOMCF
					WHEN Receipt.strReceiptType = 'Direct' THEN 
						0
					ELSE 
						0
			END
		)
		, strContainer = LogisticsView.strContainerNumber
		, ContractView.ysnLoad
		, ContractView.dblAvailableQty
		, dblFranchise = ISNULL(LogisticsView.dblFranchise, 0.00)
		, dblContainerWeightPerQty = ISNULL(LogisticsView.dblContainerWeightPerQty, 0.00)
		, ContractView.strPricingType

FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId

		LEFT JOIN tblICItem Item 
			ON Item.intItemId = ReceiptItem.intItemId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
			ON SubLocation.intCompanyLocationSubLocationId = ReceiptItem.intSubLocationId
		LEFT JOIN tblICStorageLocation StorageLocation 
			ON StorageLocation.intStorageLocationId = ReceiptItem.intStorageLocationId
		LEFT JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
			AND ItemUOM.intItemId = ReceiptItem.intItemId
		LEFT JOIN tblICUnitMeasure ItemUnitMeasure  
			ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemWeightUOM 
			ON ItemWeightUOM.intItemUOMId = ReceiptItem.intWeightUOMId 
			AND ItemWeightUOM.intItemId = ReceiptItem.intItemId
		LEFT JOIN tblICUnitMeasure WeightUOM 
			ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM 
			ON ItemCostUOM.intItemUOMId = ReceiptItem.intCostUOMId 
			AND ItemCostUOM.intItemId = ReceiptItem.intItemId
		LEFT JOIN tblICUnitMeasure CostUOM 
			ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN tblICCommodityAttribute Grade 
			ON Grade.intCommodityAttributeId = ReceiptItem.intGradeId
		LEFT JOIN tblGRDiscountId DiscountSchedule 
			ON DiscountSchedule.intDiscountId = ReceiptItem.intDiscountSchedule
		LEFT JOIN tblSMCurrency SubCurrency 
			ON SubCurrency.intMainCurrencyId = Receipt.intCurrencyId
		LEFT JOIN tblSMCurrency TransactionCurrency
			ON TransactionCurrency.intCurrencyID = Receipt.intCurrencyId

		-- Integrations with the other modules: 
		-- 1. Purchase Order
		LEFT JOIN vyuPODetails POView
			ON POView.intPurchaseId = ReceiptItem.intOrderId 
			AND intPurchaseDetailId = ReceiptItem.intLineNo
			AND Receipt.strReceiptType = 'Purchase Order'

		-- 2. Contracts
		LEFT JOIN vyuCTContractDetailView ContractView
			ON ContractView.intContractDetailId = ReceiptItem.intLineNo
			AND Receipt.strReceiptType = 'Purchase Contract'

		-- 3. Inventory Transfer
		LEFT JOIN vyuICGetInventoryTransferDetail TransferView
			ON TransferView.intInventoryTransferDetailId = ReceiptItem.intLineNo
			AND Receipt.strReceiptType = 'Transfer Order'

		-- 4. Logistics
		LEFT JOIN vyuICLoadContainerReceiptContracts LogisticsView
			ON LogisticsView.intLoadDetailId = ReceiptItem.intSourceId
			AND intLoadContainerId = ReceiptItem.intContainerId
			AND Receipt.strReceiptType = 'Purchase Contract'
			AND Receipt.intSourceType = 2

		-- 5. Scale Tickets
		LEFT JOIN tblSCTicket SCTicket
			ON SCTicket.intTicketId = ReceiptItem.intSourceId
			AND Receipt.intSourceType = 1 -- Scale 

		-- 6. Transport Loads (New tables)
		LEFT JOIN vyuTRTransportReceipt_New TransportView_New
			ON TransportView_New.intTransportReceiptId = ReceiptItem.intSourceId
			AND Receipt.intSourceType = 3

		-- 7. Transport Loads (Old tables) 
		LEFT JOIN vyuTRTransportReceipt_Old TransportView_Old
			ON TransportView_Old.intTransportReceiptId = ReceiptItem.intSourceId
			AND Receipt.intSourceType = 3

		-- 8. Grain > Settle Storage 
		LEFT JOIN vyuGRStorageSearchView
			ON vyuGRStorageSearchView.intCustomerStorageId = ReceiptItem.intSourceId
				AND Receipt.intSourceType = 4