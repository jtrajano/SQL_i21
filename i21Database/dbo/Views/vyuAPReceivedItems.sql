CREATE VIEW [dbo].[vyuAPReceivedItems]
AS
SELECT
A.intVendorId
,A.dtmDate
,A.strReference
,A.strPurchaseOrderNumber
,B.intPurchaseDetailId
,B.intItemId
,C.strItemNo
,C.strDescription
,tblReceived.dblOrderQty
,tblReceived.dblOpenReceive
,tblReceived.intLineNo
,tblReceived.dblUnitCost
,tblReceived.intAccountId
,tblReceived.strAccountId
,D2.strName
,D1.strVendorId
,E.strShipVia
,F.strTerm
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN 
	(
		SELECT
			B.intItemId
			,B.intLineNo
			,B.dblOrderQty
			,B.dblUnitCost
			,SUM(ISNULL(B.dblOpenReceive,0)) dblOpenReceive
			,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')
			,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
		FROM tblICInventoryReceipt A
			INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
			INNER JOIN tblICItemLocation loc ON B.intItemId = loc.intItemId AND A.intLocationId = loc.intLocationId
		WHERE A.ysnPosted = 1 AND B.dblOpenReceive != B.dblBillQty
		GROUP BY
			B.intInventoryReceiptItemId
			,B.intItemId 
			,B.dblUnitCost
			,intLineNo
			,dblOrderQty
			,loc.intItemLocationId
	) as tblReceived
	ON B.intPurchaseDetailId = tblReceived.intLineNo AND B.intItemId = tblReceived.intItemId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityId = D2.intEntityId) ON A.intVendorId = D1.intVendorId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.intShipViaID
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
UNION ALL
--Miscellaneous items
SELECT
A.intVendorId
,A.dtmDate
,A.strReference
,A.strPurchaseOrderNumber
,B.intPurchaseDetailId
,B.intItemId
,C.strItemNo
,C.strDescription
,B.dblQtyOrdered
,B.dblQtyOrdered
,B.intPurchaseDetailId
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
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityId = D2.intEntityId) ON A.intVendorId = D1.intVendorId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.intShipViaID
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')
AND B.dblQtyOrdered != B.dblQtyReceived