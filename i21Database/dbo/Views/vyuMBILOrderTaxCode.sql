CREATE VIEW [dbo].[vyuMBILOrderTaxCode]
	AS

SELECT  TaxCode.intOrderTaxId
	, TaxCode.intOrderItemId
	, TaxCode.intItemId
	, TaxCode.intTransactionDetailTaxId
	, TaxCode.intInvoiceDetailId
	, TaxCode.intTaxGroupMasterId
	, TaxCode.intTaxGroupId
	, TaxCode.intTaxCodeId
	, TaxCode.intTaxClassId
	, TaxCode.strTaxableByOtherTaxes
	, TaxCode.strCalculationMethod
	, TaxCode.dblRate
	, TaxCode.dblExemptionPercent
	, TaxCode.dblTax
	, TaxCode.dblAdjustedTax
	, TaxCode.dblBaseAdjustedTax
	, TaxCode.intSalesTaxAccountId
	, TaxCode.ysnSeparateOnInvoice
	, TaxCode.ysnCheckoffTax
	, TaxCode.strTaxCode
	, TaxCode.ysnTaxExempt
	, TaxCode.ysnTaxOnly
	, TaxCode.ysnInvalidSetup
	, TaxCode.strTaxGroup
	, TaxCode.strNotes
	, TaxCode.intUnitMeasureId
	, TaxCode.strUnitMeasure
FROM tblMBILOrderTaxCode TaxCode

