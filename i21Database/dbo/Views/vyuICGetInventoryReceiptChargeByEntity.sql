CREATE VIEW [dbo].[vyuICGetInventoryReceiptChargeByEntity]
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
	, intCostUnitMeasureId = UOM.intUnitMeasureId
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
	, ReceiptCharge.strChargesLink
	, ReceiptCharge.dblQuantity
	, ReceiptCharge.intConcurrencyId
	, ReceiptCharge.intChargeId
	, ReceiptCharge.intCostUOMId
	, ReceiptCharge.dblAmountBilled
	, ReceiptCharge.dblAmountPaid
	, ReceiptCharge.dblAmountPriced
	, ReceiptCharge.intSort
	, ReceiptCharge.intTaxGroupId
	, ReceiptCharge.intForexRateTypeId
	, ReceiptCharge.dblForexRate
	, Book.strBook
	, SubBook.strSubBook
    , permission.intEntityContactId
	, fiscal.strPeriod strAccountingPeriod
	, Receipt.intBookId
	, Receipt.intSubBookId
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
	LEFT JOIN tblCTBook Book ON Book.intBookId = Receipt.intBookId
	LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Receipt.intSubBookId
	CROSS APPLY (
		SELECT ec.intEntityId, ec.intEntityContactId
		FROM tblEMEntityToContact ec
			INNER JOIN tblEMEntity e ON e.intEntityId = ec.intEntityContactId
			INNER JOIN tblEMEntityLocation el ON el.intEntityLocationId = ec.intEntityLocationId
				AND el.intEntityId = ec.intEntityId
		WHERE ec.ysnPortalAccess = 1
	) permission
	CROSS APPLY (
		SELECT TOP 1 sl.intCompanyLocationSubLocationId
		FROM tblSMCompanyLocationSubLocation sl
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intSubLocationId = sl.intCompanyLocationSubLocationId
				AND ri.intInventoryReceiptId = Receipt.intInventoryReceiptId
		WHERE sl.intCompanyLocationId = Receipt.intLocationId
			AND sl.intVendorId = permission.intEntityId
	) accessibleReceipts
	OUTER APPLY (
		SELECT TOP 1 fp.strPeriod
		FROM tblGLFiscalYearPeriod fp
		WHERE Receipt.dtmReceiptDate BETWEEN fp.dtmStartDate AND fp.dtmEndDate
	) fiscal
WHERE Receipt.strReceiptType = 'Purchase Contract'
	AND Receipt.intSourceType = 2