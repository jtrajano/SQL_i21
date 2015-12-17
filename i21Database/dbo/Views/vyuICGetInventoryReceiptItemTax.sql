CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemTax]
	AS

 SELECT ReceiptItemTax.intInventoryReceiptItemTaxId,
	ReceiptItemTax.intInventoryReceiptItemId,
	ReceiptItem.intInventoryReceiptId,
	ReceiptItem.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	ReceiptItemTax.intTaxGroupId,
	TaxGroup.strTaxGroup,
	ReceiptItemTax.intTaxClassId,
	TaxClass.strTaxClass,
	ReceiptItemTax.intTaxCodeId,
	TaxCode.strTaxCode,
	ReceiptItemTax.strTaxableByOtherTaxes,
	ReceiptItemTax.strCalculationMethod,
	ReceiptItemTax.dblRate,
	ReceiptItemTax.dblTax,
	ReceiptItemTax.dblAdjustedTax,
	ReceiptItemTax.intTaxAccountId,
	ReceiptItemTax.ysnTaxAdjusted,
	ReceiptItemTax.ysnSeparateOnInvoice,
	ReceiptItemTax.ysnCheckoffTax,
	ReceiptItemTax.intSort
FROM tblICInventoryReceiptItemTax ReceiptItemTax
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemTax.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
	LEFT JOIN tblSMTaxGroup TaxGroup ON TaxGroup.intTaxGroupId = ReceiptItemTax.intTaxGroupId
	LEFT JOIN tblSMTaxClass TaxClass ON TaxClass.intTaxClassId = ReceiptItemTax.intTaxClassId
	LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = ReceiptItemTax.intTaxCodeId
