CREATE VIEW [dbo].[vyuARGetSalesOrdersToWeight]
AS
SELECT DISTINCT
	   SO.intSalesOrderId
	 , SO.intCompanyLocationId
	 , SO.strLocationName
	 , SO.strSalesOrderNumber
FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
INNER JOIN (
	SELECT SO.intSalesOrderId
		 , SO.intCompanyLocationId
		 , SO.strSalesOrderNumber
		 , L.strLocationName
	FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
	INNER JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) L ON SO.intCompanyLocationId = L.intCompanyLocationId
	WHERE SO.strOrderStatus NOT IN ('Closed', 'Short Closed', 'Cancelled')
	  AND SO.strTransactionType = 'Order'
) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
INNER JOIN (
	SELECT intItemId
	FROM dbo.tblICItem WITH (NOLOCK)
	WHERE ysnUseWeighScales = 1
) ITEMS ON SOD.intItemId = ITEMS.intItemId