CREATE VIEW [dbo].[vyuARGetTaxDetail]
AS 
SELECT intItemId			= ID.intItemId
	 , intCategoryId		= ITEM.intCategoryId
	 , strItemNo			= ITEM.strItemNo
	 , strCategoryCode		= ITEMCATEGORY.strCategoryCode
	 , strTransactionType   = 'Invoice'
	 , TAXDETAILS.*	 
FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
INNER JOIN (
	SELECT intTransactionTid = IDT.intInvoiceDetailId
		 , IDT.intTaxClassId
		 , IDT.intTaxCodeId
		 , ysnSpecialTax	= CONVERT(BIT, 1)
		 , IDT.ysnTaxExempt
		 , dblAdjustedTax	= ISNULL(IDT.dblAdjustedTax, 0.00)
	FROM dbo.tblARInvoiceDetailTax IDT WITH (NOLOCK)
	INNER JOIN (
		SELECT intTaxCodeId
			 , strTaxCode
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) TAXCODE ON IDT.intTaxCodeId = TAXCODE.intTaxCodeId
	INNER JOIN (
		SELECT intTaxClassId
			 , strTaxClass
		FROM dbo.tblSMTaxClass WITH (NOLOCK)
	) TAXCLASS ON IDT.intTaxClassId = TAXCLASS.intTaxClassId
) TAXDETAILS ON ID.intInvoiceDetailId = TAXDETAILS.intTransactionTid
INNER JOIN (
	SELECT intItemId
		 , intCategoryId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ID.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intCategoryId
		, strCategoryCode
	FROM dbo.tblICCategory
) ITEMCATEGORY ON ITEM.intCategoryId = ITEMCATEGORY.intCategoryId
