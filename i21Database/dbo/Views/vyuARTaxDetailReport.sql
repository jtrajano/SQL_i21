CREATE VIEW [dbo].[vyuARTaxDetailReport]
AS 
SELECT TAXDETAIL.*
     , SMT.strTaxCode
	 , SMT.strDescription
FROM (
	SELECT intTransactionDetailTaxId	= IDT.intInvoiceDetailTaxId
		 , intTransactionDetailId		= IDT.intInvoiceDetailId
		 , dblAdjustedTax				= IDT.dblAdjustedTax
		 , dblRate						= IDT.dblRate
		 , intTaxCodeId					= IDT.intTaxCodeId
		 , strCalculationMethod			= IDT.strCalculationMethod
		 , strTaxTransactionType		= 'Invoice' COLLATE Latin1_General_CI_AS
	FROM tblARInvoiceDetailTax IDT 	
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN (
		SELECT DISTINCT intInvoiceId
		FROM tblARInvoiceReportStagingTable
	) STAGING ON ID.intInvoiceId = STAGING.intInvoiceId
	WHERE IDT.dblAdjustedTax <> 0 
	  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , dblAdjustedTax				= SDT.dblAdjustedTax
		 , dblRate						= SDT.dblRate
		 , intTaxCodeId					= SDT.intTaxCodeId
		 , strCalculationMethod			= SDT.strCalculationMethod
		 , strTaxTransactionType   		= 'Sales Order' COLLATE Latin1_General_CI_AS
	FROM tblSOSalesOrderDetailTax SDT
	WHERE SDT.dblAdjustedTax <> 0
) AS TAXDETAIL
LEFT JOIN tblSMTaxCode SMT ON
       TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId 
