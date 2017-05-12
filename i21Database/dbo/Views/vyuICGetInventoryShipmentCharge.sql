CREATE VIEW [dbo].[vyuICGetInventoryShipmentCharge]
	AS 

SELECT ShipmentCharge.intInventoryShipmentChargeId
	, ShipmentCharge.intInventoryShipmentId
	, ShipmentCharge.intContractId
	, Contract.strContractNumber
	, Charge.strItemNo
	, Charge.intItemId
	, strItemDescription = Charge.strDescription
	, ShipmentCharge.strCostMethod
	, ShipmentCharge.dblRate
	, strCostUOM = UOM.strUnitMeasure
	, Charge.strUnitType
	, ShipmentCharge.intCurrencyId
	, Currency.strCurrency
	, Charge.intOnCostTypeId
	, Charge.ysnPrice
	, strOnCostType = Charge.strOnCostType
	, ShipmentCharge.dblAmount
	, ShipmentCharge.strAllocatePriceBy
	, ShipmentCharge.ysnAccrue
	, ShipmentCharge.intEntityVendorId
	, Vendor.strVendorId
	, strVendorName = Vendor.strName
	, strForexRateType = forexRateType.strCurrencyExchangeRateType
	, dblForexRate = ShipmentCharge.dblForexRate
	, intForexRateTypeId = ShipmentCharge.intForexRateTypeId
FROM tblICInventoryShipmentCharge ShipmentCharge
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ShipmentCharge.intChargeId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = ShipmentCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = ShipmentCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ShipmentCharge.intContractId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ShipmentCharge.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType forexRateType ON ShipmentCharge.intForexRateTypeId = forexRateType.intCurrencyExchangeRateTypeId