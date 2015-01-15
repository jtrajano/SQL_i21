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
	,A.intSourceId
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
FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblPOPurchase D ON A.intSourceId = D.intPurchaseId
	INNER JOIN  (tblAPVendor E1 INNER JOIN tblEntity E2 ON E1.intEntityId = E2.intEntityId) ON D.intVendorId = E1.intVendorId
	LEFT JOIN tblSMShipVia F ON D.intShipViaId = F.intShipViaID
	LEFT JOIN tblSMTerm G ON D.intTermsId = G.intTermID
WHERE strReceiptType = 'Purchase Order' AND ysnPosted = 1