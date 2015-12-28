CREATE VIEW [dbo].[vyuAPChargesForBilling]
AS
SELECT
	 [intInventoryReceiptId]					=	ReceiptCharge.intInventoryReceiptId
	,[intEntityVendorId]						=	Vendor.intEntityVendorId
	,[dtmDate]									=	Receipt.dtmReceiptDate
	,[strReference]								=	Receipt.strVendorRefNo
	,[strSourceNumber]							=	Receipt.strReceiptNumber
	,[intItemId]								=	Item.intItemId
	,[strMiscDescription]						=	Item.strDescription
	,[strItemNo]								=	Item.strItemNo
	,[strDescription]							=	Item.strDescription
	,[dblOrderQty]								=	1
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	1
	,[dblQuantityToBill]						=	1
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryReceiptItemId]				=	NULL 
	,[intInventoryReceiptChargeId]				=	ReceiptCharge.intInventoryReceiptChargeId
	,[dblUnitCost]								=	ReceiptCharge.dblAmount
	,[dblTax]									=	0
	,[intAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.intAccountId 
															ELSE 																
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.intAccountId
																	FROM	tblICInventoryReceiptChargePerItem ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 
	,[strAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.strAccountId
															ELSE 
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.strAccountId
																	FROM	tblICInventoryReceiptChargePerItem ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 

	,[strName]									=	Entity.strName
	,[strVendorId]								=	Vendor.strVendorId
FROM tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICItem Item 
		ON ReceiptCharge.intChargeId = Item.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON ReceiptCharge.intInventoryReceiptId = Receipt.intInventoryReceiptId
	INNER JOIN (
		tblAPVendor Vendor INNER JOIN tblEntity Entity
			ON Vendor.intEntityVendorId = Entity.intEntityId
	) 
		ON Vendor.intEntityVendorId = ISNULL(ReceiptCharge.intEntityVendorId,  Receipt.intEntityVendorId) 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId = Receipt.intLocationId

	LEFT JOIN tblGLAccount OtherChargeExpense
		ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'Other Charge Expense') = OtherChargeExpense.intAccountId

	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
	--LEFT JOIN tblGLAccount OtherChargeAPClearing
	--	ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId

WHERE	ReceiptCharge.ysnAccrue = 1 
		AND ISNULL(Receipt.ysnPosted, 0) = 1
		AND ISNULL(ReceiptCharge.dblAmountBilled, 0) < ROUND(ReceiptCharge.dblAmount, 6) 