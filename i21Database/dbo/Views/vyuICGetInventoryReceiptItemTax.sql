CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemTax]
	AS

SELECT ReceiptItemTax.intInventoryReceiptItemTaxId,
	ReceiptItemTax.intInventoryReceiptItemId,
	ReceiptItem.intInventoryReceiptId,
	ReceiptItem.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	ReceiptItemTax.intTaxGroupMasterId,
	ReceiptItemTax.intTaxGroupId,
	ReceiptItemTax.intTaxCodeId,
	ReceiptItemTax.intTaxClassId,
	ReceiptItemTax.strTaxableByOtherTaxes,
	ReceiptItemTax.strCalculationMethod,
	ReceiptItemTax.dblRate,
	ReceiptItemTax.dblTax,
	ReceiptItemTax.dblAdjustedTax,
	ReceiptItemTax.intTaxAccountId,
	ReceiptItemTax.ysnTaxAdjusted,
	ReceiptItemTax.ysnSeparateOnInvoice,
	ReceiptItemTax.ysnCheckoffTax,
	ReceiptItemTax.strTaxCode,
	ReceiptItemTax.intSort
FROM tblICInventoryReceiptItemTax ReceiptItemTax
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemTax.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId