CREATE VIEW [dbo].[vyuARTaxDetailReport]
AS 
SELECT TAXDETAIL.*
     , SMT.strTaxCode
FROM (
	SELECT intTransactionDetailTaxId	=  IDT.intInvoiceDetailTaxId
		 , intTransactionDetailId		= IDT.intInvoiceDetailId
		 , IDT.dblAdjustedTax
		 , IDT.intTaxCodeId
		 , strTaxTransactionType		= 'Invoice'
	FROM tblARInvoiceDetailTax IDT 
		INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
			WHERE IDT.dblAdjustedTax <> 0 
			  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , SDT.dblAdjustedTax
		 , SDT.intTaxCodeId
		 , strTaxTransactionType   = 'Sales Order'
	FROM tblSOSalesOrderDetailTax SDT
		WHERE SDT.dblAdjustedTax <> 0
) AS TAXDETAIL
LEFT JOIN tblSMTaxCode SMT ON
       TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId 
