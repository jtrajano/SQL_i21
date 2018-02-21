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
	ChargeTax.ysnTaxAdjusted,
	ChargeTax.intUnitMeasureId,
	UnitMeasure.strUnitMeasure
FROM	dbo.tblICInventoryShipmentChargeTax ChargeTax
		LEFT JOIN dbo.tblICInventoryShipmentCharge Charge on Charge.intInventoryShipmentChargeId = ChargeTax.intInventoryShipmentChargeId
		LEFT JOIN dbo.tblICItem Item on Item.intItemId = Charge.intChargeId 
		LEFT JOIN dbo.tblSMTaxGroup TaxGroup on TaxGroup.intTaxGroupId = ChargeTax.intTaxGroupId			
		LEFT JOIN dbo.tblSMTaxCode TaxCode on TaxCode.intTaxCodeId = ChargeTax.intTaxCodeId
		LEFT JOIN dbo.tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = TaxCode.intTaxClassId
		LEFT JOIN tblSMTaxCodeRate TaxCodeRate ON TaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId
			AND TaxCodeRate.intUnitMeasureId = ChargeTax.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ChargeTax.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
