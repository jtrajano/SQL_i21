CREATE VIEW [dbo].[vyuMBILInvoiceTaxCode]
	AS
	
SELECT intInvoiceTaxId
	, intInvoiceItemId
	, intItemId
	, intTransactionDetailTaxId
	, intInvoiceDetailId
	, intTaxGroupMasterId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, strTaxableByOtherTaxes
	, strCalculationMethod
	, dblRate
	, dblExemptionPercent
	, dblTax
	, dblAdjustedTax
	, dblBaseAdjustedTax
	, intSalesTaxAccountId
	, ysnSeparateOnInvoice
	, ysnCheckoffTax
	, strTaxCode
	, ysnTaxExempt
	, ysnTaxOnly
	, ysnInvalidSetup
	, strTaxGroup
	, strNotes
	, intUnitMeasureId
	, strUnitMeasure
FROM tblMBILInvoiceTaxCode