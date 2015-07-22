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
,B.strMiscDescription
,C.strItemNo
,C.strDescription
,tblReceived.dblOrderQty
,tblReceived.dblPOOpenReceive --uom converted received quantity from po to IR
,tblReceived.dblOpenReceive
,(tblReceived.dblPOOpenReceive - tblReceived.dblQuantityBilled) AS dblQuantityToBill
,tblReceived.dblQuantityBilled
,tblReceived.intLineNo
,tblReceived.intInventoryReceiptItemId
,tblReceived.dblUnitCost
,tblReceived.intAccountId
,tblReceived.strAccountId
,D2.strName
,D1.strVendorId
,E.strShipVia
,F.strTerm
,G1.intContractNumber
,G1.intContractHeaderId
,G2.intContractDetailId
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
			,dblQuantityBilled = SUM(ISNULL(B1.dblBillQty, 0))
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
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
	LEFT JOIN tblSMTerm F ON A.intTermsId = F.intTermID
	LEFT JOIN (tblCTContractHeader G1 INNER JOIN tblCTContractDetail G2 ON G1.intContractHeaderId = G2.intContractHeaderId) 
			ON G1.intEntityId = D1.intEntityVendorId AND B.intItemId = G2.intItemId AND B.intContractDetailId = G2.intContractDetailId
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
,B.strMiscDescription
,C.strItemNo
,C.strDescription
,B.dblQtyOrdered
,B.dblQtyOrdered -B.dblQtyReceived
,B.dblQtyOrdered
,B.dblQtyOrdered -B.dblQtyReceived
,B.dblQtyReceived
,B.intPurchaseDetailId
,NULL --this should be null as this has constraint from IR Receipt item
,B.dblCost
,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory')
,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, loc.intItemLocationId, 'Inventory'))
,D2.strName
,D1.strVendorId
,E.strShipVia
,F.strTerm
,NULL
,NULL
,NULL
FROM tblPOPurchase A
	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intShipToId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
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
,C.strDescription
,C.strItemNo
,C.strDescription
,B.dblOpenReceive
,B.dblReceived
,B.dblOpenReceive
,(B.dblOpenReceive - B.dblBillQty)
,B.dblBillQty
,B.intInventoryReceiptItemId
,B.intInventoryReceiptItemId
,B.dblUnitCost
,intAccountId = [dbo].[fnGetItemGLAccount](B.intItemId, A.intLocationId, 'Inventory')
,strAccountId = (SELECT strAccountId FROM tblGLAccount WHERE intAccountId = dbo.fnGetItemGLAccount(B.intItemId, A.intLocationId, 'Inventory'))
,D2.strName
,D1.strVendorId
,E.strShipVia
,NULL
,F1.intContractNumber
,F1.intContractHeaderId
,CASE WHEN A.strReceiptType = 'Purchase Contract' THEN B.intLineNo ELSE NULL END
FROM tblICInventoryReceipt A
INNER JOIN tblICInventoryReceiptItem B
	ON A.intInventoryReceiptId = B.intInventoryReceiptId
INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	--INNER JOIN tblICItemLocation loc ON C.intItemId = loc.intItemId AND loc.intLocationId = A.intLocationId
INNER JOIN  (tblAPVendor D1 INNER JOIN tblEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
LEFT JOIN tblSMShipVia E ON A.intShipViaId = E.[intEntityShipViaId]
LEFT JOIN (tblCTContractHeader F1 INNER JOIN tblCTContractDetail F2 ON F1.intContractHeaderId = F2.intContractHeaderId) ON F1.intContractHeaderId = F2.intContractHeaderId
WHERE A.strReceiptType IN ('Direct','Purchase Contract') AND A.ysnPosted = 1 AND B.dblBillQty != B.dblOpenReceive