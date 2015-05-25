CREATE VIEW [dbo].[vyuARShippedItems]
AS

SELECT
	 SO.[intEntityCustomerId]
	,E.[strName]						AS [strCustomerName]
	,SO.[intSalesOrderId]
	,SO.[strSalesOrderNumber]
	,SO.[dtmProcessDate]
	,SHP.[intInventoryShipmentItemId]
	,SOD.[intSalesOrderDetailId]
	,SO.[intCompanyLocationId]
	,SO.[intShipToLocationId]
	,SO.[intBillToLocationId]
	,SO.[intFreightTermId]
	,SOD.[intItemId]
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SOD.[dblQtyOrdered] 
	,SOD.[dblQtyShipped]
	,SHP.[dblQuantity] 
	,SHP.[dblUnitPrice] 
	,SHP.[dblSOShipped]
	,SHP.[dblShipped]
	,SOD.[dblPrice]
	,SOD.[dblTotalTax]
	,SOD.[dblTotal]
	,SOD.[intAccountId]
	,SOD.[intCOGSAccountId]
	,SOD.[intSalesAccountId]
	,SOD.[intInventoryAccountId]
	,T.[intTermID]
	,T.[strTerm]
	,S.[intShipViaID] 
	,S.[strName]						AS [strShipVia]
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 
LEFT OUTER JOIN
	tblSMTerm T
		ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	tblSMShipVia S
		ON SO.[intShipViaId] = S.[intShipViaID] 		
CROSS APPLY
	(
	SELECT 
		 ISI.[intInventoryShipmentItemId]
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,ISI.[dblUnitPrice]
		,dbo.fnCalculateQtyBetweenUOM(ISI.[intItemUOMId], SOD.[intItemUOMId], SUM(ISNULL(ISI.[dblQuantity],0))) dblSOShipped
		,SUM(ISNULL(ISI.dblQuantity,0)) dblShipped
	FROM
		tblICInventoryShipmentItem ISI
	INNER JOIN
		tblICInventoryShipment ISH
			ON ISI.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	WHERE
		ISH.[ysnPosted] = 1
		AND ISI.[intLineNo] = SOD.[intSalesOrderDetailId]	
	GROUP BY
		 ISI.[intInventoryShipmentItemId]
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,ISI.[dblUnitPrice]		
	HAVING
		SUM(ISNULL(ISI.[dblQuantity],0)) != ISNULL(SOD.[dblQtyShipped],0)
	) SHP
	
UNION ALL

SELECT
	 SO.[intEntityCustomerId]
	,E.[strName]						AS [strCustomerName]
	,SO.[intSalesOrderId]
	,SO.[strSalesOrderNumber]
	,SO.[dtmProcessDate]
	,NULL								AS [intInventoryShipmentItemId]
	,SOD.[intSalesOrderDetailId]
	,SO.[intCompanyLocationId]
	,SO.[intShipToLocationId]
	,SO.[intBillToLocationId]
	,SO.[intFreightTermId]
	,SOD.[intItemId]
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SOD.[dblQtyOrdered] 
	,SOD.[dblQtyShipped]
	,0									AS [dblQuantity] 
	,0									AS [dblUnitPrice] 
	,0									AS [dblSOShipped]
	,0									AS [dblShipped]
	,SOD.[dblPrice]
	,SOD.[dblTotalTax]
	,SOD.[dblTotal]
	,SOD.[intAccountId]
	,SOD.[intCOGSAccountId]
	,SOD.[intSalesAccountId]
	,SOD.[intInventoryAccountId]
	,T.[intTermID]
	,T.[strTerm]
	,S.[intShipViaID] 
	,S.[strName]					AS strShipVia
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
INNER JOIN
	tblICItem I
		ON SOD.[intItemId] = I.[intItemId]
		AND I.[strType] IN ('Service','Software','Non-Inventory','Other Charge')
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 
LEFT OUTER JOIN
	tblSMTerm T
		ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	tblSMShipVia S
		ON SO.[intShipViaId] = S.[intShipViaID] 
WHERE
	SO.[strOrderStatus] <> 'Complete'