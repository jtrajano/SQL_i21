CREATE VIEW [dbo].[vyuICInventoryReceiptItemLookUp]
AS

SELECT	ReceiptItem.intInventoryReceiptId
		, ReceiptItem.intInventoryReceiptItemId
		, Item.strItemNo
		, strItemDescription = Item.strDescription
		, Item.strLotTracking
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, intItemUOMId = ItemUnitMeasure.intUnitMeasureId
		, intItemUOMDecimalPlaces = ItemUnitMeasure.intDecimalPlaces
		, strUnitType = ItemUnitMeasure.strUnitType
		, SubLocation.strSubLocationName
		, strStorageLocationName = StorageLocation.strName
		, strGrade = Grade.strDescription
		, strWarehouseRefNo = ReceiptItem.strWarehouseRefNo
		, Item.intCommodityId
		, strWeightUOM = WeightUOM.strUnitMeasure
		, intWeightUnitMeasureId = WeightUOM.intUnitMeasureId
		, intWeightUOMId = ReceiptItem.intWeightUOMId
		, ItemLocation.ysnStorageUnitRequired
		, dblItemUOMConvFactor = ISNULL(ItemUOM.dblUnitQty, 0)
		, dblWeightUOMConvFactor = ISNULL(ItemWeightUOM.dblUnitQty, 0)
		, dblGrossMargin = (
			CASE	WHEN ISNULL(dblUnitRetail, 0) = 0 THEN 0
					ELSE ((ISNULL(dblUnitRetail, 0) - ISNULL(ReceiptItem.dblUnitCost, 0)) / dblUnitRetail) * 100 END
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
				WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
					CASE	WHEN rtn.strReceiptType = 'Purchase Contract' 
								THEN ContractView.strContractNumber							
							WHEN rtn.strReceiptType = 'Purchase Order'
								THEN POView.strPurchaseOrderNumber
							WHEN rtn.strReceiptType = 'Transfer Order'
								THEN TransferView.strTransferNo
							WHEN rtn.strReceiptType = 'Direct'
								THEN rtn.strReceiptNumber 
							ELSE 
								NULL 
					END 
				ELSE NULL
				END
			)

		, strSourceNumber = (
				CASE WHEN Receipt.intSourceType = 1 THEN -- Scale
					SCTicket.strTicketNumber 

				WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
					ISNULL(LogisticsView.strLoadNumber, '')

				WHEN Receipt.intSourceType = 3 -- Transport
					THEN LoadReceipt.strTransaction 

				WHEN Receipt.intSourceType = 4 -- Settle Storage
					THEN ISNULL(GrainStorageView.strStorageTicketNumber, '') 					

				WHEN Receipt.intSourceType = 5
					THEN SCDeliverySheet.strDeliverySheetNumber COLLATE Latin1_General_CI_AS
				WHEN Receipt.intSourceType = 6
					THEN PCOView.strPurchaseOrderNumber
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
							CASE	WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 1 OR Receipt.intSourceType = 6 THEN -- None
                                        CASE WHEN ContractView.ysnLoad = 1 
												THEN 'Load' 
											ELSE ContractView.strItemUOM 
										END
									--WHEN Receipt.intSourceType = 1 THEN -- Scale
									--	NULL
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
							CASE	WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 1 OR Receipt.intSourceType = 6 THEN -- None
										CASE	WHEN (ContractView.ysnLoad = 1) THEN 
													ISNULL(ContractView.intNoOfLoad, 0)
												ELSE 
													ISNULL(ContractView.dblDetailQuantity, 0) 
										END
									--WHEN Receipt.intSourceType = 1 THEN -- Scale
									--	0 
									WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
										ISNULL(LogisticsView.dblQuantity, 0)
									WHEN Receipt.intSourceType = 3 THEN -- Transport
										ISNULL(LoadReceipt.dblOrderedQuantity, 0) 
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
							CASE	WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 1 OR Receipt.intSourceType = 6 THEN -- None
										CASE	WHEN (ContractView.ysnLoad = 1) THEN 
													ISNULL(ContractView.intLoadReceived, 0)
												ELSE ISNULL(ContractView.dblDetailQuantity, 0) - ISNULL(ContractView.dblBalance, 0) 
										END
									--WHEN Receipt.intSourceType = 1 THEN -- Scale
									--	0
									WHEN Receipt.intSourceType = 2 THEN -- Inbound Shipment
										ISNULL(LogisticsView.dblDeliveredQuantity, 0)
									WHEN Receipt.intSourceType = 3 THEN -- Transport
										ISNULL(LoadReceipt.dblGross, 0) 
									ELSE NULL
							END
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN 
							ISNULL(POView.dblQtyReceived, 0.00)
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN 
							0.00
						WHEN Receipt.strReceiptType = 'Direct' THEN 
							0.00
						WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
							rtn.dblQtyReturned -- Show how much was received less the returns. 
						ELSE 
							0.00
				END
		)
		, dblOrderUOMConvFactor = (
			CASE	WHEN Receipt.strReceiptType = 'Purchase Contract' THEN 
						CASE	WHEN Receipt.intSourceType = 0 OR Receipt.intSourceType = 6 THEN -- None
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
		, ItemLocation.intLocationId
		, intShipToLocationId = Receipt.intLocationId
		, strContainer = LogisticsView.strContainerNumber
		, ContractView.ysnLoad
		, ContractView.dblAvailableQty
		, ContractView.dblQuantityPerLoad
		, dblFranchise = ISNULL(LogisticsView.dblFranchise, 0.00)
		, dblContainerWeightPerQty = ISNULL(LogisticsView.dblContainerWeightPerQty, 0.00)
		, ContractView.strPricingType
		, strTaxGroup = SMTaxGroup.strTaxGroup
		, strForexRateType = forexType.strCurrencyExchangeRateType
		, intContainerWeightUOMId = LogisticsView.intWeightUOMId
		, dblContainerWeightUOMConvFactor = LogisticsView.dblWeightUOMConvFactor
		, Item.ysnLotWeightsRequired
		, intContractSeq = (
				CASE WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN ContractView.intContractSeq
				--WHEN Receipt.strReceiptType = 'Purchase Order'
				--	THEN POView.strPurchaseOrderNumber
				--WHEN Receipt.strReceiptType = 'Transfer Order'
				--	THEN TransferView.strTransferNo
				--WHEN Receipt.strReceiptType = 'Direct'
				--	THEN NULL
				WHEN Receipt.strReceiptType = 'Inventory Return' THEN 
					CASE	WHEN rtn.strReceiptType = 'Purchase Contract' 
								THEN ContractView.intContractSeq							
							--WHEN rtn.strReceiptType = 'Purchase Order'
							--	THEN POView.strPurchaseOrderNumber
							--WHEN rtn.strReceiptType = 'Transfer Order'
							--	THEN TransferView.strTransferNo
							--WHEN rtn.strReceiptType = 'Direct'
							--	THEN rtn.strReceiptNumber 
							ELSE 
								NULL 
					END 
				ELSE NULL
				END
			)

FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN tblSMCurrencyExchangeRateType forexType
			ON ReceiptItem.intForexRateTypeId = forexType.intCurrencyExchangeRateTypeId
		LEFT JOIN tblICItem Item 
			ON Item.intItemId = ReceiptItem.intItemId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
			ON SubLocation.intCompanyLocationSubLocationId = ReceiptItem.intSubLocationId
		LEFT JOIN tblICStorageLocation StorageLocation 
			ON StorageLocation.intStorageLocationId = ReceiptItem.intStorageLocationId
		LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = Receipt.intLocationId AND ItemLocation.intItemId = Item.intItemId
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
		LEFT JOIN tblSMTaxGroup SMTaxGroup
			ON SMTaxGroup.intTaxGroupId = ReceiptItem.intTaxGroupId
		OUTER APPLY (
			SELECT	dblQtyReturned = ri.dblOpenReceive - ISNULL(ri.dblQtyReturned, 0) 
					,r.strReceiptType
					,r.strReceiptNumber
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId				
			WHERE	r.intInventoryReceiptId = Receipt.intSourceInventoryReceiptId
					AND ri.intInventoryReceiptItemId = ReceiptItem.intSourceInventoryReceiptItemId
					AND Receipt.strReceiptType = 'Inventory Return'
		) rtn

		-- Integrations with the other modules: 
		-- 1. Purchase Order
		OUTER APPLY (
			SELECT	strPurchaseOrderNumber
					,strUOM
					,dblQtyOrdered
					,dblQtyReceived
					,dblItemUOMCF					
			FROM	vyuPODetails POView
			WHERE	POView.intPurchaseId = ReceiptItem.intOrderId 
					AND intPurchaseDetailId = ReceiptItem.intLineNo
					AND (
						Receipt.strReceiptType = 'Purchase Order'
						OR (
							Receipt.strReceiptType = 'Inventory Return'
							AND rtn.strReceiptType = 'Purchase Order'
						)
					)	
		) POView

		-- 2. Contracts
		OUTER APPLY (
			SELECT	strContractNumber
					,dtmContractDate
					,strItemUOM
					,ysnLoad
					,intNoOfLoad
					,dblDetailQuantity
					,intLoadReceived
					,dblQuantityPerLoad
					,dblBalance
					,dblAvailableQty
					,strPricingType
					,intContractSeq
			FROM	vyuCTCompactContractDetailView ContractView
			WHERE	ContractView.intContractDetailId = ReceiptItem.intLineNo
					AND (
						Receipt.strReceiptType = 'Purchase Contract'
						OR (
							Receipt.strReceiptType = 'Inventory Return'
							AND rtn.strReceiptType = 'Purchase Contract'
						)
					)		
		) ContractView

		-- 3. Inventory Transfer
		OUTER APPLY (
			SELECT	strTransferNo
					,strUnitMeasure
					,dblQuantity
					,dblItemUOMCF
			FROM	vyuICGetInventoryTransferDetail TransferView
			WHERE	TransferView.intInventoryTransferDetailId = ReceiptItem.intLineNo
					AND (
						Receipt.strReceiptType = 'Transfer Order'
						OR (
							Receipt.strReceiptType = 'Inventory Return'
							AND rtn.strReceiptType = 'Transfer Order'
						)
					)
		) TransferView

		-- 4. Logistics
		OUTER APPLY (
			SELECT	* 
			FROM	vyuLGLoadContainerLookup LogisticsView --LEFT JOIN vyuLGLoadContainerReceiptContracts LogisticsView
			WHERE	LogisticsView.intLoadDetailId = ReceiptItem.intSourceId 
					AND intLoadContainerId = ReceiptItem.intContainerId
					AND Receipt.intSourceType = 2
					AND (
						Receipt.strReceiptType = 'Purchase Contract'
						OR (
							Receipt.strReceiptType = 'Inventory Return'
							AND rtn.strReceiptType = 'Purchase Contract'
						)
					)
		) LogisticsView

		-- 5. Scale Tickets
		OUTER APPLY (
			SELECT	strTicketNumber
			FROM	tblSCTicket SCTicket
			WHERE	SCTicket.intTicketId = ReceiptItem.intSourceId 
					AND Receipt.intSourceType = 1 -- Scale 		
		) SCTicket

		-- 6. Transport Loads (New tables)
		OUTER APPLY (
			SELECT	strTransaction
					,dblOrderedQuantity
					,dblGross
			FROM	vyuTRGetTransportLoadReceipt LoadReceipt --vyuTRGetLoadReceipt LoadReceipt
			WHERE	LoadReceipt.intLoadReceiptId = ReceiptItem.intSourceId 
					AND Receipt.intSourceType = 3		
		) LoadReceipt

		-- 7. Grain > Settle Storage 
		OUTER APPLY (
			SELECT	strStorageTicketNumber
			FROM	tblGRCustomerStorage
			WHERE	intCustomerStorageId = ReceiptItem.intSourceId 
					AND Receipt.intSourceType = 4
		) GrainStorageView

		-- 8. Delivery Sheets
		OUTER APPLY (
			SELECT	strDeliverySheetNumber
			FROM	tblSCDeliverySheet SCDeliverySheet
			WHERE	SCDeliverySheet.intDeliverySheetId = ReceiptItem.intSourceId 
					AND Receipt.intSourceType = 5 -- Delivery Sheets 		
		) SCDeliverySheet

		-- 9. Purchase Order from Contracts
		OUTER APPLY (
			SELECT	strPurchaseOrderNumber				
			FROM	vyuPODetails POView
			WHERE	POView.intPurchaseId = ReceiptItem.intSourceId 
					--AND intPurchaseDetailId = ReceiptItem.intLineNo
					AND (
						Receipt.strReceiptType = 'Purchase Contract'
					)	
		) PCOView