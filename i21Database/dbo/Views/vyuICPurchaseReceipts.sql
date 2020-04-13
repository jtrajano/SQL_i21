CREATE VIEW vyuICPurchaseReceipts
AS
SELECT
	  purchase.strReceiptNumber
	, purchase.intPurchaseDetailId
	, purchase.intPurchaseId
	, purchase.dblReceived
	, purchase.dblOpenReceive
	, purchase.dblOrderQty
	, po.intItemId
	, po.intLocationId
	, po.intStockUOM
FROM vyuPODetails po
	INNER JOIN tblPOPurchase p ON p.intPurchaseId = po.intPurchaseId
	INNER JOIN (
		SELECT c.intPurchaseDetailId, c.intPurchaseId, a.strReceiptNumber, b.dblReceived, b.dblOpenReceive, b.dblOrderQty
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intPurchaseDetailId = b.intLineNo
		WHERE a.strReceiptType = 'Purchase Order'
		UNION ALL
		SELECT c.intPurchaseDetailId, c.intPurchaseId,  a.strReceiptNumber, b.dblReceived, b.dblOpenReceive, b.dblOrderQty
		from tblICInventoryReceipt a
			join tblICInventoryReceiptItem b
				on a.intInventoryReceiptId = b.intInventoryReceiptId
			join tblPOPurchaseDetail c
				on c.intContractDetailId = b.intLineNo
		WHERE a.strReceiptType = 'Purchase Contract' AND a.intSourceType = 6
	) purchase ON purchase.intPurchaseId = po.intPurchaseId
		AND purchase.intPurchaseDetailId = po.intPurchaseDetailId
WHERE po.ysnCompleted = 1