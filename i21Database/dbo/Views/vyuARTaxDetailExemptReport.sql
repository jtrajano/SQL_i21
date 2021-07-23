CREATE VIEW [dbo].[vyuARTaxDetailExemptReport]
AS 
SELECT TAXDETAIL.*
     , strTaxCode				= SMT.strTaxCode
	 , strDescription			= SMT.strDescription
	 , strTaxClass				= TC.strTaxClass
FROM (
	SELECT intTransactionDetailTaxId	= IDT.intInvoiceDetailTaxId
		 , intTransactionDetailId		= IDT.intInvoiceDetailId
		 , intTransactionId				= ID.intInvoiceId
		 , dblRate						= IDT.dblRate
		 , intTaxCodeId					= IDT.intTaxCodeId
		 , strTaxTransactionType		= 'Invoice' COLLATE Latin1_General_CI_AS
		 , strInvoiceType				= I.strType
		 , strTaxNumber					= C.strTaxNumber
	FROM tblARInvoiceDetailTax IDT 	
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityId
	WHERE (IDT.ysnTaxExempt = 1 AND ISNULL(ID.dblComputedGrossPrice, 0) = 0)
	  AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM tblTRCompanyPreference), 0)

	UNION ALL

	SELECT intTransactionDetailTaxId	= SDT.intSalesOrderDetailTaxId
		 , intTransactionDetailId		= SDT.intSalesOrderDetailId
		 , intTransactionId				= 0
		 , dblRate						= SDT.dblRate
		 , intTaxCodeId					= SDT.intTaxCodeId
		 , strTaxTransactionType   		= 'Sales Order' COLLATE Latin1_General_CI_AS
		 , strInvoiceType				= NULL
		 , strTaxNumber					= NULL
	FROM tblSOSalesOrderDetailTax SDT
	INNER JOIN tblSOSalesOrderDetail SOD ON SDT.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	WHERE SDT.dblAdjustedTax = 0
	AND SDT.ysnTaxExempt = 1
) AS TAXDETAIL
INNER JOIN tblSMTaxCode SMT ON TAXDETAIL.intTaxCodeId = SMT.intTaxCodeId
INNER JOIN tblSMTaxClass TC ON SMT.intTaxClassId = TC.intTaxClassId