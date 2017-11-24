CREATE VIEW [dbo].[vyuARGetTaxDetail]
AS 
SELECT intCategoryId		= ITEM.intCategoryId
	 , strItemNo			= ITEM.strItemNo
	 , strCategoryCode		= ITEMCATEGORY.strCategoryCode	 
	 , strTaxClass			= TAXCLASS.strTaxClass
	 , strTaxCode			= TAXCODE.strTaxCode
	 , ysnTaxMatched		= CONVERT(BIT, 1)
	 , TRANSACTIONS.*
FROM (
	SELECT intTransactionId			= ID.intInvoiceId
		 , intItemId				= ID.intItemId
		 , intTaxClassId			= IDT.intTaxClassId
		 , intTaxCodeId				= IDT.intTaxCodeId
		 , ysnSpecialTax			= CONVERT(BIT, 1)
		 , ysnTaxExempt				= IDT.ysnTaxExempt
		 , strTransactionType		= 'Invoice'
		 , dblAdjustedTax			= ISNULL(IDT.dblAdjustedTax, 0.00)
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceDetailId
			 , intTaxClassId
			 , intTaxCodeId
			 , ysnTaxExempt
			 , dblAdjustedTax
		FROM dbo.tblARInvoiceDetailTax IDT WITH (NOLOCK)
	) IDT ON ID.intInvoiceDetailId = IDT.intInvoiceDetailId

	UNION ALL

	SELECT intTransactionId			= SOD.intSalesOrderId
		 , intItemId				= SOD.intItemId
		 , intTaxClassId			= SODT.intTaxClassId
		 , intTaxCodeId				= SODT.intTaxCodeId
		 , ysnSpecialTax			= CONVERT(BIT, 1)
		 , ysnTaxExempt				= SODT.ysnTaxExempt
		 , strTransactionType		= 'Sales Order'
		 , dblAdjustedTax			= ISNULL(SODT.dblAdjustedTax, 0.00)
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intSalesOrderDetailId
			 , intTaxClassId
			 , intTaxCodeId
			 , ysnTaxExempt
			 , dblAdjustedTax		 
		FROM dbo.tblSOSalesOrderDetailTax WITH (NOLOCK)
	) SODT ON SOD.intSalesOrderDetailId = SODT.intSalesOrderDetailId
) TRANSACTIONS	
INNER JOIN (
	SELECT intTaxCodeId
		 , strTaxCode
	FROM dbo.tblSMTaxCode WITH (NOLOCK)
) TAXCODE ON TRANSACTIONS.intTaxCodeId = TAXCODE.intTaxCodeId
INNER JOIN (
	SELECT intTaxClassId
		 , strTaxClass
	FROM dbo.tblSMTaxClass WITH (NOLOCK)
) TAXCLASS ON TRANSACTIONS.intTaxClassId = TAXCLASS.intTaxClassId
INNER JOIN (
	SELECT intItemId
		 , intCategoryId
		 , strItemNo
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON TRANSACTIONS.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intCategoryId
		, strCategoryCode
	FROM dbo.tblICCategory
) ITEMCATEGORY ON ITEM.intCategoryId = ITEMCATEGORY.intCategoryId