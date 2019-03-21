CREATE VIEW [dbo].[vyuARTaxDetailReport]
AS 
SELECT TAXDETAIL.*
     , SMT.strTaxCode
	 , SMT.strDescription
	 , TC.strTaxClass
FROM (
	SELECT intTransactionDetailTaxId	= IDT.intInvoiceDetailTaxId
		 , intTransactionDetailId		= IDT.intInvoiceDetailId
		 , intTransactionId				= ID.intInvoiceId
		 , dblAdjustedTax				= IDT.dblAdjustedTax
		 , dblRate						= IDT.dblRate
		 , intTaxCodeId					= IDT.intTaxCodeId
		 , strCalculationMethod			= IDT.strCalculationMethod
		 , dblComputedGrossPrice		= ISNULL(ID.dblComputedGrossPrice, 0)
		 , strTaxTransactionType		= 'Invoice' COLLATE Latin1_General_CI_AS
	FROM tblARInvoiceDetailTax IDT 	
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN (
		SELECT DISTINCT intInvoiceId
		FROM tblARInvoiceReportStagingTable
	) STAGING ON ID.intInvoiceId = STAGING.intInvoiceId
	WHERE (IDT.ysnTaxExempt = 1 OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , intTransactionId				= 0
		 , dblAdjustedTax				= SDT.dblAdjustedTax
		 , dblRate						= SDT.dblRate
		 , intTaxCodeId					= SDT.intTaxCodeId
		 , strCalculationMethod			= SDT.strCalculationMethod
		 , dblComputedGrossPrice		= 0
		 , strTaxTransactionType   		= 'Sales Order' COLLATE Latin1_General_CI_AS
	FROM tblSOSalesOrderDetailTax SDT
	WHERE SDT.dblAdjustedTax <> 0
) AS TAXDETAIL
INNER JOIN tblSMTaxCode SMT ON TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId
INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId 
OUTER APPLY (
	SELECT TOP 1 strInvoiceReportName
	FROM tblARCompanyPreference
) CP