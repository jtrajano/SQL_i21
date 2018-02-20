CREATE VIEW [dbo].[vyuICGetChargeTaxDetails]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intInventoryReceiptChargeTaxId) AS INT)
, * 
FROM (
	SELECT
		ChargeTax.intInventoryReceiptChargeTaxId,
		Charge.intInventoryReceiptId,
		Charge.intInventoryReceiptChargeId,
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
	FROM	dbo.tblICInventoryReceiptChargeTax ChargeTax
			LEFT JOIN dbo.tblICInventoryReceiptCharge Charge on Charge.intInventoryReceiptChargeId = ChargeTax.intInventoryReceiptChargeId
			LEFT JOIN dbo.tblICItem Item on Item.intItemId = Charge.intChargeId 
			LEFT JOIN dbo.tblSMTaxGroup TaxGroup on TaxGroup.intTaxGroupId = ChargeTax.intTaxGroupId			
			LEFT JOIN dbo.tblSMTaxCode TaxCode on TaxCode.intTaxCodeId = ChargeTax.intTaxCodeId
			LEFT JOIN dbo.tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = TaxCode.intTaxClassId
			LEFT JOIN tblSMTaxCodeRate TaxCodeRate ON TaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId
				AND TaxCodeRate.intUnitMeasureId = ChargeTax.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ChargeTax.intUnitMeasureId
			LEFT JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
) tblChargeTaxDetails