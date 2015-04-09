CREATE VIEW dbo.vyuARInvoiceDetail
AS
SELECT     
	D.[intInvoiceDetailId]
	,D.[intInvoiceId]
	,D.[intCompanyLocationId]
	,D.[intItemId]
	,D.[strItemDescription]
	,D.[intItemUOMId]
	,D.[dblQtyOrdered]
	,D.[dblQtyShipped]
	,D.[dblPrice]
	,D.[dblTotal]
	,D.[intAccountId]
	,D.[intCOGSAccountId]
	,D.[intSalesAccountId]
	,D.[intInventoryAccountId]
	,D.[intConcurrencyId]
	,I.[strInvoiceNumber] 
	,L.[strLocationName] 
	,U.[strUnitMeasure] 
	,IC.[strItemNo]  
FROM         
	[tblARInvoiceDetail] D
INNER JOIN	
	[tblARInvoice] I
		ON D.[intInvoiceId] = I.[intInvoiceId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] L
		ON D.[intCompanyLocationId] = L.[intCompanyLocationId]
LEFT OUTER JOIN
	[tblICUnitMeasure] U
		ON D.[intItemUOMId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	[tblICItem] IC
		ON D.[intItemId] = IC.[intItemId]	