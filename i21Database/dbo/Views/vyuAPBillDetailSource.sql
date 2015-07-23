CREATE VIEW [dbo].[vyuAPBillDetailSource]
AS

--SELECT * FROM (
	SELECT
	--ROW_NUMBER() OVER(ORDER BY A.intBillDetailId) AS intBillDetailSourceId
	Items.*
	,A.intBillDetailId
	FROM tblAPBillDetail A
	INNER JOIN
	(
	--PO Items
	SELECT
	tblReceived.strReceiptNumber AS strSourceNumber
	,B.intPurchaseDetailId
	,tblReceived.intInventoryReceiptItemId
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
		CROSS APPLY 
		(
			SELECT
				A1.strReceiptNumber
				,B1.intInventoryReceiptItemId
			FROM tblICInventoryReceipt A1
				INNER JOIN tblICInventoryReceiptItem B1 ON A1.intInventoryReceiptId = B1.intInventoryReceiptId
			WHERE A1.ysnPosted = 1
			AND B.intPurchaseDetailId = B1.intLineNo
			GROUP BY
				A1.strReceiptNumber
				,B1.intInventoryReceiptItemId

		) as tblReceived
	UNION ALL
	--Miscellaneous items
	SELECT
	A.strPurchaseOrderNumber
	,B.intPurchaseDetailId
	,NULL
	FROM tblPOPurchase A
		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')

	UNION ALL
	--DIRECT TYPE
	SELECT
	A.strReceiptNumber
	,NULL
	,B.intInventoryReceiptItemId
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	WHERE A.strReceiptType IN ('Direct','Purchase Contract') AND A.ysnPosted = 1
	) Items
	ON (A.intPurchaseDetailId = Items.intPurchaseDetailId AND A.intInventoryReceiptItemId IS NULL)
	OR (A.intInventoryReceiptItemId = Items.intInventoryReceiptItemId AND A.intPurchaseDetailId IS NULL)
	OR (A.intInventoryReceiptItemId = Items.intInventoryReceiptItemId AND A.intPurchaseDetailId = Items.intPurchaseDetailId)
--) BillDetailSource