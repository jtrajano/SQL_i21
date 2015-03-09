CREATE VIEW [dbo].[vyuAPReceivedItems]
AS
SELECT
	B.intInventoryReceiptItemId
	,B.intItemId
	,B.intLineNo
	,B.dblOrderQty
	,B.dblOpenReceive
	,B.dblReceived
	,B.dblUnitCost
	,B.dblLineTotal
	,B.intSourceId
	,D.intVendorId
	,A.dtmReceiptDate
	,E2.strName
	,E1.strVendorId
	,C.strDescription
	,C.strItemNo
	,D.strReference
	,D.strPurchaseOrderNumber
	,F.strShipVia
	,G.strTerm
	,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')
	,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'AP Clearing'))
FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblPOPurchase D ON B.intSourceId = D.intPurchaseId
	INNER JOIN  (tblAPVendor E1 INNER JOIN tblEntity E2 ON E1.intEntityVendorId = E2.intEntityId) ON D.intVendorId = E1.intEntityVendorId
	INNER JOIN tblICItemLocation loc ON B.intItemId = loc.intItemId AND A.intLocationId = loc.intLocationId
	LEFT JOIN tblSMShipVia F ON D.intShipViaId = F.intShipViaID
	LEFT JOIN tblSMTerm G ON D.intTermsId = G.intTermID
WHERE strReceiptType = 'Purchase Order' AND ysnPosted = 1