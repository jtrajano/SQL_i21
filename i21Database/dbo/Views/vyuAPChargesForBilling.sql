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
	,[intInventoryReceiptItemId]				=	B.intInventoryReceiptItemId
	,[intInventoryReceiptChargeId]				=	B.intInventoryReceiptChargeId
	,[dblUnitCost]								=	B.dblCalculatedAmount
	,[dblTax]									=	0
	,[intAccountId]								=	
													CASE	WHEN ISNULL(A.ysnInventoryCost, 0) = 0 THEN 
																H.intAccountId
															ELSE 
																F.intAccountId
													END 
	,[strAccountId]								=	
													CASE	WHEN ISNULL(A.ysnInventoryCost, 0) = 0 THEN 
																H.strAccountId
															ELSE 
																F.strAccountId
													END 

	,[strName]									=	E2.strName
	,[strVendorId]								=	E.strVendorId
FROM tblICInventoryReceiptCharge A
INNER JOIN tblICInventoryReceiptChargePerItem B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
INNER JOIN tblICItem C ON B.intChargeId = C.intItemId
INNER JOIN tblICInventoryReceiptItem G ON B.intInventoryReceiptItemId = G.intInventoryReceiptItemId
INNER JOIN tblICItem C1 ON G.intItemId = C1.intItemId
INNER JOIN tblICInventoryReceipt D ON A.intInventoryReceiptId = D.intInventoryReceiptId
INNER JOIN (tblAPVendor E INNER JOIN tblEntity E2 ON E.intEntityVendorId = E2.intEntityId) ON (CASE WHEN A.ysnAccrue = 1 THEN ISNULL(A.intEntityVendorId, D.intEntityVendorId) ELSE NULL END) = E.intEntityVendorId
LEFT JOIN tblGLAccount F ON [dbo].[fnGetItemGLAccount](C1.intItemId, D.intLocationId, 'AP Clearing') = F.intAccountId
LEFT JOIN tblGLAccount H ON [dbo].[fnGetItemGLAccount](C.intItemId, D.intLocationId, 'Other Charge Expense') = H.intAccountId
WHERE	A.ysnAccrue = 1 
		AND B.dblAmountBilled != B.dblCalculatedAmount