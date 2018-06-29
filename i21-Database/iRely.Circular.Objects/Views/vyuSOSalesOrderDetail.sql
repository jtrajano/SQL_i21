CREATE VIEW dbo.vyuSOSalesOrderDetail
AS
SELECT intSalesOrderDetailId	= D.intSalesOrderDetailId
     , intSalesOrderId			= D.intSalesOrderId
     , strSalesOrderNumber		= H.strSalesOrderNumber
     , intCompanyLocationId		= H.intCompanyLocationId
     , intEntityCustomerId		= H.intEntityCustomerId
     , strCustomerNumber		= H.strCustomerNumber
     , strCustomerName			= H.strCustomerName
     , strLocationName			= L.strLocationName
     , intItemId				= D.intItemId
     , strItemNo				= IC.strItemNo
     , strItemDescription		= D.strItemDescription
     , strLotTracking			= IC.strLotTracking
     , intItemUOMId				= D.intItemUOMId
     , dblUOMConversion			= ISNULL(IU.[dblUnitQty], 0)
     , strUnitMeasure			= U.strUnitMeasure
     , dblQtyOrdered			= D.dblQtyOrdered
     , dblQtyAllocated			= D.dblQtyAllocated
     , dblQtyShipped			= D.dblQtyShipped
     , dblDiscount				= D.dblDiscount
     , intTaxId					= D.intTaxId
     , dblPrice					= D.dblPrice
     , dblTotal					= D.dblTotal
     , strComments				= D.strComments
     , intAccountId				= D.intAccountId
     , intCOGSAccountId			= D.intCOGSAccountId
     , intSalesAccountId		= D.intSalesAccountId
     , intInventoryAccountId	= D.intInventoryAccountId
     , intSubLocationId			= ST.intSubLocationId
     , strSubLocationName		= ST.strSubLocationName
     , intStorageLocationId		= D.intStorageLocationId
     , strStorageLocation		= ST.strName
     , strMaintenanceType		= D.strMaintenanceType
     , strFrequency				= D.strFrequency
     , dtmMaintenanceDate		= D.dtmMaintenanceDate
     , dblMaintenanceAmount		= D.dblMaintenanceAmount
     , dblLicenseAmount			= D.dblLicenseAmount
     , intContractHeaderId		= D.intContractHeaderId
     , intContractDetailId		= D.intContractDetailId
     , strContractNumber		= CH.strContractNumber
     , intContractSeq			= CD.intContractSeq
     , intCommodityId			= IC.intCommodityId
     , ysnProcessed				= H.ysnProcessed
	 , intCurrencyExchangeRateTypeId	= D.intCurrencyExchangeRateTypeId
	 , dblCurrencyExchangeRate	= D.dblCurrencyExchangeRate 
	 , D.intPriceUOMId 
	 , strPriceUOM				= PriceUOM.strUnitMeasure
FROM dbo.tblSOSalesOrderDetail D WITH (NOLOCK)
LEFT JOIN (
	SELECT intSalesOrderId
		 , intCompanyLocationId
		 , intEntityCustomerId
		 , strSalesOrderNumber
		 , strCustomerNumber
		 , strCustomerName
		 , ysnProcessed
	FROM dbo.vyuSOSalesOrderSearch WITH (NOLOCK)
	WHERE strTransactionType = 'Order'
) H ON H.intSalesOrderId = D.intSalesOrderId
LEFT JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) L ON H.intCompanyLocationId = L.intCompanyLocationId
LEFT JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , dblUnitQty
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) IU ON D.intItemUOMId = IU.intItemUOMId
LEFT JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) U ON IU.intUnitMeasureId = U.intUnitMeasureId
LEFT JOIN (
	SELECT intItemId
		 , intCommodityId
		 , strItemNo
		 , strLotTracking
	FROM dbo.tblICItem WITH (NOLOCK)
) IC ON D.intItemId = IC.intItemId
LEFT JOIN (
	SELECT intStorageLocationId
		 , intSubLocationId
		 , strName
		 , strSubLocationName
	FROM dbo.vyuICGetStorageLocation WITH (NOLOCK)
) ST ON D.intStorageLocationId = ST.intStorageLocationId
LEFT JOIN (
	SELECT intContractHeaderId
		 , strContractNumber
	FROM dbo.tblCTContractHeader WITH (NOLOCK) 
) CH ON D.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN (
    SELECT intContractHeaderId
		 , intContractDetailId
		 , intContractSeq
	FROM dbo.tblCTContractDetail WITH (NOLOCK)
) CD ON D.intContractDetailId = CD.intContractDetailId 
   AND CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , dblUnitQty
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ItemPriceUOM ON D.intPriceUOMId = ItemPriceUOM.intItemUOMId
LEFT JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) PriceUOM ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId