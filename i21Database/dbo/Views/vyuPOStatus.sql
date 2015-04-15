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
	,ISNULL(ReceivedItems.dblIRItemQtyReceive,0) AS dblIRItemQtyReceive
	,ISNULL(ReceivedItems.dblPOItemQtyReceive,0) AS dblPOItemQtyReceive
	,ysnItemReceived = CASE WHEN (B.dblQtyOrdered = ISNULL(ReceivedItems.dblPOItemQtyReceive,0)) AND A.intOrderStatusId <> 1 THEN 1 ELSE 0 END
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
			SUM(dblIRItemQtyReceive) dblIRItemQtyReceive
			,SUM(dblPOItemQtyReceive) dblPOItemQtyReceive
			,intLineNo
		FROM
		(
			SELECT
				F2.intItemId
				,F2.intLineNo
				,SUM(F2.dblOpenReceive) dblIRItemQtyReceive
				,dbo.fnCalculateQtyBetweenUOM(F2.intUnitMeasureId, B.intUnitOfMeasureId, SUM(F2.dblOpenReceive)) dblPOItemQtyReceive
			FROM tblICInventoryReceipt F1
				INNER JOIN tblICInventoryReceiptItem F2
					ON F1.intInventoryReceiptId = F2.intInventoryReceiptId
			WHERE F1.ysnPosted = 1
			AND F2.intLineNo = B.intPurchaseDetailId
			GROUP BY F2.intItemId, F2.intLineNo, F2.intUnitMeasureId
		) TotalReceivedItems
		WHERE TotalReceivedItems.intLineNo = B.intPurchaseDetailId
		GROUP BY intLineNo
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

	

