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
	ReceiptChargeTax.ysnCheckoffTax,
	ReceiptChargeTax.intSort
FROM tblICInventoryReceiptChargeTax ReceiptChargeTax
	LEFT JOIN tblICInventoryReceiptCharge ReceiptCharge ON ReceiptCharge.intInventoryReceiptChargeId = ReceiptChargeTax.intInventoryReceiptChargeId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptCharge.intChargeId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ReceiptChargeTax.intTaxGroupId
	LEFT JOIN tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = ReceiptChargeTax.intTaxClassId
	LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = ReceiptChargeTax.intTaxCodeId
GO
