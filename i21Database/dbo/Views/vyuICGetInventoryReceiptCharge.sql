﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptCharge]
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
	, ReceiptCharge.ysnSubCurrency
	--, ReceiptCharge.intCurrencyId
	--, Currency.strCurrency
	, Charge.intOnCostTypeId
	, strOnCostType = Charge.strOnCostType
	, ReceiptCharge.dblAmount
	, ReceiptCharge.strAllocateCostBy
	, ReceiptCharge.ysnAccrue
	, ReceiptCharge.intEntityVendorId
	, Vendor.strVendorId
	, Vendor.strName AS strVendorName
	, ReceiptCharge.ysnPrice
FROM tblICInventoryReceiptCharge ReceiptCharge
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN vyuAPVendor Vendor ON Vendor.intEntityVendorId = ReceiptCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ReceiptCharge.intContractId
	--LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ReceiptCharge.intCurrencyId