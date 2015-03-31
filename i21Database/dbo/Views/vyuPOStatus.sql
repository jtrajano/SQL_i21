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
	,ISNULL(BillItems.dblItemQtyBilled,0) AS dblItemQtyBilled
	,ISNULL(BillItems.dblItemQtyForBill,0) AS dblItemQtyForBill
	,ISNULL(ReceivedItems.dblItemQtyReceived,0) AS dblItemQtyReceived
	,ISNULL(ReceivedItems.dblItemQtyForReceive,0) AS dblItemForReceive
	,ysnItemReceived = CASE WHEN (B.dblQtyOrdered = ISNULL(ReceivedItems.dblItemQtyReceived,0)) AND A.intOrderStatusId <> 1 THEN 1 ELSE 0 END
	,ysnItemBilled = CASE WHEN (B.dblQtyOrdered = ISNULL(BillItems.dblItemQtyBilled,0)) AND A.intOrderStatusId <> 1 THEN 1 ELSE 0 END
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B
		ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN tblPOOrderStatus C
		ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN tblICItem D
		ON B.intItemId = D.intItemId
	OUTER APPLY (
		SELECT
			F2.intItemId
			,F2.intLineNo
			,SUM(F2.dblReceived) dblItemQtyReceived
			,SUM(F2.dblOpenReceive) dblItemQtyForReceive
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
			,SUM(CASE WHEN E1.ysnPosted = 1 THEN E2.dblQtyReceived ELSE 0 END) AS dblItemQtyBilled
			,SUM(CASE WHEN E1.ysnPosted = 0 THEN E2.dblQtyReceived ELSE 0 END) AS dblItemQtyForBill
		FROM tblAPBill E1 INNER JOIN tblAPBillDetail E2
						ON E1.intBillId = E2.intBillId
		WHERE E1.ysnPosted = 1 AND E2.intItemReceiptId = B.intPurchaseDetailId
		GROUP BY E2.intItemId, E2.intItemReceiptId
	) BillItems

	
