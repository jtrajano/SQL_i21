CREATE VIEW [dbo].[vyuICGetInventoryReceiptCharge]
	AS 

SELECT ReceiptCharge.intInventoryReceiptChargeId
	, ReceiptCharge.intInventoryReceiptId
	, ReceiptCharge.intContractId
	, Contract.strContractNumber
	, Charge.strItemNo
	, strItemDescription = Charge.strDescription
	, ReceiptCharge.ysnInventoryCost
	, ReceiptCharge.strCostMethod
	, ReceiptCharge.dblRate
	, Charge.strCostUOM
	, Charge.strUnitType
	, Charge.intOnCostTypeId
	, strOnCostType = Charge.strOnCostType
	, ReceiptCharge.dblAmount
	, ReceiptCharge.strAllocateCostBy
	, ReceiptCharge.ysnAccrue
	, ReceiptCharge.intEntityVendorId
	, Vendor.strVendorId
	, ReceiptCharge.ysnPrice
FROM tblICInventoryReceiptCharge ReceiptCharge
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityVendorId = ReceiptCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ReceiptCharge.intContractId