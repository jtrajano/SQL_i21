CREATE VIEW [dbo].[vyuICGetInventoryReceiptCharge]
	AS 

SELECT ReceiptCharge.intInventoryReceiptChargeId
	, ReceiptCharge.intInventoryReceiptId
	, Charge.strItemNo
	, strItemDescription = Charge.strDescription
	, ReceiptCharge.ysnInventoryCost
	, ReceiptCharge.strCostMethod
	, ReceiptCharge.dblRate
	, Charge.strCostUOM
	, Charge.strUnitType
	, Charge.intOnCostTypeId
	, strOnCostType = Charge.strOnCostType
	, Vendor.strVendorId
	, ReceiptCharge.dblAmount
	, ReceiptCharge.strAllocateCostBy
	, ReceiptCharge.strCostBilledBy
FROM tblICInventoryReceiptCharge ReceiptCharge
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityVendorId = ReceiptCharge.intEntityVendorId