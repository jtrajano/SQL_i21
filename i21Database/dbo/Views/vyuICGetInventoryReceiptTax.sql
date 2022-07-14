CREATE VIEW [dbo].[vyuICGetInventoryReceiptTax]
AS

SELECT 
	ReceiptTax.intInventoryReceiptTaxId
	,intInventoryReceiptItemId = CAST(NULL AS INT) 
	,ReceiptTax.intInventoryReceiptId
	,intItemId = NULL 
	,strItemNo = NULL 
	,strItemDescription = NULL 
	,ReceiptTax.intTaxGroupId
	,TaxGroup.strTaxGroup
	,ReceiptTax.intTaxClassId
	,TaxClass.strTaxClass
	,ReceiptTax.intTaxCodeId
	,TaxCode.strTaxCode
	,ReceiptTax.strTaxableByOtherTaxes
	,ReceiptTax.strCalculationMethod
	,ReceiptTax.dblRate
	,ReceiptTax.dblTax
	,ReceiptTax.dblAdjustedTax
	,ReceiptTax.intTaxAccountId
	,ReceiptTax.ysnTaxAdjusted
	,ReceiptTax.ysnTaxOnly
	,ReceiptTax.ysnSeparateOnInvoice
	,ReceiptTax.ysnCheckoffTax
	,ReceiptTax.intSort
	,ReceiptTax.dblQty
	,ReceiptTax.dblCost
	,ReceiptTax.intUnitMeasureId
	,UnitMeasure.strUnitMeasure
FROM 
	tblICInventoryReceiptTax ReceiptTax 
	LEFT JOIN tblSMTaxGroup TaxGroup 
		ON TaxGroup.intTaxGroupId = ReceiptTax.intTaxGroupId
	LEFT JOIN tblSMTaxClass TaxClass 
		ON TaxClass.intTaxClassId = ReceiptTax.intTaxClassId
	LEFT JOIN tblSMTaxCode TaxCode 
		ON TaxCode.intTaxCodeId = ReceiptTax.intTaxCodeId
	LEFT JOIN tblICItemUOM ItemUOM 
		ON ItemUOM.intItemUOMId = ReceiptTax.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UnitMeasure 
		ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		
