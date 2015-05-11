CREATE VIEW [dbo].[vyuAPReceivedItems]
AS
--PO Items
SELECT
A.[intEntityVendorId]
,A.dtmDate
,A.strReference
,tblReceived.strReceiptNumber AS strSourceNumber
,A.strPurchaseOrderNumber
,B.intPurchaseDetailId
,B.intItemId
,C.strItemNo
,C.strDescription
,tblReceived.dblOrderQty
,tblReceived.dblPOOpenReceive
,tblReceived.dblOpenReceive
,tblReceived.intLineNo
,tblReceived.intInventoryReceiptItemId
,tblReceived.dblUnitCost
,tblReceived.intAccountId
,tblReceived.strAccountId
,D2.strName
,D1.strVendorId
,E.strShipVia
,F.strTerm
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	CROSS APPLY 
	(
		SELECT
			A1.strReceiptNumber
			,B1.intInventoryReceiptItemId
			,B1.intItemId
			,B1.intLineNo
			,B1.dblOrderQty
			,B1.dblUnitCost
			,dbo.fnCalculateQtyBetweenUOM(B1.intUnitMeasureId, B.intUnitOfMeasureId, SUM(ISNULL(B1.dblOpenReceive,0))) dblPOOpenReceive
			,SUM(ISNULL(B1.dblOpenReceive,0)) dblOpenReceive
			,intAccountId = [dbo].[fnGetItemGLAccount](B1.intItemId, loc.intItemLocationId, 'AP Clearing')
			,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B1.intItemId, loc.intItemLocationId, 'AP Clearing'))
		FROM tblICInventoryReceipt A1
			INNER JOIN tblICInventoryReceiptItem B1 ON A1.intInventoryReceiptId = B1.intInventoryReceiptId
			INNER JOIN tblICItemLocation loc ON B1.intItemId = loc.intItemId AND A1.intLocationId = loc.intLocationId
		WHERE A1.ysnPosted = 1 AND B1.dblOpenReceive != B1.dblBillQty
		AND B.intPurchaseDetailId = B1.intLineNo
		GROUP BY
			A1.strReceiptNumber
			,B1.intInventoryReceiptItemId
			,B1.intItemId 
			,B1.dblUnitCost
			,intLineNo
			,dblOrderQty
			,loc.intItemLocationId
			,B1.intUnitMeasureId

	) as tblReceived
	--ON B.intPurchaseDetailId = tblReceived.intLineNo AND B.intItemId = tblReceived.intItemId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.intShipViaID
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
UNION ALL
--Miscellaneous items
SELECT
A.[intEntityVendorId]
,A.dtmDate
,A.strReference
,A.strPurchaseOrderNumber
,A.strPurchaseOrderNumber
,B.intPurchaseDetailId
,B.intItemId
,C.strItemNo
,C.strDescription
,B.dblQtyOrdered
,B.dblQtyOrdered -B.dblQtyReceived
,B.dblQtyOrdered
,B.intPurchaseDetailId
,NULL
,B.dblCost
,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory')
,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Inventory'))
,D2.strName
,D1.strVendorId
,E.strShipVia
,F.strTerm
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.intShipViaID
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
AND B.dblQtyOrdered != B.dblQtyReceived
UNION ALL
--DIRECT TYPE
SELECT
A.intEntityVendorId
,A.dtmReceiptDate
,A.strVendorRefNo
,A.strReceiptNumber
,A.strReceiptNumber
,B.intInventoryReceiptItemId
,B.intItemId
,C.strItemNo
,C.strDescription
,B.dblOpenReceive
,B.dblReceived
,B.dblOpenReceive
,B.intInventoryReceiptItemId
,NULL
,B.dblUnitCost
,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory')
,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Inventory'))
,D2.strName
,D1.strVendorId
,E.strShipVia
,NULL
FROM tblICInventoryReceipt A
INNER JOIN tblICInventoryReceiptItem B
	ON A.intInventoryReceiptId = B.intInventoryReceiptId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.intShipViaID
WHERE A.strReceiptType = 'Direct' AND A.ysnPosted = 1