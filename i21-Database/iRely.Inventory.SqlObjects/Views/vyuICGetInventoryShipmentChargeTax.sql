CREATE VIEW [dbo].[vyuICGetInventoryShipmentChargeTax]
AS

 SELECT 
	ShipmentChargeTax.intInventoryShipmentChargeTaxId
	,ShipmentChargeTax.intInventoryShipmentChargeId
	,ShipmentCharge.intInventoryShipmentId
	,ShipmentCharge.intChargeId
	,Item.strItemNo
	,strItemDescription = Item.strDescription
	,ShipmentChargeTax.intTaxGroupId
	,TaxGroup.strTaxGroup
	,ShipmentChargeTax.intTaxClassId
	,TaxClass.strTaxClass
	,ShipmentChargeTax.intTaxCodeId
	,TaxCode.strTaxCode
	,ShipmentChargeTax.strTaxableByOtherTaxes
	,ShipmentChargeTax.strCalculationMethod
	,ShipmentChargeTax.dblRate
	,ShipmentChargeTax.dblTax
	,ShipmentChargeTax.dblAdjustedTax
	,ShipmentChargeTax.intTaxAccountId
	,ShipmentChargeTax.ysnTaxAdjusted
	,ShipmentChargeTax.ysnTaxOnly
	,ShipmentChargeTax.ysnCheckoffTax
	,ShipmentChargeTax.intSort
	,ShipmentChargeTax.dblQty
	,ShipmentChargeTax.dblCost
FROM tblICInventoryShipmentChargeTax ShipmentChargeTax
	LEFT JOIN tblICInventoryShipmentCharge ShipmentCharge ON ShipmentCharge.intInventoryShipmentChargeId = ShipmentChargeTax.intInventoryShipmentChargeId
	LEFT JOIN tblICItem Item ON Item.intItemId = ShipmentCharge.intChargeId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ShipmentChargeTax.intTaxGroupId
	LEFT JOIN tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = ShipmentChargeTax.intTaxClassId
	LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = ShipmentChargeTax.intTaxCodeId
