CREATE VIEW [dbo].[vyuARGetSalesOrdersToWeight]
AS
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , intCurrencyId			= SO.intCurrencyId
	 , intFreightTermId			= SO.intFreightTermId
	 , intShipToLocationId		= SO.intShipToLocationId
	 , intItemId				= SOD.intItemId
	 , intItemUOMId				= SOD.intItemUOMId
	 , intSalesOrderDetailId	= SOD.intSalesOrderDetailId
	 , intContractHeaderId		= SOD.intContractHeaderId
	 , intContractDetailId		= SOD.intContractDetailId
	 , intSubLocationId			= SOD.intSubLocationId
	 , intStorageLocationId		= SOD.intStorageLocationId
	 , intCommodityId			= ITEMS.intCommodityId
	 , intCategoryId			= ITEMS.intCategoryId
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber		= CUSTOMER.strCustomerNumber
	 , strLocationName			= LOCATIONS.strLocationName
	 , strCurrency				= CURRENCY.strCurrency
	 , strItemNo				= ITEMS.strItemNo
	 , strDescription			= ITEMS.strDescription
	 , strLotTracking			= ITEMS.strLotTracking
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , strCommodityCode			= COMMODITY.strCommodityCode
	 , strCategoryCode			= CATEGORY.strCategoryCode
	 , strSubLocationName		= SUBLOCATION.strSubLocationName
	 , strStorageLocationName   = STORAGELOCATION.strName
	 , strContractNumber		= CONTRACTS.strContractNumber
	 , intContractSeq			= CONTRACTS.intContractSeq
	 , dblQtyOrdered			= ISNULL(SOD.dblQtyOrdered, 0)
	 , dblQtyShipped			= ISNULL(SOD.dblQtyShipped, 0)
	 , dblQtyAllocated			= ISNULL(SOD.dblQtyAllocated, 0)
	 , dblPrice					= ISNULL(SOD.dblPrice, 0)
	 , dblDiscount				= ISNULL(SOD.dblDiscount, 0)
	 , dblTotal					= ISNULL(SOD.dblTotal, 0)
	 , dtmDate					= SO.dtmDate
FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
INNER JOIN (
	SELECT SO.intSalesOrderId
		 , SO.intCompanyLocationId
		 , SO.intEntityCustomerId
		 , SO.intCurrencyId
		 , SO.intShipToLocationId
		 , SO.intFreightTermId
		 , SO.strSalesOrderNumber
		 , SO.dtmDate
	FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)	
	WHERE SO.strOrderStatus NOT IN ('Closed', 'Short Closed', 'Cancelled')
	  AND SO.strTransactionType = 'Order'
	  AND SO.ysnRejected = 0
) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATIONS ON SO.intCompanyLocationId = LOCATIONS.intCompanyLocationId
INNER JOIN (
	SELECT intItemId
		 , intCommodityId
		 , intCategoryId
		 , strItemNo
		 , strDescription
		 , strLotTracking
	FROM dbo.tblICItem WITH (NOLOCK)
	WHERE ysnUseWeighScales = 1
) ITEMS ON SOD.intItemId = ITEMS.intItemId
INNER JOIN (
	SELECT C.intEntityId
		 , strCustomerNumber
		 , strName
	FROM dbo.tblARCustomer C WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) E ON E.intEntityId = C.intEntityId
) CUSTOMER ON SO.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intCurrencyID
	     , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON SO.intCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN (
	SELECT intCompanyLocationSubLocationId
		 , intCompanyLocationId
		 , strSubLocationName
	FROM dbo.tblSMCompanyLocationSubLocation WITH (NOLOCK)
) SUBLOCATION ON SOD.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId
             AND SO.intCompanyLocationId = SUBLOCATION.intCompanyLocationId
LEFT JOIN (
	SELECT intStorageLocationId
		 , strName
	FROM dbo.tblICStorageLocation WITH (NOLOCK)
) STORAGELOCATION ON SOD.intStorageLocationId = STORAGELOCATION.intStorageLocationId
LEFT JOIN (
	SELECT intItemId
		 , intUnitMeasureId
		 , intItemUOMId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICUOM ON SOD.intItemId = ICUOM.intItemId
       AND SOD.intItemUOMId = ICUOM.intItemUOMId
INNER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) UOM ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN (
	SELECT intCommodityId
		 , strCommodityCode
	FROM dbo.tblICCommodity WITH (NOLOCK)
) COMMODITY ON ITEMS.intCommodityId = COMMODITY.intCommodityId
LEFT JOIN (
	SELECT intCategoryId
		 , strCategoryCode
	FROM dbo.tblICCategory WITH (NOLOCK)
) CATEGORY ON ITEMS.intCategoryId = CATEGORY.intCategoryId
LEFT JOIN (
	SELECT CH.intContractHeaderId
		 , CD.intContractDetailId
		 , CD.intContractSeq
		 , strContractNumber
	FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
	INNER JOIN (
		SELECT intContractHeaderId
			 , intContractDetailId
			 , intContractSeq
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
	) CD ON CH.intContractHeaderId = CD.intContractHeaderId
) CONTRACTS ON SOD.intContractHeaderId = CONTRACTS.intContractHeaderId
	       AND SOD.intContractDetailId = CONTRACTS.intContractDetailId
LEFT JOIN (
	SELECT intFreightTermId
		 , strFreightTerm
	FROM dbo.tblSMFreightTerms WITH (NOLOCK)
) FREIGHT ON SO.intFreightTermId = FREIGHT.intFreightTermId
WHERE SO.intSalesOrderId NOT IN (SELECT intTransactionId FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order')