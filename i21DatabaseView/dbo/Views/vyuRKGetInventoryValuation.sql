﻿CREATE VIEW [dbo].[vyuRKGetInventoryValuation]

AS
SELECT	intInventoryValuationKeyId  = ISNULL(t.intInventoryTransactionId, 0) 
		,intInventoryTransactionId	= ISNULL(t.intInventoryTransactionId, 0) 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,intLocationId				= ISNULL(InTransitLocation.intCompanyLocationId, [Location].intCompanyLocationId) 
		,t.intItemLocationId
		,strLocationName			= ISNULL(InTransitLocation.strLocationName, [Location].strLocationName) --ISNULL([Location].strLocationName, InTransitLocation.strLocationName + ' (' + ItemLocation.strDescription + ')') 
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= dbo.fnRemoveTimeOnDate(t.dtmDate)
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
											ELSE ''
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
											''
										END
		,intSourceId			= CASE 
										WHEN receipt.intInventoryReceiptId IS NOT NULL THEN
											CASE	
												WHEN receipt.intSourceType = 1 THEN ScaleView.intTicketId -- Scale
												WHEN receipt.intSourceType = 2 THEN LogisticsView.intLoadContainerId -- Inbound Shipment
												WHEN receipt.intSourceType = 3 THEN LoadHeader.intLoadHeaderId -- Transport
												WHEN receipt.intSourceType = 4 THEN SettleStorage.intStorageScheduleId -- Settle Storage
												WHEN receipt.intSourceType = 5 THEN DeliverySheet.intDeliverySheetId -- Delivery Sheet
												ELSE ''
											END
										WHEN shipment.intInventoryShipmentId IS NOT NULL THEN
											CASE	
												WHEN shipment.intSourceType = 1 THEN ScaleView.intTicketId -- Scale
												WHEN shipment.intSourceType = 2 THEN LogisticsView.intLoadContainerId -- Inbound Shipment
												WHEN shipment.intSourceType = 3 THEN PickLot.intPickLotHeaderId -- Pick Lot
												WHEN shipment.intSourceType = 4 THEN DeliverySheet.intDeliverySheetId -- Delivery Sheet
												ELSE ''
											END
										ELSE
											''
										END
		,strTransactionType			= (CASE WHEN ty.strName = 'Invoice' THEN invoice.strTransactionType ELSE ty.strName END)
		,t.strTransactionForm	
		,t.intTransactionId	
		,t.strTransactionId	
		,t.intTransactionDetailId	
		,dblQuantity				= ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, iuStock.intItemUOMId, t.dblQty), 0)
		,t.strBatchId	
		,strUOM						= umTransUOM.strUnitMeasure
		,strEntity					= e.strName			
		,intEntityId				= e.intEntityId							
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,ysnInTransit				= CAST(CASE WHEN InTransitLocation.intCompanyLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
		,t.dtmCreated
		,t.intCurrencyId
		,cur.strCurrency
FROM 	tblICItem i 
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId			
					,umStock.strUnitMeasure
			FROM	tblICItemUOM iuStock INNER JOIN tblICUnitMeasure umStock
						ON iuStock.intUnitMeasureId = umStock.intUnitMeasureId
			WHERE	iuStock.intItemId = i.intItemId
					AND iuStock.ysnStockUnit = 1 -- TODO: In 18.3, change it to use the [Stock UOM] instead of [Stock Unit]. 
					--AND iuStock.ysnStockUOM = 1
		) iuStock
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICInventoryTransaction t 
			ON i.intItemId = t.intItemId
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId
		LEFT JOIN (
			tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
				ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
		)
			ON t.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN (
			tblICItemLocation InTransitItemLocation INNER JOIN tblSMCompanyLocation InTransitLocation 
				ON InTransitLocation.intCompanyLocationId = InTransitItemLocation.intLocationId	
		)
			ON t.intInTransitSourceLocationId = InTransitItemLocation.intItemLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId

		LEFT JOIN tblSMCurrency cur
			ON cur.intCurrencyID = t.intCurrencyId
		LEFT JOIN tblICCostingMethod CostingMethod
			ON CostingMethod.intCostingMethodId = t.intCostingMethod
		LEFT JOIN (
			tblICItemUOM iuTransUOM INNER JOIN tblICUnitMeasure umTransUOM
				ON umTransUOM.intUnitMeasureId = iuTransUOM.intUnitMeasureId			
		)
			ON iuTransUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICLot l
			ON l.intLotId = t.intLotId

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
			AND shipmentItem.intItemId = i.intItemId

		LEFT JOIN tblARInvoice invoice
			ON invoice.intInvoiceId = t.intTransactionId
			AND invoice.strInvoiceNumber = t.strTransactionId
			AND ty.intTransactionTypeId = 33
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
					AND ty.intTransactionTypeId = 44
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

WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)