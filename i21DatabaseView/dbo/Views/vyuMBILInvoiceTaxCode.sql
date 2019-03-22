CREATE VIEW [dbo].[vyuMBILInvoiceTaxCode]
	AS
	
SELECT InvoiceTax.intInvoiceTaxId
	, InvoiceTax.intInvoiceItemId
	, InvoiceTax.intItemId
	, InvoiceTax.intTransactionDetailTaxId
	, InvoiceTax.intInvoiceDetailId
	, InvoiceTax.intTaxGroupMasterId
	, InvoiceTax.intTaxGroupId
	, InvoiceTax.intTaxCodeId
	, InvoiceTax.intTaxClassId
	, InvoiceTax.strTaxableByOtherTaxes
	, InvoiceTax.strCalculationMethod
	, InvoiceTax.dblRate
	, InvoiceTax.dblExemptionPercent
	, InvoiceTax.dblTax
	, InvoiceTax.dblAdjustedTax
	, InvoiceTax.dblBaseAdjustedTax
	, InvoiceTax.intSalesTaxAccountId
	, InvoiceTax.ysnSeparateOnInvoice
	, InvoiceTax.ysnCheckoffTax
	, InvoiceTax.strTaxCode
	, InvoiceTax.ysnTaxExempt
	, InvoiceTax.ysnTaxOnly
	, InvoiceTax.ysnInvalidSetup
	, InvoiceTax.strTaxGroup
	, InvoiceTax.strNotes
	, InvoiceTax.intUnitMeasureId
	, InvoiceTax.strUnitMeasure
	, InvoiceItem.intDriverId
	, InvoiceItem.strDriverNo
	, InvoiceItem.strDriverName
FROM tblMBILInvoiceTaxCode InvoiceTax
LEFT JOIN vyuMBILInvoiceItem InvoiceItem ON InvoiceItem.intInvoiceItemId = InvoiceTax.intInvoiceItemId