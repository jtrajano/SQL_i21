﻿CREATE VIEW [dbo].[vyuICGetInventoryShipmentCharge]
	AS 

SELECT ShipmentCharge.intInventoryShipmentChargeId
	, ShipmentCharge.intInventoryShipmentId
	, ShipmentCharge.intContractId
	, Contract.strContractNumber
	, Charge.strItemNo
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
	, ShipmentCharge.ysnAccrue
	, ShipmentCharge.intEntityVendorId
	, Vendor.strVendorId
FROM tblICInventoryShipmentCharge ShipmentCharge
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ShipmentCharge.intChargeId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = ShipmentCharge.intCostUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CostUOM.intUnitMeasureId
	LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityVendorId = ShipmentCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ShipmentCharge.intContractId
	LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ShipmentCharge.intCurrencyId