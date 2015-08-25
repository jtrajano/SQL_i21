CREATE VIEW [dbo].[vyuAPChargesForBilling]
AS
SELECT
	[intEntityVendorId]							=	E.intEntityVendorId
	,[dtmDate]									=	D.dtmReceiptDate
	,[strReference]								=	D.strVendorRefNo
	,[strSourceNumber]							=	D.strReceiptNumber
	,[intItemId]								=	B.intChargeId
	,[strMiscDescription]						=	C.strDescription
	,[strItemNo]								=	C.strItemNo
	,[strDescription]							=	C.strDescription
	,[dblOrderQty]								=	1
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	1
	,[dblQuantityToBill]						=	1
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryReceiptItemId]				=	A.intInventoryReceiptItemId
	,[intInventoryReceiptItemAllocatedChargeId]	=	A.intInventoryReceiptItemAllocatedChargeId
	,[dblUnitCost]								=	A.dblAmount
	,[dblTax]									=	0
	,[intAccountId]								=	F.intAccountId
	,[strAccountId]								=	F.strAccountId
	,[strName]									=	E2.strName
	,[strVendorId]								=	E.strVendorId
FROM tblICInventoryReceiptItemAllocatedCharge A
INNER JOIN tblICInventoryReceiptChargePerItem B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
INNER JOIN tblICItem C ON B.intChargeId = C.intItemId
INNER JOIN tblICInventoryReceiptItem G ON A.intInventoryReceiptItemId = G.intInventoryReceiptItemId
INNER JOIN tblICItem C1 ON G.intItemId = C1.intItemId
INNER JOIN tblICInventoryReceipt D ON A.intInventoryReceiptId = D.intInventoryReceiptId
INNER JOIN (tblAPVendor E INNER JOIN tblEntity E2 ON E.intEntityVendorId = E2.intEntityId) ON (CASE WHEN A.ysnAccrue = 1 THEN ISNULL(A.intEntityVendorId, D.intEntityVendorId) ELSE NULL END) = E.intEntityVendorId
LEFT JOIN tblGLAccount F ON [dbo].[fnGetItemGLAccount](C1.intItemId, D.intLocationId, 'AP Clearing') = F.intAccountId
WHERE	A.ysnAccrue = 1 
		AND A.dblAmountBilled != A.dblAmount