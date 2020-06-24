CREATE VIEW [dbo].[vyuICGetInventoryShipmentCharge]
AS 

SELECT ShipmentCharge.intInventoryShipmentChargeId
	, ShipmentCharge.intInventoryShipmentId
	, ShipmentCharge.intContractId
	, ShipmentCharge.intContractDetailId
	, ShipmentCharge.intChargeId
	, ContractHeader.strContractNumber
	, Charge.strItemNo
	, Charge.intItemId
	, strItemDescription = Charge.strDescription
	, ShipmentCharge.strChargesLink
	, ShipmentCharge.strCostMethod
	, ShipmentCharge.dblRate
	, ShipmentCharge.intCostUOMId
	, strCostUOM = UOM.strUnitMeasure
	, Charge.strUnitType
	, ShipmentCharge.intCurrencyId
	, Currency.strCurrency
	, Charge.intOnCostTypeId
	, Charge.ysnPrice
	, strOnCostType = Charge.strOnCostType
	, ShipmentCharge.dblAmount
	, ShipmentCharge.dblAmountBilled
    , ShipmentCharge.dblAmountPaid
	, ShipmentCharge.dblAmountPriced
	, ShipmentCharge.dblTax
	, ShipmentCharge.intTaxGroupId
	, ShipmentCharge.strAllocatePriceBy
	, ShipmentCharge.ysnAccrue
	, ShipmentCharge.intEntityVendorId
	, Vendor.strVendorId
	, strVendorName = Vendor.strName
	, strForexRateType = forexRateType.strCurrencyExchangeRateType
	, dblForexRate = ShipmentCharge.dblForexRate
	, intForexRateTypeId = ShipmentCharge.intForexRateTypeId
	, ShipmentCharge.dblQuantity
	, Charge.strCostType
	, strTaxGroup = SMTaxGroup.strTaxGroup
	, ShipmentCharge.intConcurrencyId
	, Shipment.strShipmentNumber
	, Shipment.strShipFromLocation
	, Shipment.strBOLNumber
	, Shipment.strCustomerName
	, Shipment.strCustomerNumber
	, Charge.ysnInventoryCost
	, Shipment.dtmShipDate
FROM tblICInventoryShipmentCharge ShipmentCharge
	INNER JOIN vyuICGetInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ShipmentCharge.intChargeId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = ShipmentCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = ShipmentCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ShipmentCharge.intContractId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ShipmentCharge.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType forexRateType ON ShipmentCharge.intForexRateTypeId = forexRateType.intCurrencyExchangeRateTypeId
	LEFT JOIN tblSMTaxGroup SMTaxGroup ON SMTaxGroup.intTaxGroupId = ShipmentCharge.intTaxGroupId