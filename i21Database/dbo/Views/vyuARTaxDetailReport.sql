CREATE VIEW [dbo].[vyuARTaxDetailReport]
AS 
SELECT TAXDETAIL.*
     , strTaxCode				= SMT.strTaxCode
	 , strDescription			= SMT.strDescription
	 , strTaxClass				= TC.strTaxClass
	 , ysnIncludeInvoicePrice	= ISNULL(SMT.ysnIncludeInvoicePrice, 0)
FROM (
	SELECT intTransactionDetailTaxId	= IDT.intInvoiceDetailTaxId
		 , intTransactionDetailId		= IDT.intInvoiceDetailId
		 , intTransactionId				= ID.intInvoiceId
		 , dblAdjustedTax				= IDT.dblAdjustedTax
		 , dblRate						= IDT.dblRate
		 , dblTaxPerQty					= CASE WHEN ISNULL(ID.dblQtyShipped, 0) <> 0 THEN IDT.dblAdjustedTax / ID.dblQtyShipped ELSE 0 END
		 , intTaxCodeId					= IDT.intTaxCodeId
		 , strCalculationMethod			= IDT.strCalculationMethod
		 , dblComputedGrossPrice		= ISNULL(ID.dblComputedGrossPrice, 0)
		 , strTaxTransactionType		= 'Invoice' COLLATE Latin1_General_CI_AS
		 , strInvoiceType				= I.strType
	FROM tblARInvoiceDetailTax IDT 	
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	WHERE ((IDT.ysnTaxExempt = 1 AND ISNULL(ID.dblComputedGrossPrice, 0) <> 0) OR (IDT.ysnTaxExempt = 0 AND IDT.dblAdjustedTax <> 0))
	  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , intTransactionId				= 0
		 , dblAdjustedTax				= SDT.dblAdjustedTax
		 , dblRate						= SDT.dblRate
		 , dblTaxPerQty					= CASE WHEN ISNULL(SOD.dblQtyOrdered, 0) <> 0 THEN SDT.dblAdjustedTax / SOD.dblQtyOrdered ELSE 0 END
		 , intTaxCodeId					= SDT.intTaxCodeId
		 , strCalculationMethod			= SDT.strCalculationMethod
		 , dblComputedGrossPrice		= 0
		 , strTaxTransactionType   		= 'Sales Order' COLLATE Latin1_General_CI_AS
		 , strInvoiceType				= NULL
	FROM tblSOSalesOrderDetailTax SDT
	INNER JOIN tblSOSalesOrderDetail SOD ON SDT.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	WHERE SDT.dblAdjustedTax <> 0
) AS TAXDETAIL
INNER JOIN tblSMTaxCode SMT ON TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId
INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId	