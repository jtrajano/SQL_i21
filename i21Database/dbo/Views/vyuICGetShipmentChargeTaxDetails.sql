CREATE VIEW [dbo].[vyuICGetShipmentChargeTaxDetails]
AS

SELECT
	ChargeTax.intInventoryShipmentChargeTaxId,
	Charge.intInventoryShipmentId,
	Charge.intInventoryShipmentChargeId,
	Charge.intChargeId,
	Item.strItemNo,
	TaxGroup.strTaxGroup,
	TaxCode.strTaxCode,
	ChargeTax.strCalculationMethod,
	ChargeTax.dblRate,
	ChargeTax.dblTax,
	TaxClass.strTaxClass,
	ChargeTax.dblQty,
	ChargeTax.dblCost,
	ChargeTax.ysnCheckoffTax,
	ChargeTax.ysnTaxAdjusted
FROM	dbo.tblICInventoryShipmentChargeTax ChargeTax
		LEFT JOIN dbo.tblICInventoryShipmentCharge Charge on Charge.intInventoryShipmentChargeId = ChargeTax.intInventoryShipmentChargeId
		LEFT JOIN dbo.tblICItem Item on Item.intItemId = Charge.intChargeId 
		LEFT JOIN dbo.tblSMTaxGroup TaxGroup on TaxGroup.intTaxGroupId = ChargeTax.intTaxGroupId			
		LEFT JOIN dbo.tblSMTaxCode TaxCode on TaxCode.intTaxCodeId = ChargeTax.intTaxCodeId
		LEFT JOIN dbo.tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = TaxCode.intTaxClassId
