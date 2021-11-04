CREATE VIEW [dbo].[vyuICGetReceiptDetailSource]
AS

SELECT *
FROM
(

SELECT DISTINCT
	intReceiptId =  Receipt.intInventoryReceiptId,
	strReceiptNumber = Receipt.strReceiptNumber,
	intSourceTransactionId = 
	CASE 
		WHEN Receipt.intSourceType = 0
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN ContractHeader.intContractHeaderId
				WHEN Receipt.strReceiptType = 'Purchase Order'
					THEN Purchase.intPurchaseId
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN InventoryTransfer.intInventoryTransferId
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				END
		WHEN Receipt.intSourceType = 1
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN CASE
						WHEN ReceiptItem.intSourceId IS NOT NULL
							THEN Ticket.intTicketId
						WHEN ReceiptItem.intOrderId IS NOT NULL
							THEN ContractHeader.intContractHeaderId
						ELSE NULL
						END
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN Ticket.intTicketId
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN Ticket.intTicketId
				WHEN Receipt.strReceiptType = 'Direct'
					THEN Ticket.intTicketId
				ELSE NULL
				END
		WHEN Receipt.intSourceType = 2
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE LoadShipment.intLoadId
				END
		WHEN Receipt.intSourceType = 3
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE LoadHeader.intLoadHeaderId
				END
		WHEN Receipt.intSourceType = 4
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE Ticket.intTicketId
				END
		WHEN Receipt.intSourceType = 5
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE DeliverySheet.intDeliverySheetId
				END
		WHEN Receipt.intSourceType = 6
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE Purchase.intPurchaseId
				END
		WHEN Receipt.intSourceType = 7
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.intInventoryReceiptId
				ELSE CheckoutHeader.intCheckoutId
				END
		ELSE NULL
	END,
	strSourceTransactionNumber = 
	CASE
		WHEN Receipt.intSourceType = 0
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN ContractHeader.strContractNumber
				WHEN Receipt.strReceiptType = 'Purchase Order'
					THEN Purchase.strPurchaseOrderNumber
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN InventoryTransfer.strTransferNo
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				END
		WHEN Receipt.intSourceType = 1
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN CASE
						WHEN ReceiptItem.intSourceId IS NOT NULL
							THEN Ticket.strTicketNumber
						WHEN ReceiptItem.intOrderId IS NOT NULL
							THEN ContractHeader.strContractNumber
						ELSE NULL
						END
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN Ticket.strTicketNumber
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN Ticket.strTicketNumber
				WHEN Receipt.strReceiptType = 'Direct'
					THEN Ticket.strTicketNumber
				ELSE NULL
				END
		WHEN Receipt.intSourceType = 2
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE LoadShipment.strLoadNumber
				END
		WHEN Receipt.intSourceType = 3
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE LoadHeader.strTransaction
				END
		WHEN Receipt.intSourceType = 4
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE Ticket.strTicketNumber
				END
		WHEN Receipt.intSourceType = 5
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE DeliverySheet.strDeliverySheetNumber
				END
		WHEN Receipt.intSourceType = 6
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE Purchase.strPurchaseOrderNumber
				END
		WHEN Receipt.intSourceType = 7
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN InventoryReturn.strReceiptNumber
				ELSE 'Checkout - ' + CAST(Store.intStoreNo AS NVARCHAR(50)) + ' - ' + 
					CheckoutHeader.strDescription + ' - ' + 
					CAST(MONTH(CheckoutHeader.dtmCheckoutDate) AS VARCHAR(2)) + '/' + 
					CAST(DAY(CheckoutHeader.dtmCheckoutDate) AS VARCHAR(2)) + '/' + 
					CAST(YEAR(CheckoutHeader.dtmCheckoutDate) AS VARCHAR(4)) + ' - ' +  
					CAST(CheckoutHeader.intShiftNo AS NVARCHAR(50))
				END
		ELSE NULL
	END COLLATE Latin1_General_CI_AS,
	strSourceScreen = 
	CASE
		WHEN Receipt.intSourceType = 0
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN 'Contract'
				WHEN Receipt.strReceiptType = 'Purchase Order'
					THEN 'Purchase Order'
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN 'Inventory Transfer'
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				END
		WHEN Receipt.intSourceType = 1
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN CASE
						WHEN ReceiptItem.intSourceId IS NOT NULL
							THEN 'Scale Ticket'
						WHEN ReceiptItem.intOrderId IS NOT NULL
							THEN 'Contract'
						ELSE NULL
						END
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN 'Scale Ticket'
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Scale Ticket'
				WHEN Receipt.strReceiptType = 'Direct'
					THEN 'Scale Ticket'
				ELSE NULL
				END
		WHEN Receipt.intSourceType = 2
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Load/Shipment Schedule'
				END
			
		WHEN Receipt.intSourceType = 3
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Transport Load'
				END
		WHEN Receipt.intSourceType = 4
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Scale Ticket'
				END
		WHEN Receipt.intSourceType = 5
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Delivery Sheet'
				END
		WHEN Receipt.intSourceType = 6
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Purchase Order'
				END
		WHEN Receipt.intSourceType = 7
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory Receipt'
				ELSE 'Checkout'
				END
		ELSE NULL
	END COLLATE Latin1_General_CI_AS,
	strSourceModule = 
	CASE
		WHEN Receipt.intSourceType = 0
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN 'Contract Management'
				WHEN Receipt.strReceiptType = 'Purchase Order'
					THEN 'Purchasing A/P'
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN 'Inventory'
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				END
		WHEN Receipt.intSourceType = 1
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Purchase Contract'
					THEN CASE
						WHEN ReceiptItem.intSourceId IS NOT NULL
							THEN 'Ticket Management'
						WHEN ReceiptItem.intOrderId IS NOT NULL
							THEN 'Contract Management'
						ELSE NULL
						END
				WHEN Receipt.strReceiptType = 'Transfer Order'
					THEN 'Ticket Management'
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Ticket Management'
				WHEN Receipt.strReceiptType = 'Direct'
					THEN 'Ticket Management'
				ELSE NULL
				END
		WHEN Receipt.intSourceType = 2
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Logistics'
				END
		WHEN Receipt.intSourceType = 3
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Transport'
				END
		WHEN Receipt.intSourceType = 4
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Ticket Management'
				END
		WHEN Receipt.intSourceType = 5
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Ticket Management'
				END
		WHEN Receipt.intSourceType = 6
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Purchasing A/P'
				END
		WHEN Receipt.intSourceType = 7
			THEN CASE 
				WHEN Receipt.strReceiptType = 'Inventory Return'
					THEN 'Inventory'
				ELSE 'Store'
				END
		ELSE NULL
	END COLLATE Latin1_General_CI_AS
FROM tblICInventoryReceipt Receipt
	INNER JOIN tblICInventoryReceiptItem ReceiptItem
		ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId

	-- Link Contracts
	LEFT OUTER JOIN tblCTContractHeader ContractHeader
		ON ContractHeader.intContractHeaderId = ReceiptItem.intOrderId
		AND (Receipt.intSourceType = 0 OR Receipt.intSourceType = 1)
		AND Receipt.strReceiptType = 'Purchase Contract' 

	LEFT OUTER JOIN tblICInventoryTransfer InventoryTransfer
		ON ReceiptItem.intOrderId = InventoryTransfer.intInventoryTransferId
		AND Receipt.intSourceType = 0
		AND Receipt.strReceiptType = 'Transfer Order' 

	-- Link Scale/Ticket
	LEFT OUTER JOIN tblSCTicket Ticket
		ON ReceiptItem.intSourceId = Ticket.intTicketId
		AND (Receipt.intSourceType = 1 OR Receipt.intSourceType = 4)

	--Link Load Shipment
	LEFT OUTER JOIN (tblLGLoadDetail LoadDetail
		INNER JOIN tblLGLoad LoadShipment
			ON LoadShipment.intLoadId = LoadDetail.intLoadId
	)
		ON LoadDetail.intLoadDetailId = ReceiptItem.intSourceId
		AND Receipt.intSourceType = 2

	--Link Transport Load
	LEFT OUTER JOIN (tblTRLoadReceipt LoadReceipt
		INNER JOIN tblTRLoadHeader LoadHeader
			ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId
	)
		ON LoadReceipt.intLoadReceiptId = ReceiptItem.intSourceId
		AND Receipt.intSourceType = 3

	--Link Delivery Sheet
	LEFT OUTER JOIN tblSCDeliverySheet DeliverySheet
		ON DeliverySheet.intDeliverySheetId = ReceiptItem.intSourceId
		AND Receipt.intSourceType = 5

	--Link Purchase Order
	LEFT OUTER JOIN tblPOPurchase Purchase
		ON (
			Purchase.intPurchaseId = COALESCE(ReceiptItem.intSourceId, ReceiptItem.intOrderId)
			AND (Receipt.intSourceType = 6 OR Receipt.strReceiptType = 'Purchase Order')
		)

	-- Link Store
	LEFT OUTER JOIN (tblSTReceiveLottery ReceiveLottery 
		INNER JOIN (tblSTCheckoutHeader CheckoutHeader
			INNER JOIN tblSTStore Store
				ON CheckoutHeader.intStoreId = Store.intStoreId
		)
			ON ReceiveLottery.intCheckoutId = CheckoutHeader.intCheckoutId
				
	)
		ON ReceiptItem.intSourceId = ReceiveLottery.intReceiveLotteryId
		AND Receipt.intSourceType = 7

	-- Link Inventory Return
	LEFT OUTER JOIN (tblICInventoryReceiptItem InventoryReturnItem
		INNER JOIN tblICInventoryReceipt InventoryReturn
			ON InventoryReturn.intInventoryReceiptId = InventoryReturnItem.intInventoryReceiptId
	)
		ON InventoryReturnItem.intInventoryReceiptItemId = ReceiptItem.intSourceInventoryReceiptItemId
		AND Receipt.strReceiptType = 'Inventory Return'

) AS InventoryReceiptLinks
WHERE intSourceTransactionId IS NOT NULL