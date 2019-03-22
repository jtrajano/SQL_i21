CREATE VIEW [dbo].[vyuICGetInventoryReceiptChargeTax]
	AS

 SELECT ReceiptChargeTax.intInventoryReceiptChargeTaxId,
	ReceiptChargeTax.intInventoryReceiptChargeId,
	ReceiptCharge.intInventoryReceiptId,
	ReceiptCharge.intChargeId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	ReceiptChargeTax.intTaxGroupId,
	TaxGroup.strTaxGroup,
	ReceiptChargeTax.intTaxClassId,
	TaxClass.strTaxClass,
	ReceiptChargeTax.intTaxCodeId,
	TaxCode.strTaxCode,
	ReceiptChargeTax.strTaxableByOtherTaxes,
	ReceiptChargeTax.strCalculationMethod,
	ReceiptChargeTax.dblRate,
	ReceiptChargeTax.dblTax,
	ReceiptChargeTax.dblAdjustedTax,
	ReceiptChargeTax.intTaxAccountId,
	ReceiptChargeTax.ysnTaxAdjusted,
	ReceiptChargeTax.ysnTaxOnly,
	ReceiptChargeTax.ysnCheckoffTax,
	ReceiptChargeTax.intSort,
	ReceiptChargeTax.dblQty,
	ReceiptChargeTax.dblCost,
	ReceiptChargeTax.intUnitMeasureId,
	UnitMeasure.strUnitMeasure
FROM tblICInventoryReceiptChargeTax ReceiptChargeTax
	LEFT JOIN tblICInventoryReceiptCharge ReceiptCharge ON ReceiptCharge.intInventoryReceiptChargeId = ReceiptChargeTax.intInventoryReceiptChargeId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ReceiptChargeTax.intTaxGroupId
	LEFT JOIN tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = ReceiptChargeTax.intTaxClassId
	LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = ReceiptChargeTax.intTaxCodeId
	LEFT JOIN tblSMTaxCodeRate TaxCodeRate ON TaxCodeRate.intTaxCodeId = TaxCode.intTaxCodeId
		AND TaxCodeRate.intUnitMeasureId = ReceiptChargeTax.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = ReceiptChargeTax.intUnitMeasureId
GO
