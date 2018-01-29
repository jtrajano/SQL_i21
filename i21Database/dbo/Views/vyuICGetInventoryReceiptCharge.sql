﻿CREATE VIEW [dbo].[vyuICGetInventoryReceiptCharge]
	AS 

SELECT ReceiptCharge.intInventoryReceiptChargeId
	, ReceiptCharge.intInventoryReceiptId
	, ReceiptCharge.intContractId
	, Contract.strContractNumber
	, ContractDetail.intContractSeq
	, Charge.strItemNo
	, strItemDescription = Charge.strDescription
	, ReceiptCharge.ysnInventoryCost
	, ReceiptCharge.strCostMethod
	, ReceiptCharge.dblRate
	, strCostUOM = UOM.strUnitMeasure
	, strUnitType = UOM.strUnitType
	, Currency.ysnSubCurrency -- ReceiptCharge.ysnSubCurrency
	, intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) 
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
	, strForexRateType = forexRateType.strCurrencyExchangeRateType
	, Charge.strCostType
	, ReceiptCharge.dblQuantity
FROM tblICInventoryReceiptCharge ReceiptCharge
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = ReceiptCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ReceiptCharge.intContractId	
	LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = ReceiptCharge.intContractDetailId
	LEFT JOIN tblSMTaxGroup SMTaxGroup ON SMTaxGroup.intTaxGroupId = ReceiptCharge.intTaxGroupId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Receipt.intLocationId
	LEFT JOIN tblEMEntity ReceiptVendor ON ReceiptVendor.intEntityId = Receipt.intEntityVendorId
	LEFT JOIN tblSMCurrencyExchangeRateType forexRateType ON ReceiptCharge.intForexRateTypeId = forexRateType.intCurrencyExchangeRateTypeId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId) 