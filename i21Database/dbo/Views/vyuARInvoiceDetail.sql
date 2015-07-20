CREATE VIEW dbo.vyuARInvoiceDetail
AS
SELECT     
	D.[intInvoiceDetailId]
	,D.[intInvoiceId]
	,I.[intCompanyLocationId]
	,D.[intItemId]
	,D.[strItemDescription]
	,D.[intItemUOMId]
	,D.[dblQtyOrdered]
	,D.[dblQtyShipped]
	,D.[dblDiscount] 
	,D.[dblPrice]
	,D.[dblTotal]
	,D.[intAccountId]
	,D.[intCOGSAccountId]
	,D.[intSalesAccountId]
	,D.[intInventoryAccountId]
	,D.[intServiceChargeAccountId]
	,D.[intConcurrencyId]
	,I.[strInvoiceNumber] 
	,L.[strLocationName] 
	,U.[strUnitMeasure] 
	,IC.[strItemNo]
	,D.strMaintenanceType
	,D.strFrequency
	,D.dtmMaintenanceDate
	,D.dblMaintenanceAmount
	,D.dblLicenseAmount
	,D.intSCInvoiceId
	,D.strSCInvoiceNumber
FROM         
	[tblARInvoiceDetail] D
INNER JOIN	
	[tblARInvoice] I
		ON D.[intInvoiceId] = I.[intInvoiceId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] L
		ON I.[intCompanyLocationId] = L.[intCompanyLocationId]
LEFT OUTER JOIN
	[tblICUnitMeasure] U
		ON D.[intItemUOMId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	[tblICItem] IC
		ON D.[intItemId] = IC.[intItemId]	