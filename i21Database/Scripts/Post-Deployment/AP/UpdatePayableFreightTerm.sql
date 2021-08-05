PRINT N'START: UPDATING PAYABLE FREIGHT TERM'
--UPDATE PAYABLE RECORD's NEW FREIGHT TERM ID
UPDATE A
SET A.intFreightTermId = C.intFreightTermId
FROM tblAPVoucherPayable A
INNER JOIN (tblICInventoryReceiptItem B INNER JOIN tblICInventoryReceipt C 
				ON B.intInventoryReceiptId = C.intInventoryReceiptId)
	ON A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
PRINT N'SUCCESS: UPDATING PAYABLE FREIGHT TERM'