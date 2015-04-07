
EXEC
('
IF EXISTS(SELECT 1 FROM tblAPBillDetail A WHERE A.intPODetailId IS NULL AND A.intItemReceiptId IS NOT NULL)
BEGIN
	--SET the new intPODetailId field to track the po item
	UPDATE A
		SET A.intPODetailId = A.intItemReceiptId
	FROM tblAPBillDetail A
		INNER JOIN tblICItem B
			ON A.intItemId = B.intItemId
	WHERE B.strType NOT IN (''Service'',''Software'',''Non-Inventory'',''Other Charge'') AND A.intItemReceiptId IS NOT NULL

	--SET the intItemReceiptId to track the IR, update only those that has only one IR
	UPDATE A
		SET A.intItemReceiptId = (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem WHERE intLineNo = A.intPODetailId)
	FROM tblAPBillDetail A
	WHERE A.intPODetailId IS NOT NULL
	AND 1 = (SELECT COUNT(*) FROM tblICInventoryReceiptItem WHERE intLineNo = A.intPODetailId)

	--SET THE dblBillQty to 0 if there are no bills yet for IR
	UPDATE A
		SET A.dblBillQty = 0
	FROM tblICInventoryReceiptItem A
	WHERE NOT EXISTS
	(
		SELECT
			1
		FROM tblAPBill B
			INNER JOIN tblAPBillDetail C
				ON B.intBillId = C.intBillId
		WHERE A.intInventoryReceiptItemId = C.intItemReceiptId
		AND ysnPosted = 1
	)

	--SET update PO qty received item
	UPDATE A
		SET A.dblQtyReceived = ISNULL(Received.dblTotalReceived, 0)
	FROM tblPOPurchaseDetail A
	OUTER APPLY
	(
		SELECT 
			SUM(dblTotalReceived) dblTotalReceived
			,intLineNo
		FROM (
			SELECT 
				dbo.[fnCalculateQtyBetweenUOM](A.intUnitOfMeasureId, C.intUnitMeasureId, SUM(C.dblOpenReceive)) dblTotalReceived
				,C.intLineNo
			FROM tblICInventoryReceipt B
				INNER JOIN tblICInventoryReceiptItem C
					ON B.intInventoryReceiptId = C.intInventoryReceiptId
			WHERE B.ysnPosted = 1 
			AND C.intLineNo = A.intPurchaseDetailId
			GROUP BY C.intLineNo, C.intUnitMeasureId
		) TotalReceived
		GROUP BY intLineNo
	) Received
END
')






