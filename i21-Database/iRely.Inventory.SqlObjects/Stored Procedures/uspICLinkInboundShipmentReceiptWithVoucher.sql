CREATE PROCEDURE uspICLinkInboundShipmentReceiptWithVoucher
	@intBillId INT = NULL
	,@intInventoryReceiptId INT = NULL 
AS

DECLARE @inboundShipment AS INT = 2

UPDATE	bd
SET		bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			AND r.intSourceType = @inboundShipment
			AND r.strReceiptType = 'Purchase Contract'
			AND r.ysnPosted = 1
		INNER JOIN (
			tblAPBill b INNER JOIN tblAPBillDetail bd
				ON b.intBillId = bd.intBillId		
		)
			ON ri.intOrderId = bd.intContractHeaderId
			AND ri.intLineNo = bd.intContractDetailId
			AND ri.intSourceId = bd.intLoadDetailId
			AND bd.intInventoryReceiptItemId IS NULL 
WHERE	b.intBillId = @intBillId 
		OR r.intInventoryReceiptId = @intInventoryReceiptId 