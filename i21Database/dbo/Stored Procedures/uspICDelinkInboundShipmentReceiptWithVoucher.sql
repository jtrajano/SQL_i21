CREATE PROCEDURE uspICDelinkInboundShipmentReceiptWithVoucher
	@intBillId INT = NULL
	,@intInventoryReceiptId INT = NULL 
AS

DECLARE @SOURCE_TYPE_NONE AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_InboundShipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3
		,@SOURCE_TYPE_SettleStorage AS INT = 4
		,@SOURCE_TYPE_DeliverySheet AS INT = 5
		,@SOURCE_TYPE_PurchaseOrder AS INT = 6
		,@SOURCE_TYPE_Store AS INT = 7
		,@SOURCE_TYPE_TransferShipment AS INT = 9


-- Remove link between the provisional voucher and inventory receipt if source type is Inbound Shipment and the Voucher is created before Inventory Receipt. 
UPDATE	bd
SET		bd.intInventoryReceiptItemId = NULL 		
FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			AND r.intSourceType = @SOURCE_TYPE_InboundShipment
			AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblAPBillDetail bd
			ON bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		INNER JOIN tblAPBill b
			ON b.intBillId = bd.intBillId			
WHERE	
	(b.intBillId = @intBillId OR r.intInventoryReceiptId = @intInventoryReceiptId )
	AND ri.dtmDateCreated > b.dtmDateCreated 

