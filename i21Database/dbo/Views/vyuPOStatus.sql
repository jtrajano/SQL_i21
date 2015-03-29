CREATE VIEW [dbo].[vyuPOStatus]
AS
SELECT
	A.intPurchaseId
	,A.strPurchaseOrderNumber
	,A.intOrderStatusId
	,B.intPurchaseDetailId
	,B.intItemId
	,B.dblQtyOrdered
	,B.dblQtyReceived
	,C.strStatus
	,D.strType
	,ISNULL(BillItems.dblQtyBilled,0) AS dblQtyBilled
	,ISNULL(ReceivedItems.dblItemReceived,0) AS dblItemReceived
	,ISNULL(ReceivedItems.dblItemForReceived,0) AS dblItemForReceived
	,ysnItemBilled = CASE WHEN (B.dblQtyOrdered = ISNULL(BillItems.dblQtyBilled,0)) THEN 1 ELSE 0 END
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B
		ON A.intPurchaseId = B.intPurchaseDetailId
	INNER JOIN tblPOOrderStatus C
		ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	OUTER APPLY (
		SELECT
			F2.intItemId
			,F2.intLineNo
			,SUM(F2.dblReceived) dblItemReceived
			,SUM(F2.dblOpenReceive) dblItemForReceived
		FROM tblICInventoryReceipt F1
			INNER JOIN tblICInventoryReceiptItem F2
				ON F1.intInventoryReceiptId = F2.intInventoryReceiptId
		WHERE F2.intLineNo = B.intPurchaseDetailId
		GROUP BY F2.intItemId, F2.intLineNo
	) ReceivedItems
	OUTER APPLY (
		SELECT 
			E2.intItemId
			,E2.intItemReceiptId
			,SUM(E2.dblQtyReceived) AS dblQtyBilled
		FROM tblAPBill E1 INNER JOIN tblAPBillDetail E2
						ON E1.intBillId = E2.intBillId
		WHERE E1.ysnPosted = 1 AND E2.intItemReceiptId = B.intPurchaseDetailId
		GROUP BY E2.intItemId, E2.intItemReceiptId
	) BillItems

	
