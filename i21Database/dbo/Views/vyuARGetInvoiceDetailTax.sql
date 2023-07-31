CREATE VIEW [dbo].[vyuARGetInvoiceDetailTax]
AS
SELECT intInvoiceDetailTaxId			= IDT.intInvoiceDetailTaxId
     , intInvoiceDetailId				= IDT.intInvoiceDetailId 
     , intTaxGroupId					= IDT.intTaxGroupId
     , strTaxGroup						= TG.strTaxGroup
     , intTaxCodeId						= IDT.intTaxCodeId
     , strTaxCode						= TC.strTaxCode
     , intTaxClassId					= IDT.intTaxClassId
     , strTaxableByOtherTaxes			= IDT.strTaxableByOtherTaxes
     , strCalculationMethod				= IDT.strCalculationMethod
     , dblRate							= IDT.dblRate
     , dblBaseRate						= IDT.dblBaseRate
     , dblExemptionPercent				= IDT.dblExemptionPercent
     , dblTax							= IDT.dblTax
     , dblAdjustedTax					= IDT.dblAdjustedTax
     , dblBaseAdjustedTax				= IDT.dblBaseAdjustedTax
     , intSalesTaxAccountId				= IDT.intSalesTaxAccountId
     , intSalesTaxExemptionAccountId	= IDT.intSalesTaxExemptionAccountId
     , ysnTaxAdjusted					= IDT.ysnTaxAdjusted
     , ysnSeparateOnInvoice				= IDT.ysnSeparateOnInvoice
     , ysnCheckoffTax 					= IDT.ysnCheckoffTax
     , ysnTaxExempt 					= IDT.ysnTaxExempt
     , ysnInvalidSetup 					= IDT.ysnInvalidSetup
     , ysnTaxOnly 						= IDT.ysnTaxOnly
     , ysnAddToCost 					= IDT.ysnAddToCost
     , strNotes 						= IDT.strNotes
     , intUnitMeasureId 				= IDT.intUnitMeasureId
     , strUnitMeasure 					= UM.strUnitMeasure
     , strTaxClass 						= TCC.strTaxClass
     , ysnOverrideTaxGroup 				= ID.ysnOverrideTaxGroup
     , intConcurrencyId 				= IDT.intConcurrencyId
FROM tblARInvoiceDetailTax IDT
INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblSMTaxGroup TG ON IDT.intTaxGroupId = TG.intTaxGroupId
INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
INNER JOIN tblSMTaxClass TCC ON IDT.intTaxClassId = TCC.intTaxClassId
LEFT JOIN tblICUnitMeasure UM ON IDT.intUnitMeasureId = UM.intUnitMeasureId