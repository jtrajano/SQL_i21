--UPDATE PAYABLE RECORD's NEW FREIGHT TERM ID
UPDATE A
SET A.intFreightTermId = C.intFreightTermId
FROM tblAPVoucherPayable A
INNER JOIN (tblICInventoryReceiptItem B INNER JOIN tblICInventoryReceipt C 
				ON B.intInventoryReceiptId = C.intInventoryReceiptId)
	ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId