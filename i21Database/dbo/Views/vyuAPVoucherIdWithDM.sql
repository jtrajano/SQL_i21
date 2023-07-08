/*
	Handle data from AP-12194 issue
*/
CREATE VIEW [dbo].[vyuAPVoucherIdWithDM]
AS 
SELECT v.intBillId
FROM (tblAPBillDetail v INNER JOIN tblAPBill v2 ON v.intBillId = v2.intBillId AND v2.intTransactionType = 1 AND v.intInventoryReceiptChargeId IS NULL)
INNER JOIN (tblAPBillDetail dm INNER JOIN tblAPBill dm2 ON dm.intBillId = dm2.intBillId AND dm2.intTransactionType = 3 AND dm.intInventoryReceiptChargeId IS NULL)
	ON v.intInventoryReceiptItemId = dm.intInventoryReceiptItemId
WHERE
	v2.ysnPosted = 1
AND dm2.ysnPosted = 1
UNION ALL
SELECT dm.intBillId
FROM (tblAPBillDetail v INNER JOIN tblAPBill v2 ON v.intBillId = v2.intBillId AND v2.intTransactionType = 1 AND v.intInventoryReceiptChargeId IS NULL)
INNER JOIN (tblAPBillDetail dm INNER JOIN tblAPBill dm2 ON dm.intBillId = dm2.intBillId AND dm2.intTransactionType = 3 AND dm.intInventoryReceiptChargeId IS NULL)
	ON v.intInventoryReceiptItemId = dm.intInventoryReceiptItemId
WHERE
	v2.ysnPosted = 1
AND dm2.ysnPosted = 1