﻿CREATE VIEW [dbo].[vyuARShippedItems]
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
	,SO.[intFreightTermId]
	,SOD.[intItemId]	
	,I.[strItemNo] 
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SHP.[intItemUOMId]					AS [intShipmentItemUOMId]
	,SOD.[dblQtyOrdered] 
	,SHP.[dblQuantity]					AS [dblShipmentQuantity] 
	,SOD.[dblQtyShipped]	
	,SHP.[dblSOShipped]					AS [dblShipmentQtyShipped] 
	,SHP.[dblShipped]					AS [dblShipmentQtyShippedTotal]
	,SOD.[dblQtyOrdered] 
		- SOD.[dblQtyShipped]			AS [dblQtyRemaining]
	,SOD.[dblPrice]
	,SHP.[dblUnitPrice]					AS [dblShipmentUnitPrice]
	,SOD.[dblTotalTax]
	,SOD.[dblTotal]
	,SOD.[intAccountId]
	,SOD.[intCOGSAccountId]
	,SOD.[intSalesAccountId]
	,SOD.[intInventoryAccountId]
	,SOD.[intStorageLocationId]
	,SL.[strName]						AS [strStorageLocationName]
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
INNER JOIN
	tblICItem I
		ON SOD.[intItemId] = I.[intItemId]
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId] 
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
		AND SO.[strOrderStatus]	<> 'Complete'
	GROUP BY
		 ISI.[intInventoryShipmentItemId]
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,ISI.[dblUnitPrice]		
	HAVING
		SUM(ISNULL(ISI.[dblQuantity],0)) != ISNULL(SOD.[dblQtyOrdered],0)
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
	,SO.[intFreightTermId]
	,SOD.[intItemId]	
	,I.[strItemNo] 
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,NULL								AS [intShipmentItemUOMId]
	,SOD.[dblQtyOrdered] 
	,NULL								AS [dblShipmentQuantity] 
	,SOD.[dblQtyShipped]	
	,NULL								AS [dblShipmentQtyShipped] 
	,NULL								AS [dblShipmentQtyShippedTotal]
	,SOD.[dblQtyOrdered] 
		- SOD.[dblQtyShipped]			AS [dblQtyRemaining]
	,SOD.[dblPrice]
	,NULL								AS [dblShipmentUnitPrice] 			
	,SOD.[dblTotalTax]
	,SOD.[dblTotal]
	,SOD.[intAccountId]
	,SOD.[intCOGSAccountId]
	,SOD.[intSalesAccountId]
	,SOD.[intInventoryAccountId]
	,SOD.[intStorageLocationId]
	,SL.[strName]						AS [strStorageLocationName]
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
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId] 		
WHERE
	SO.[strOrderStatus] <> 'Complete'