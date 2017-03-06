CREATE VIEW dbo.vyuSOSalesOrderDetail
AS
SELECT 
     D.[intSalesOrderDetailId]
    ,D.[intSalesOrderId]
    ,H.[strSalesOrderNumber]  
    ,H.[intCompanyLocationId]
    ,H.intEntityCustomerId
    ,H.strCustomerNumber
    ,H.strCustomerName
    ,L.[strLocationName] 
    ,D.[intItemId]
    ,IC.[strItemNo]
    ,D.[strItemDescription]
    ,IC.[strLotTracking]
    ,D.[intItemUOMId]
    ,ISNULL(IU.[dblUnitQty], 0) AS dblUOMConversion
    ,U.[strUnitMeasure] 
    ,D.[dblQtyOrdered]
    ,D.[dblQtyAllocated]
    ,D.[dblQtyShipped]
    ,D.[dblDiscount]
    ,D.[intTaxId]
    ,D.[dblPrice]
    ,D.[dblTotal]
    ,D.[strComments]
    ,D.[intAccountId]
    ,D.[intCOGSAccountId]
    ,D.[intSalesAccountId]
    ,D.[intInventoryAccountId]
    ,ST.intSubLocationId
    ,ST.strSubLocationName
    ,D.[intStorageLocationId]
    ,ST.[strName] AS strStorageLocation
    ,D.strMaintenanceType
    ,D.strFrequency
    ,D.dtmMaintenanceDate
    ,D.dblMaintenanceAmount
    ,D.dblLicenseAmount
    ,D.intContractHeaderId
    ,D.intContractDetailId
    ,CH.strContractNumber
    ,CD.intContractSeq
    ,IC.intCommodityId
    ,H.ysnProcessed
	,D.intCurrencyExchangeRateTypeId
	,D.dblCurrencyExchangeRate 
FROM         
    [tblSOSalesOrderDetail] D
LEFT JOIN    
    [vyuSOSalesOrderSearch] H
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
    [vyuICGetStorageLocation] ST
        ON D.[intStorageLocationId] = ST.[intStorageLocationId]
LEFT JOIN
    [tblCTContractHeader] CH
        ON D.[intContractHeaderId] = CH.[intContractHeaderId]
LEFT JOIN
    [tblCTContractDetail] CD
        ON D.[intContractDetailId] = CD.[intContractDetailId] 
      AND CH.[intContractHeaderId] = CD.[intContractHeaderId]