CREATE VIEW [dbo].[vyuARGetSalesOrdersToWeight]
AS
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , intCurrencyId			= SO.intCurrencyId
	 , intFreightTermId			= SO.intFreightTermId
	 , intShipToLocationId		= SO.intShipToLocationId
	 , intItemId				= NULL
	 , intItemUOMId				= NULL
	 , intSalesOrderDetailId	= NULL
	 , intContractHeaderId		= NULL
	 , intContractDetailId		= NULL
	 , intSubLocationId			= NULL
	 , intStorageLocationId		= NULL
	 , intCommodityId			= NULL
	 , intCategoryId			= NULL
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber		= CUSTOMER.strCustomerNumber
	 , strLocationName			= LOCATIONS.strLocationName
	 , strCurrency				= CURRENCY.strCurrency
	 , strItemNo				= NULL
	 , strDescription			= NULL
	 , strLotTracking			= NULL
	 , strUnitMeasure			= NULL
	 , strCommodityCode			= NULL
	 , strCategoryCode			= NULL
	 , strSubLocationName		= NULL
	 , strStorageLocationName   = NULL
	 , strContractNumber		= NULL
	 , intContractSeq			= NULL
	 , dblQtyOrdered			= NULL
	 , dblQtyShipped			= NULL
	 , dblQtyAllocated			= NULL
	 , dblPrice					= NULL
	 , dblDiscount				= NULL
	 , dblTotal					= NULL
	 , dtmDate					= SO.dtmDate
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATIONS ON SO.intCompanyLocationId = LOCATIONS.intCompanyLocationId
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
CROSS APPLY (
	SELECT intSalesOrderId
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemId
		FROM dbo.tblICItem WITH (NOLOCK)
		WHERE ysnUseWeighScales = 1
	) ITEM ON SOD.intItemId = ITEM.intItemId
	WHERE SOD.intSalesOrderId = SO.intSalesOrderId
	GROUP BY SOD.intSalesOrderId
) DETAILS
WHERE SO.strOrderStatus NOT IN ('Closed', 'Short Closed', 'Cancelled')
	  AND SO.strTransactionType = 'Order'