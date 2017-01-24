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
	, strCostUOM = UOM.strUnitMeasure
	, strUnitType = UOM.strUnitType
	, Currency.ysnSubCurrency -- ReceiptCharge.ysnSubCurrency
	, ReceiptCharge.intCurrencyId
	, Currency.strCurrency
	, Charge.intOnCostTypeId
	, strOnCostType = Charge.strOnCostType
	, ReceiptCharge.dblAmount
	, ReceiptCharge.strAllocateCostBy
	, ReceiptCharge.ysnAccrue
	, ReceiptCharge.intEntityVendorId
	, Vendor.strVendorId
	, Vendor.strName AS strVendorName
	, ReceiptCharge.ysnPrice
	, Currency.intCent
	, strTaxGroup = SMTaxGroup.strTaxGroup
	, ReceiptCharge.dblTax
	, Receipt.strReceiptNumber
	, Receipt.dtmReceiptDate
	, Location.strLocationName
	, Receipt.strBillOfLading
	, strReceiptVendor = ReceiptVendor.strName
FROM tblICInventoryReceiptCharge ReceiptCharge
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN vyuAPVendor Vendor ON Vendor.intEntityVendorId = ReceiptCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ReceiptCharge.intContractId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ReceiptCharge.intCurrencyId
	LEFT JOIN tblSMTaxGroup SMTaxGroup ON SMTaxGroup.intTaxGroupId = ReceiptCharge.intTaxGroupId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblEMEntity ReceiptVendor ON ReceiptVendor.intEntityId = Receipt.intEntityVendorId