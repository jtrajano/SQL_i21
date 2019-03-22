CREATE VIEW [dbo].[vyuARGetSalesOrdersToWeight]
AS
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , intCurrencyId			= SO.intCurrencyId
	 , intFreightTermId			= SO.intFreightTermId
	 , intShipToLocationId		= SO.intShipToLocationId
	 , intCommodityId			= DETAILS.intCommodityId
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strCustomerNumber		= CUSTOMER.strCustomerNumber
	 , strLocationName			= LOCATIONS.strLocationName
	 , strCurrency				= CURRENCY.strCurrency
	 , strCommodityCode			= COMM.strCommodityCode
	 , dblTotalQtyOrdered		= DETAILS.dblTotalQtyOrdered
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
		 , intCommodityId			= MAX(ITEM.intCommodityId)		 
		 , dblTotalQtyOrdered		= SUM(ISNULL(dblQtyOrdered, 0))
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemId
			 , intCommodityId
		FROM dbo.tblICItem WITH (NOLOCK)
		WHERE ysnUseWeighScales = 1
	) ITEM ON SOD.intItemId = ITEM.intItemId	
	WHERE SOD.intSalesOrderId = SO.intSalesOrderId
	GROUP BY SOD.intSalesOrderId
) DETAILS
LEFT JOIN (
	SELECT intCommodityId
		 , strCommodityCode
	FROM dbo.tblICCommodity WITH (NOLOCK)
) COMM ON DETAILS.intCommodityId = COMM.intCommodityId
WHERE SO.strOrderStatus NOT IN ('Closed', 'Short Closed', 'Cancelled')
	  AND SO.strTransactionType = 'Order'
	  AND SO.ysnRejected = 0