CREATE PROCEDURE [dbo].[uspICRebuildInventoryTransaction]
	@ysnForceRebuild BIT = 0
AS

IF EXISTS (SELECT * FROM tblICCompanyPreference WHERE ISNULL(ysnMigrateNewInventoryTransaction, 0) = 0) 
	OR @ysnForceRebuild = 1
BEGIN 
	UPDATE t 
	SET 
		t.strSourceType	=				
			CASE
				WHEN receipt.intInventoryReceiptId IS NOT NULL THEN
					CASE
						WHEN receipt.intSourceType = 1 THEN 'Scale'
						WHEN receipt.intSourceType = 2 THEN 'Inbound Shipment'
						WHEN receipt.intSourceType = 3 THEN 'Transport'
						WHEN receipt.intSourceType = 4 THEN 'Settle Storage'
						WHEN receipt.intSourceType = 5 THEN 'Delivery Sheet'
						WHEN receipt.intSourceType = 6 THEN 'Purchase Order'
						WHEN receipt.intSourceType = 7 THEN 'Store'
						ELSE NULL 
					END
				WHEN shipment.intInventoryShipmentId IS NOT NULL THEN
					CASE
						WHEN shipment.intSourceType = 1 THEN 'Scale'
						WHEN shipment.intSourceType = 2 THEN 'Outbound Shipment'
						WHEN shipment.intSourceType = 3 THEN 'Pick Lot'
						WHEN shipment.intSourceType = 4 THEN 'Delivery Sheet'
						ELSE NULL 
					END
				ELSE 
					CASE 
						WHEN InventoryTransfer.intSourceType = 3 AND InventoryTransfer.intInventoryTransferDetailId IS NOT NULL 
						AND t.strTransactionForm = 'Inventory Transfer' 
						THEN 
							'Transport'
						ELSE NULL 
					END
			END COLLATE Latin1_General_CI_AS
		,t.strSourceNumber = 
			CASE 
				WHEN receipt.intInventoryReceiptId IS NOT NULL THEN
					CASE	
						WHEN receipt.intSourceType = 1 THEN ScaleView.strTicketNumber -- Scale
						WHEN receipt.intSourceType = 2 THEN LogisticsView.strLoadNumber -- Inbound Shipment
						WHEN receipt.intSourceType = 3 THEN LoadHeader.strTransaction -- Transport
						WHEN receipt.intSourceType = 4 THEN SettleStorage.strStorageTicketNumber -- Settle Storage
						WHEN receipt.intSourceType = 5 THEN DeliverySheet.strDeliverySheetNumber -- Delivery Sheet
						ELSE NULL
					END
				WHEN shipment.intInventoryShipmentId IS NOT NULL THEN
					CASE	
						WHEN shipment.intSourceType = 1 THEN ScaleView.strTicketNumber -- Scale
						WHEN shipment.intSourceType = 2 THEN LogisticsView.strLoadNumber -- Inbound Shipment
						WHEN shipment.intSourceType = 3 THEN PickLot.strPickLotNumber -- Pick Lot
						WHEN shipment.intSourceType = 4 THEN DeliverySheet.strDeliverySheetNumber -- Delivery Sheet
						ELSE NULL
					END
				ELSE
					CASE 
						WHEN InventoryTransfer.intSourceType = 3 
						AND InventoryTransfer.intInventoryTransferDetailId IS NOT NULL 
						AND t.strTransactionForm = 'Inventory Transfer' 
						THEN 
							InventoryTransfer.strSourceNumber
						ELSE 
							NULL 
					END
			END
		,t.strBOLNumber = 
			CAST (
					CASE	
						ty.intTransactionTypeId 
						WHEN 4 THEN receipt.strBillOfLading 
						WHEN 42 THEN receipt.strBillOfLading 
						WHEN 5 THEN shipment.strBOLNumber 
						WHEN 33 THEN invoice.strBOLNumber 
						WHEN 44 THEN loadShipmentSchedule.strBLNumber
						ELSE NULL 
					END
				AS NVARCHAR(100)
			)
		,t.intSourceEntityId = 
			COALESCE(
				receipt.intEntityVendorId
				, shipment.intEntityCustomerId
				, invoice.intEntityCustomerId
				, bill.intEntityVendorId
				, loadShipmentSchedule.intVendorEntityId
				, loadShipmentSchedule.intCustomerEntityId
				, settleStorage.intEntityId
				, adjustmentItem.intEntityId
			)
	FROM 
		tblICInventoryTransaction t
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN (
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

			LEFT JOIN tblICInventoryAdjustment adj
				ON adj.intInventoryAdjustmentId = t.intTransactionId
				AND adj.strAdjustmentNo = t.strTransactionId
				AND ty.strTransactionForm = 'Inventory Adjustment'

			LEFT JOIN tblICInventoryAdjustmentDetail adjustmentItem
				ON adjustmentItem.intInventoryAdjustmentId = adj.intInventoryAdjustmentId
				AND adjustmentItem.intInventoryAdjustmentDetailId = t.intTransactionDetailId
				AND adjustmentItem.intItemId = t.intItemId		

			LEFT JOIN tblSCTicket ScaleView
				ON ScaleView.intTicketId = CASE 
												WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
												WHEN shipmentItem.intInventoryShipmentId IS NOT NULL THEN shipmentItem.intSourceId
												ELSE NULL
											END
				AND (receipt.intSourceType = 1 OR shipment.intSourceType = 1)

			OUTER APPLY (
				SELECT	TOP 1 
						L.strLoadNumber
				FROM	tblLGLoad L INNER JOIN tblLGLoadDetail LD
							ON L.intLoadId = LD.intLoadId
						LEFT JOIN tblLGLoadContainer LC 
							ON LC.intLoadId = L.intLoadId AND ISNULL(LC.ysnRejected, 0) = 0
						LEFT JOIN tblLGLoadDetailContainerLink LDCL 
							ON LDCL.intLoadContainerId = LC.intLoadContainerId		
				WHERE 
						LD.intLoadDetailId = receiptItem.intSourceId
						AND receipt.intSourceType = 2 
						AND ISNULL(LC.intLoadContainerId, -1) = receiptItem.intContainerId					
						AND L.intShipmentType = 1
			) LogisticsView
		
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
				ON DeliverySheet.intDeliverySheetId =  
					CASE 
						WHEN receiptItem.intInventoryReceiptId IS NOT NULL THEN receiptItem.intSourceId
						WHEN shipmentItem.intInventoryShipmentId IS NOT NULL THEN shipmentItem.intSourceId
						ELSE NULL
					END
				AND (receipt.intSourceType = 5 OR shipment.intSourceType = 4)	

			LEFT JOIN tblEMEntity e 
				ON e.intEntityId = COALESCE(
					receipt.intEntityVendorId
					, shipment.intEntityCustomerId
					, invoice.intEntityCustomerId
					, bill.intEntityVendorId
					, loadShipmentSchedule.intVendorEntityId
					, loadShipmentSchedule.intCustomerEntityId
					, settleStorage.intEntityId
					, adjustmentItem.intEntityId
				)

	UPDATE tblICCompanyPreference 
	SET ysnMigrateNewInventoryTransaction = 1
END 