CREATE VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT	intInventoryValuationKeyId  = ISNULL(t.intInventoryTransactionId, 0) 
		,intInventoryTransactionId	= ISNULL(t.intInventoryTransactionId, 0) 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,i.intCommodityId
		,strCommodity				= commodity.strCommodityCode
		,intLocationId				= t.intCompanyLocationId --ISNULL(InTransitLocation.intCompanyLocationId, [Location].intCompanyLocationId) 
		,t.intItemLocationId
		,strLocationName			= [location].strLocationName --ISNULL(InTransitLocation.strLocationName, [Location].strLocationName) --ISNULL([Location].strLocationName, InTransitLocation.strLocationName + ' (' + ItemLocation.strDescription + ')') 
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= t.dtmDate --dbo.fnRemoveTimeOnDate(t.dtmDate)
		,strSourceType				= CASE
											WHEN receipt.intInventoryReceiptId IS NOT NULL THEN
												CASE
													WHEN receipt.intSourceType = 1 THEN 'Scale'
													WHEN receipt.intSourceType = 2 THEN 'Inbound Shipment'
													WHEN receipt.intSourceType = 3 THEN 'Transport'
													WHEN receipt.intSourceType = 4 THEN 'Settle Storage'
													WHEN receipt.intSourceType = 5 THEN 'Delivery Sheet'
													ELSE ''
												END
											WHEN shipment.intInventoryShipmentId IS NOT NULL THEN
												CASE
													WHEN shipment.intSourceType = 1 THEN 'Scale'
													WHEN shipment.intSourceType = 2 THEN 'Outbound Shipment'
													WHEN shipment.intSourceType = 3 THEN 'Pick Lot'
													WHEN shipment.intSourceType = 4 THEN 'Delivery Sheet'
													ELSE ''
												END
											ELSE 
												CASE WHEN InventoryTransfer.intSourceType = 3 AND InventoryTransfer.intInventoryTransferDetailId IS NOT NULL 
													AND t.strTransactionForm = 'Inventory Transfer' 
												THEN 'Transport'
												ELSE '' END
										END COLLATE Latin1_General_CI_AS
		,strSourceNumber			= CASE 
										WHEN receipt.intInventoryReceiptId IS NOT NULL THEN
											CASE	
												WHEN receipt.intSourceType = 1 THEN ScaleView.strTicketNumber -- Scale
												WHEN receipt.intSourceType = 2 THEN LogisticsView.strLoadNumber -- Inbound Shipment
												WHEN receipt.intSourceType = 3 THEN LoadHeader.strTransaction -- Transport
												WHEN receipt.intSourceType = 4 THEN SettleStorage.strStorageTicketNumber -- Settle Storage
												WHEN receipt.intSourceType = 5 THEN DeliverySheet.strDeliverySheetNumber -- Delivery Sheet
												ELSE ''
											END
										WHEN shipment.intInventoryShipmentId IS NOT NULL THEN
											CASE	
												WHEN shipment.intSourceType = 1 THEN ScaleView.strTicketNumber -- Scale
												WHEN shipment.intSourceType = 2 THEN LogisticsView.strLoadNumber -- Inbound Shipment
												WHEN shipment.intSourceType = 3 THEN PickLot.strPickLotNumber -- Pick Lot
												WHEN shipment.intSourceType = 4 THEN DeliverySheet.strDeliverySheetNumber -- Delivery Sheet
												ELSE ''
											END
										ELSE
											CASE WHEN InventoryTransfer.intSourceType = 3 
												AND InventoryTransfer.intInventoryTransferDetailId IS NOT NULL 
												AND t.strTransactionForm = 'Inventory Transfer' 
											THEN InventoryTransfer.strSourceNumber
											ELSE '' END
										END
		,strTransactionType			= (CASE WHEN ty.strName IN ('Invoice', 'Credit Memo') THEN isnull(invoice.strTransactionType, ty.strName) ELSE ty.strName END)
		,t.strTransactionForm		
		,t.strTransactionId
		,dblBeginningQtyBalance		= CAST(0 AS NUMERIC(38, 20)) 
		,dblQuantity				= ISNULL(t.dblQty, 0)
		,dblRunningQtyBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblCost					= ISNULL(t.dblCost, 0)
		,dblBeginningBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblValue					= 
									--ISNULL(dbo.fnMultiply(t.dblQty, t.dblCost), 0) + ISNULL(t.dblValue, 0)
									ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2)

		,dblValueRounded			=  ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2)

		,dblRunningBalance			= CAST(0 AS NUMERIC(38, 20))
		,t.strBatchId
		,CostingMethod.strCostingMethod
		,strUOM						= umTransUOM.strUnitMeasure
		,strStockUOM				= iuStock.strUnitMeasure
		,dblQuantityInStockUOM		= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,dblCostInStockUOM			= ISNULL(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblCost), 0)
		,dblPrice					= ISNULL(ItemPricing.dblSalePrice ,0)
		,strBOLNumber				= CAST (
											CASE	ty.intTransactionTypeId 
													WHEN 4 THEN receipt.strBillOfLading 
													WHEN 42 THEN receipt.strBillOfLading 
													WHEN 5 THEN shipment.strBOLNumber 
													WHEN 33 THEN invoice.strBOLNumber 
													WHEN 44 THEN loadShipmentSchedule.strBLNumber
													ELSE NULL 
											END
										AS NVARCHAR(100)
									)
		,strEntity					= e.strName		
		,e.intEntityId
		,strParentLotNumber			= ParentLot.strParentLotNumber
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,ysnInTransit				= CAST(CASE WHEN t.intInTransitSourceLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
		,t.dtmCreated
		,ScaleView.intTicketId
		,strTransactionUOM			= transactionUOM.strUnitMeasure 
		,strDescription				= t.strDescription 
FROM 	tblICInventoryTransaction t 
		INNER JOIN tblICItem i 
			ON t.intItemId = i.intItemId
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId			
					,umStock.strUnitMeasure
			FROM	tblICItemUOM iuStock INNER JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	iuStock.intItemId = i.intItemId
					AND iuStock.ysnStockUnit = 1 
		) iuStock
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity commodity
			ON commodity.intCommodityId = i.intCommodityId		
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId

		LEFT OUTER JOIN (
			SELECT
				  td.intInventoryTransferDetailId,
				  t.intSourceType
				, strTransferNo = t.strTransferNo
				, strSourceNumber = CASE t.intSourceType
					WHEN 1 THEN sourceTicket.strSourceNumber 
					WHEN 2 THEN LGShipmentSource.strSourceNumber
					WHEN 3 THEN transportSource.strSourceNumber 
					ELSE NULL END
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

		) InventoryTransfer ON InventoryTransfer.intInventoryTransferDetailId = t.intTransactionDetailId		
			AND t.intTransactionTypeId = 12
		LEFT JOIN tblSMCompanyLocation [location]
			ON [location].intCompanyLocationId = t.intCompanyLocationId

		--LEFT JOIN (
		--	tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
		--		ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
		--)
		--	ON t.intItemLocationId = ItemLocation.intItemLocationId
		--LEFT JOIN (
		--	tblICItemLocation InTransitItemLocation INNER JOIN tblSMCompanyLocation InTransitLocation 
		--		ON InTransitLocation.intCompanyLocationId = InTransitItemLocation.intLocationId	
		--)
		-- ON t.intInTransitSourceLocationId = InTransitItemLocation.intItemLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId
		LEFT JOIN tblICCostingMethod CostingMethod
			ON CostingMethod.intCostingMethodId = t.intCostingMethod
		LEFT JOIN (
			tblICItemUOM iuTransUOM INNER JOIN tblICUnitMeasure umTransUOM
				ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId			
		)
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICItemPricing ItemPricing
			ON ItemPricing.intItemId = i.intItemId
			AND ItemPricing.intItemLocationId = t.intItemLocationId
		LEFT JOIN tblICLot l
			ON l.intLotId = t.intLotId
		LEFT JOIN tblICParentLot ParentLot
			ON ParentLot.intItemId = l.intItemId
			AND ParentLot.intParentLotId = l.intParentLotId

		LEFT JOIN tblICInventoryReceipt receipt 
			ON receipt.intInventoryReceiptId = t.intTransactionId
			AND receipt.strReceiptNumber = t.strTransactionId
			AND ty.intTransactionTypeId IN (4, 42)
		LEFT JOIN tblICInventoryReceiptItem receiptItem
			ON receiptItem.intInventoryReceiptId = receipt.intInventoryReceiptId
			AND receiptItem.intInventoryReceiptItemId = t.intTransactionDetailId
		LEFT JOIN tblICInventoryShipment shipment 
			ON shipment.intInventoryShipmentId = t.intTransactionId
			AND shipment.strShipmentNumber = t.strTransactionId
			AND ty.intTransactionTypeId = 5
		LEFT JOIN tblICInventoryShipmentItem shipmentItem
			ON shipmentItem.intInventoryShipmentId = shipment.intInventoryShipmentId
			AND shipmentItem.intInventoryShipmentItemId = t.intTransactionDetailId
			AND shipmentItem.intItemId = t.intItemId
		LEFT JOIN tblARInvoice invoice
			ON invoice.intInvoiceId = t.intTransactionId
			AND invoice.strInvoiceNumber = t.strTransactionId
			AND ty.intTransactionTypeId in (33, 45)
		LEFT JOIN tblAPBill bill
			ON bill.intBillId = t.intTransactionId
			AND bill.strBillId = t.strTransactionId
			AND ty.intTransactionTypeId IN (26, 27) 
		OUTER APPLY (
			SELECT	TOP 1 
					ld.intVendorEntityId
					,ld.intCustomerEntityId
					,l.strBLNumber
					,l.strLoadNumber
			FROM	tblLGLoad l INNER JOIN tblLGLoadDetail ld
						ON l.intLoadId = ld.intLoadId
			WHERE	l.strLoadNumber = t.strTransactionId
					AND ld.intLoadDetailId = t.intTransactionDetailId
					AND l.intLoadId = t.intTransactionId
					AND ld.intItemId = t.intItemId		
					AND ty.intTransactionTypeId IN (22,46)
		) loadShipmentSchedule 
		LEFT JOIN tblGRSettleStorage settleStorage 
			ON settleStorage.intSettleStorageId = t.intTransactionId
			AND settleStorage.intSettleStorageId = t.intTransactionDetailId
			AND t.strTransactionForm IN ('Settle Storage', 'Storage Settlement')
			AND ty.intTransactionTypeId = 44 
		LEFT JOIN tblEMEntity e 
			ON e.intEntityId = COALESCE(
				receipt.intEntityVendorId
				, shipment.intEntityCustomerId
				, invoice.intEntityCustomerId
				, bill.intEntityVendorId
				, loadShipmentSchedule.intVendorEntityId
				, loadShipmentSchedule.intCustomerEntityId
				, settleStorage.intEntityId
			)

		LEFT JOIN tblSCTicket ScaleView
			ON ScaleView.intTicketId = CASE 
											WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
											WHEN shipmentItem.intInventoryShipmentId IS NOT NULL THEN shipmentItem.intSourceId
											ELSE NULL
										END
			AND (receipt.intSourceType = 1 OR shipment.intSourceType = 1)

		LEFT JOIN vyuLGLoadContainerLookup LogisticsView
			ON LogisticsView.intLoadDetailId = CASE 
												WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
												WHEN shipmentItem.intInventoryShipmentId IS NOT NULL THEN shipmentItem.intSourceId
												ELSE NULL
											END
			AND LogisticsView.intLoadContainerId = receiptItem.intContainerId
			AND (receipt.intSourceType = 2 OR shipment.intSourceType = 2)
		
		LEFT JOIN (
			tblTRLoadReceipt LoadReceipt INNER JOIN tblTRLoadHeader LoadHeader
				ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId
		)	ON LoadReceipt.intLoadReceiptId = receiptItem.intSourceId
			AND receipt.intSourceType = 3
		
		LEFT JOIN tblLGPickLotHeader PickLot
			ON PickLot.intPickLotHeaderId = shipmentItem.intSourceId
			AND shipment.intSourceType = 3		


		LEFT JOIN tblGRCustomerStorage SettleStorage
			ON SettleStorage.intCustomerStorageId = CASE 
														WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
														ELSE NULL
													END
			AND receipt.intSourceType = 4

		LEFT JOIN tblSCDeliverySheet DeliverySheet
			ON DeliverySheet.intDeliverySheetId =  CASE 
														WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
														WHEN shipmentItem.intInventoryShipmentId IS NOT NULL THEN shipmentItem.intSourceId
														ELSE NULL
													END
			AND (receipt.intSourceType = 5 OR shipment.intSourceType = 4)	

		OUTER APPLY (
			SELECT 
				u.strUnitMeasure
			FROM
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u
					ON iu.intUnitMeasureId = u.intUnitMeasureId
			WHERE
				iu.intItemUOMId = t.intTransactionItemUOMId 
		) transactionUOM


WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)