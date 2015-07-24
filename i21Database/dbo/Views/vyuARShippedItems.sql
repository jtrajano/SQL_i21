CREATE VIEW [dbo].[vyuARShippedItems]
AS

SELECT
	 SO.[intEntityCustomerId]
	,E.[strName]						AS [strCustomerName]
	,SO.[intSalesOrderId]
	,SO.[strSalesOrderNumber]
	,SO.[dtmDate]
	,SHP.[intInventoryShipmentItemId]
	,SHP.[strShipmentNumber] 
	,SOD.[intSalesOrderDetailId]
	,SO.[intCompanyLocationId]
	,CL.[strLocationName] 
	,SO.[intShipToLocationId]
	,SO.[intFreightTermId]
	,SOD.[intItemId]	
	,I.[strItemNo] 
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SHP.[intItemUOMId]					AS [intShipmentItemUOMId]
	,SHP.[strUnitMeasure]				AS [strShipmentUnitMeasure]
	,SOD.[dblQtyOrdered] 
	,SHP.[dblQuantity]					AS [dblShipmentQuantity] 
	,SOD.[dblQtyShipped]	
	,SHP.[dblSOShipped]					AS [dblShipmentQtyShipped] 
	,SHP.[dblShipped]					AS [dblShipmentQtyShippedTotal]
	,SOD.[dblQtyOrdered] 
		- SOD.[dblQtyShipped]			AS [dblQtyRemaining]
	,SOD.[dblDiscount] 
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
	,S.[intEntityShipViaId] 
	,S.[strName]						AS [strShipVia]
	,SCT.[intTicketNumber]				AS [intTicketNumber]
	,SCT.[intTicketId]					AS [intTicketId]
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
		ON SO.[intShipViaId] = S.[intEntityShipViaId]
INNER JOIN
	tblICItem I
		ON SOD.[intItemId] = I.[intItemId]
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId] 
CROSS APPLY
	(
	SELECT 
		 ISI.[intInventoryShipmentItemId]
		,ISH.[strShipmentNumber] 
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,U.[strUnitMeasure]
		,ISI.[dblUnitPrice]
		,ISI.[intSourceId]
		,dbo.fnCalculateQtyBetweenUOM(ISI.[intItemUOMId], SOD.[intItemUOMId], SUM(ISNULL(ISI.[dblQuantity],0))) dblSOShipped
		,SUM(ISNULL(ISI.dblQuantity,0)) dblShipped
	FROM
		tblICInventoryShipmentItem ISI
	INNER JOIN
		tblICInventoryShipment ISH
			ON ISI.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	LEFT JOIN
		[tblICItemUOM] IU
			ON ISI.[intItemUOMId] = IU.[intItemUOMId]
	LEFT JOIN
		[tblICUnitMeasure] U
			ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
	WHERE
		ISH.[ysnPosted] = 1
		AND ISI.[intLineNo] = SOD.[intSalesOrderDetailId]
		AND SO.[strTransactionType] = 'Order'
		AND ISI.[intInventoryShipmentItemId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intInventoryShipmentItemId],0) FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.[intInvoiceId] = tblARInvoice.[intInvoiceId] WHERE tblARInvoice.[ysnPosted] = 1)
	GROUP BY
		 ISI.[intInventoryShipmentItemId]
		,ISH.[strShipmentNumber]
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,ISI.[dblUnitPrice]
		,U.[strUnitMeasure]
		,ISI.[intSourceId]
	--HAVING
	--	SUM(ISNULL(ISI.[dblQuantity],0)) != ISNULL(SOD.[dblQtyOrdered],0)
	) SHP
LEFT OUTER JOIN
	tblSCTicket SCT
		ON SHP.[intSourceId] = SCT.[intTicketId] 
	
UNION ALL

SELECT
	 SO.[intEntityCustomerId]
	,E.[strName]						AS [strCustomerName]
	,SO.[intSalesOrderId]
	,SO.[strSalesOrderNumber]
	,SO.[dtmDate]
	,NULL								AS [intInventoryShipmentItemId]
	,''									AS [strShipmentNumber]
	,SOD.[intSalesOrderDetailId]
	,SO.[intCompanyLocationId]
	,CL.[strLocationName] 
	,SO.[intShipToLocationId]
	,SO.[intFreightTermId]
	,SOD.[intItemId]	
	,I.[strItemNo] 
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SOD.[intItemUOMId]					AS [intShipmentItemUOMId]
	,U.[strUnitMeasure]					AS [strShipmentUnitMeasure]
	,SOD.[dblQtyOrdered] 
	,SOD.[dblQtyOrdered]				AS [dblShipmentQuantity] 
	,SOD.[dblQtyShipped]	
	,SOD.[dblQtyShipped]				AS [dblShipmentQtyShipped] 
	,SOD.[dblQtyShipped]				AS [dblShipmentQtyShippedTotal]
	,SOD.[dblQtyOrdered] 
		- SOD.[dblQtyShipped]			AS [dblQtyRemaining]
	,SOD.[dblDiscount] 
	,SOD.[dblPrice]
	,SOD.[dblPrice]						AS [dblShipmentUnitPrice] 			
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
	,S.[intEntityShipViaId] 
	,S.[strName]						AS [strShipVia]
	,NULL								AS [intTicketNumber]
	,NULL								AS [intTicketId]
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
		ON SO.[intShipViaId] = S.[intEntityShipViaId] 
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT JOIN
	tblICItemUOM IU
		ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U
		ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]		
WHERE
	SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId WHERE tblARInvoice.[ysnPosted] = 1)
	AND SO.[strTransactionType] = 'Order'

	UNION ALL

SELECT
	 SO.[intEntityCustomerId]
	,E.[strName]						AS [strCustomerName]
	,SO.[intSalesOrderId]
	,SO.[strSalesOrderNumber]
	,SO.[dtmDate]
	,NULL								AS [intInventoryShipmentItemId]
	,''									AS [strShipmentNumber]
	,SOD.[intSalesOrderDetailId]
	,SO.[intCompanyLocationId]
	,CL.[strLocationName] 
	,SO.[intShipToLocationId]
	,SO.[intFreightTermId]
	,SOD.[intItemId]	
	,NULL								AS [strItemNo] 
	,SOD.[strItemDescription]
	,SOD.[intItemUOMId]
	,SOD.[intItemUOMId]					AS [intShipmentItemUOMId]
	,U.[strUnitMeasure]					AS [strShipmentUnitMeasure]
	,SOD.[dblQtyOrdered] 
	,SOD.[dblQtyOrdered]				AS [dblShipmentQuantity] 
	,SOD.[dblQtyShipped]	
	,SOD.[dblQtyShipped]				AS [dblShipmentQtyShipped] 
	,SOD.[dblQtyShipped]				AS [dblShipmentQtyShippedTotal]
	,SOD.[dblQtyOrdered] 
		- SOD.[dblQtyShipped]			AS [dblQtyRemaining]
	,SOD.[dblDiscount] 
	,SOD.[dblPrice]
	,SOD.[dblPrice]						AS [dblShipmentUnitPrice] 			
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
	,S.[intEntityShipViaId] 
	,S.[strName]						AS [strShipVia]
	,NULL								AS [intTicketNumber]
	,NULL								AS [intTicketId]
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
		AND SOD.intItemId IS NULL
		AND SOD.strItemDescription <> ''
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
		ON SO.[intShipViaId] = S.[intEntityShipViaId] 
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT JOIN
	tblICItemUOM IU
		ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U
		ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]		
WHERE
	SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId WHERE tblARInvoice.[ysnPosted] = 1)
	AND SO.[strTransactionType] = 'Order'
