CREATE VIEW dbo.vyuSOSalesOrderDetail
AS
SELECT 
	 D.[intSalesOrderDetailId]
    ,D.[intSalesOrderId]
    ,H.[strSalesOrderNumber]  
    ,H.[intCompanyLocationId]
    ,L.[strLocationName] 
    ,D.[intItemId]
    ,IC.[strItemNo]
    ,D.[strItemDescription]
    ,IC.[strLotTracking]
    ,D.[intItemUOMId]
    ,U.[strUnitMeasure] 
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
    ,ST.[strName] AS strStorageLocation
FROM         
    [tblSOSalesOrderDetail] D
LEFT JOIN    
    [tblSOSalesOrder] H
        ON H.[intSalesOrderId] = D.[intSalesOrderId] 
LEFT JOIN
    [tblSMCompanyLocation] L
        ON H.[intCompanyLocationId] = L.[intCompanyLocationId]
LEFT JOIN
    [tblICItemUOM] IU
        ON D.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
    [tblICUnitMeasure] U
        ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT JOIN
    [tblICItem] IC
        ON D.[intItemId] = IC.[intItemId]
LEFT JOIN
    [tblICStorageLocation] ST
        ON D.[intStorageLocationId] = ST.[intStorageLocationId]