CREATE VIEW dbo.vyuRestApiInvoiceDetail
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
	,D.intContractDetailId
	,D.intContractHeaderId
	,COALESCE(D.intItemContractDetailId, D.intItemCategoryId) intItemContractDetailId
	,COALESCE(D.intItemContractHeaderId, dollar.intItemContractHeaderId) intItemContractHeaderId
	,strItemCategory = cc.strCategoryCode
	,strItemContractType = h.strContractCategoryId
FROM         
	[tblARInvoiceDetail] D
INNER JOIN	
	[tblARInvoice] I
		ON D.[intInvoiceId] = I.[intInvoiceId]
LEFT OUTER JOIN tblCTItemContractHeaderCategory dollar ON dollar.intItemCategoryId = D.intItemCategoryId
	AND D.intCategoryId = dollar.intCategoryId
LEFT OUTER JOIN tblCTItemContractHeader h ON h.intItemContractHeaderId = COALESCE(D.intItemContractHeaderId, dollar.intItemContractHeaderId)
LEFT OUTER JOIN tblICCategory cc ON cc.intCategoryId = dollar.intCategoryId
LEFT OUTER JOIN
	[tblSMCompanyLocation] L
		ON I.[intCompanyLocationId] = L.[intCompanyLocationId]
LEFT OUTER JOIN
	[tblICUnitMeasure] U
		ON D.[intItemUOMId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	[tblICItem] IC
		ON D.[intItemId] = IC.[intItemId]	