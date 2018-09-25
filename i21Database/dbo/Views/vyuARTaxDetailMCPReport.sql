CREATE VIEW [dbo].[vyuARTaxDetailMCPReport]
AS 
SELECT strTaxCode			= TC.strTaxCode
	 , strTaxDescription	= TC.strDescription
	 , strCalculationMethod	= IDT.strCalculationMethod
	 , dblQuantity			= SUM(ISNULL(DETAIL.dblQtyShipped, 0))
	 , dblRate				= ISNULL(IDT.dblRate, 0)
	 , dblTax				= SUM(ISNULL(IDT.dblTax, 0))
	 , dblAdjustedTax		= SUM(ISNULL(IDT.dblAdjustedTax, 0))
	 , intInvoiceId			= DETAIL.intInvoiceId
	 , intCategoryId		= ICI.[intCategoryId]
FROM dbo.tblARInvoiceDetail DETAIL WITH (NOLOCK)
INNER JOIN (
	SELECT DISTINCT intInvoiceId
	FROM tblARInvoiceReportStagingTable
) STAGING ON DETAIL.intInvoiceId = STAGING.intInvoiceId
LEFT OUTER JOIN (
	SELECT [intItemId]
		 , [intCategoryId]
	FROM dbo.tblICItem WITH (NOLOCK)
) ICI ON DETAIL.[intItemId] = ICI.[intItemId]
INNER JOIN (
	SELECT intInvoiceDetailId
		 , intTaxCodeId
		 , strCalculationMethod
		 , dblRate
		 , dblTax
		 , dblAdjustedTax
	FROM dbo.tblARInvoiceDetailTax WITH (NOLOCK)
) IDT ON DETAIL.intInvoiceDetailId = IDT.intInvoiceDetailId
INNER JOIN (
	SELECT intTaxCodeId
		 , strTaxCode
		 , strDescription
	FROM dbo.tblSMTaxCode WITH (NOLOCK)
) TC ON IDT.intTaxCodeId = TC.intTaxCodeId
GROUP BY DETAIL.intInvoiceId, TC.strTaxCode, TC.strDescription, IDT.strCalculationMethod, IDT.dblRate, ICI.[intCategoryId]
HAVING SUM(ISNULL(IDT.dblAdjustedTax, 0)) <> 0