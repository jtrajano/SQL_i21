print('/*******************  BEGIN - Update Taxed Price and Taxed QTY  *******************/')
GO

DECLARE @InvoiceDetails AS TABLE([intInvoiceDetailId] INT)
INSERT INTO @InvoiceDetails([intInvoiceDetailId])
SELECT
	ARID.[intInvoiceDetailId]
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
WHERE
	ISNULL(ARI.[ysnIncludeTaxOnDiscount], 0) = 0
	AND (
		ARID.[dblTaxedQuantity] <> ARID.[dblQtyShipped] 
		OR
		ARID.[dblTaxedPrice] <> ARID.[dblPrice] 
		OR
		ARID.[dblBaseTaxedPrice] <> ARID.[dblBasePrice] 
		)	

UPDATE ARID
SET
	 ARID.[dblTaxedPrice]		= ARID.[dblPrice]
	,ARID.[dblBaseTaxedPrice]	= ARID.[dblBasePrice]
	,ARID.[dblTaxedQuantity]	= ARID.[dblQtyShipped]
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	@InvoiceDetails IDID
		ON ARID.[intInvoiceDetailId] = IDID.[intInvoiceDetailId]

UPDATE ARIDT
SET
	 ARIDT.[dblDiscountedTax]		= ARIDT.[dblAdjustedTax]
	,ARIDT.[dblBaseDiscountedTax]	= ARIDT.[dblBaseAdjustedTax]
FROM
	tblARInvoiceDetailTax ARIDT
INNER JOIN
	@InvoiceDetails IDID
		ON ARIDT.[intInvoiceDetailId] = IDID.[intInvoiceDetailId]

GO
print('/*******************  END - Update Taxed Price and Taxed QTY  *******************/')