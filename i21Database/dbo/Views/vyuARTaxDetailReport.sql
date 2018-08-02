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
		 , strTaxTransactionType		= 'Invoice'
	FROM tblARInvoiceDetailTax IDT 	
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	WHERE IDT.dblAdjustedTax <> 0 
	  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , dblAdjustedTax				= SDT.dblAdjustedTax
		 , dblRate						= SDT.dblRate
		 , intTaxCodeId					= SDT.intTaxCodeId
		 , strCalculationMethod			= SDT.strCalculationMethod
		 , strTaxTransactionType   		= 'Sales Order'
	FROM tblSOSalesOrderDetailTax SDT
	WHERE SDT.dblAdjustedTax <> 0
) AS TAXDETAIL
LEFT JOIN tblSMTaxCode SMT ON
       TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId 
