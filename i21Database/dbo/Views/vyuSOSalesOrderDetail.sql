CREATE VIEW dbo.vyuSOSalesOrderDetail
AS
SELECT     
	D.[intSalesOrderDetailId]
	,D.[intSalesOrderId]
	,D.[intCompanyLocationId]
	,D.[intItemId]
	,D.[strItemDescription]
	,D.[intItemUOMId]
	,D.[dblQtyOrdered]
	,D.[dblQtyAllocated]
	,D.[dblDiscount]
	,D.[intTaxId]
	,D.[dblPrice]
	,D.[dblTotal]
	,D.[strComments]
	,D.[intAccountId]
	,D.[intCOGSAccountId]
	,D.[intSalesAccountId]
	,D.[intInventoryAccountId]
	,D.[intStorageLocationId]
	,H.[strSalesOrderNumber]  
	,L.[strLocationName] 
	,U.[strUnitMeasure] 
	,IC.[strItemNo]
	,ST.[strName]				AS "strStorageLocation"
FROM         
	[tblSOSalesOrderDetail] D
INNER JOIN	
	[tblSOSalesOrder] H
		ON D.[intSalesOrderId] = D.[intSalesOrderId] 
LEFT OUTER JOIN
	[tblSMCompanyLocation] L
		ON D.[intCompanyLocationId] = L.[intCompanyLocationId]
LEFT OUTER JOIN
	[tblICUnitMeasure] U
		ON D.[intItemUOMId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	[tblICItem] IC
		ON D.[intItemId] = IC.[intItemId]
LEFT OUTER JOIN
	[tblICStorageLocation] ST
		ON D.[intStorageLocationId] = ST.[intStorageLocationId]