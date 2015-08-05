CREATE VIEW [dbo].[vyuICGetInventoryShipmentCharge]
	AS 

SELECT ShipmentCharge.intInventoryShipmentChargeId
	, ShipmentCharge.intInventoryShipmentId
	, ShipmentCharge.intContractId
	, Contract.intContractNumber
	, Charge.strItemNo
	, strItemDescription = Charge.strDescription
	, ShipmentCharge.strCostMethod
	, ShipmentCharge.dblRate
	, Charge.strCostUOM
	, Charge.strUnitType
	, Charge.intOnCostTypeId
	, strOnCostType = Charge.strOnCostType
	, ShipmentCharge.intEntityVendorId
	, Vendor.strVendorId
	, ShipmentCharge.dblAmount
	, ShipmentCharge.strCostBilledBy
FROM tblICInventoryShipmentCharge ShipmentCharge
	LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ShipmentCharge.intChargeId
	LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityVendorId = ShipmentCharge.intEntityVendorId
	LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ShipmentCharge.intContractId