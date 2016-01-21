﻿CREATE VIEW [dbo].[vyuARShippedItems]
AS

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SO.[dtmDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intCompanyLocationId]				= SO.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SO.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= I.[strItemNo] 
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SOD.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intShipmentItemUOMId]				= SOD.[intItemUOMId]
	,[strShipmentUnitMeasure]			= U.[strUnitMeasure]
	,[dblQtyShipped]					= SOD.[dblQtyShipped]	
	,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
	,[dblShipmentQuantity]				= SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000)	
	,[dblShipmentQtyShippedTotal]		= SOD.[dblQtyShipped]
	,[dblQtyRemaining]					= SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000)
	,[dblDiscount]						= SOD.[dblDiscount] 
	,[dblPrice]							= SOD.[dblPrice]
	,[dblShipmentUnitPrice]				= SOD.[dblPrice]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intAccountId]						= SOD.[intAccountId]
	,[intCOGSAccountId]					= SOD.[intCOGSAccountId]
	,[intSalesAccountId]				= SOD.[intSalesAccountId]
	,[intInventoryAccountId]			= SOD.[intInventoryAccountId]
	,[intStorageLocationId]				= SOD.[intStorageLocationId]
	,[strStorageLocationName]			= SL.[strName]
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= SOD.[intTaxGroupId]
	,[strTaxGroup]						= TG.[strTaxGroup]
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
INNER JOIN
	tblICItem I
		ON SOD.[intItemId] = I.[intItemId]
		AND (dbo.fnIsStockTrackingItem(I.[intItemId]) = 0 OR ISNULL(I.strLotTracking, 'No') = 'No')
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
LEFT OUTER JOIN
	tblSMTaxGroup TG
		ON SOD.[intTaxGroupId] = TG.intTaxGroupId
LEFT JOIN (SELECT intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped FROM tblARInvoiceDetail ID GROUP BY intSalesOrderDetailId) AS ID
		ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
WHERE
	SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
		FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
		WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped AND tblARInvoice.ysnPosted = 1)
	AND SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000) > 0.000000
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SO.[dtmDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intCompanyLocationId]				= SO.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SO.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= NULL
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SOD.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intShipmentItemUOMId]				= SOD.[intItemUOMId]
	,[strShipmentUnitMeasure]			= U.[strUnitMeasure]
	,[dblQtyShipped]					= SOD.[dblQtyShipped]
	,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
	,[dblShipmentQuantity]				= SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000)
	,[dblShipmentQtyShippedTotal]		= SOD.[dblQtyShipped]
	,[dblQtyRemaining]					= SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000)
	,[dblDiscount]						= SOD.[dblDiscount]
	,[dblPrice]							= SOD.[dblPrice]
	,[dblShipmentUnitPrice]				= SOD.[dblPrice]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intAccountId]						= SOD.[intAccountId]
	,[intCOGSAccountId]					= SOD.[intCOGSAccountId]
	,[intSalesAccountId]				= SOD.[intSalesAccountId]
	,[intInventoryAccountId]			= SOD.[intInventoryAccountId]
	,[intStorageLocationId]				= SOD.[intStorageLocationId]
	,[strStorageLocationName]			= SL.[strName]
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId]
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= SOD.[intTaxGroupId]
	,[strTaxGroup]						= TG.[strTaxGroup]
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
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
LEFT OUTER JOIN
	tblSMTaxGroup TG
		ON SOD.[intTaxGroupId] = TG.intTaxGroupId
LEFT JOIN (SELECT intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped FROM tblARInvoiceDetail ID GROUP BY intSalesOrderDetailId) AS ID
		ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
WHERE
	SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
		FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
		WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped AND tblARInvoice.ysnPosted = 1)
	AND SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000) > 0.000000
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= SHP.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(SHP.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SHP.[dtmShipDate]
	,[intInventoryShipmentId]			= SHP.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]		= SHP.[intInventoryShipmentItemId]
	,[strInventoryShipmentNumber]		= SHP.[strShipmentNumber] 	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intCompanyLocationId]				= SHP.[intShipFromLocationId]
	,[strLocationName]					= SHP.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SHP.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= I.[strItemNo] 
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SOD.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intShipmentItemUOMId]				= SHP.[intItemUOMId]
	,[strShipmentUnitMeasure]			= SHP.[strUnitMeasure]
	,[dblQtyShipped]					= SOD.[dblQtyShipped]	
	,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
	,[dblShipmentQuantity]				= SHP.[dblQuantity]	
	,[dblShipmentQtyShippedTotal]		= SOD.[dblQtyShipped]
	,[dblQtyRemaining]					= SOD.[dblQtyOrdered]
	,[dblDiscount]						= SOD.[dblDiscount] 
	,[dblPrice]							= SOD.[dblPrice]
	,[dblShipmentUnitPrice]				= SHP.[dblUnitPrice]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intAccountId]						= SOD.[intAccountId]
	,[intCOGSAccountId]					= SOD.[intCOGSAccountId]
	,[intSalesAccountId]				= SOD.[intSalesAccountId]
	,[intInventoryAccountId]			= SOD.[intInventoryAccountId]
	,[intStorageLocationId]				= SOD.[intStorageLocationId]
	,[strStorageLocationName]			= SL.[strName]
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= SCT.[strTicketNumber]
	,[intTicketId]						= SCT.[intTicketId]
	,[intTaxGroupId]					= NULL --SOD.[intTaxGroupId]
	,[strTaxGroup]						= NULL --TG.[strTaxGroup]
	,[dblGrossWt]						= ISISIL.dblGrossWeight 
	,[dblTareWt]						= ISISIL.dblTareWeight 
	,[dblNetWt]							= ISISIL.dblNetWeight
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
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
LEFT JOIN
	tblICItemUOM IU
		ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U
		ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]		
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId] 
LEFT OUTER JOIN
	tblSMTaxGroup TG
		ON SOD.[intTaxGroupId] = TG.intTaxGroupId 
CROSS APPLY
	(
	SELECT 
		 ISI.[intInventoryShipmentItemId]
		,ISH.[strShipmentNumber]
		,ISH.[intInventoryShipmentId]  
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,U.[strUnitMeasure]
		,ISI.[dblUnitPrice]
		,ISI.[intSourceId]
		,dbo.fnCalculateQtyBetweenUOM(ISI.[intItemUOMId], SOD.[intItemUOMId], SUM(ISNULL(ISI.[dblQuantity],0))) dblSOShipped
		,SUM(ISNULL(ISI.dblQuantity,0)) dblShipped
		,ISH.[intShipFromLocationId]
		,ISH.[dtmShipDate]
		,CL.[strLocationName]
		,ISH.[intFreightTermId]
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
	LEFT OUTER JOIN
		[tblSMCompanyLocation] CL
			ON ISH.[intShipFromLocationId] = CL.[intCompanyLocationId]
	LEFT OUTER JOIN
		 tblARInvoiceDetail IND
			ON ISI.[intInventoryShipmentItemId] = IND.[intInventoryShipmentItemId]
	WHERE
		ISH.[ysnPosted] = 1
		AND ISI.[intLineNo] = SOD.[intSalesOrderDetailId]
		AND SO.[strTransactionType] = 'Order' AND SO.strOrderStatus <> 'Cancelled'
		AND IND.[intInventoryShipmentItemId] IS NULL		
	GROUP BY
		 ISI.[intInventoryShipmentItemId]
		,ISH.[strShipmentNumber]
		,ISH.[intInventoryShipmentId]  
		,ISI.[intLineNo]
		,ISI.[intItemId]
		,ISI.[dblQuantity]
		,ISI.[intItemUOMId]
		,ISI.[dblUnitPrice]
		,U.[strUnitMeasure]
		,ISI.[intSourceId]
		,ISH.[intShipFromLocationId]
		,ISH.[dtmShipDate]
		,CL.[strLocationName]
		,ISH.[intFreightTermId]
	) SHP
LEFT OUTER JOIN
	tblSCTicket SCT
		ON SHP.[intSourceId] = SCT.[intTicketId]
LEFT OUTER JOIN
	(
		SELECT
			intInventoryShipmentItemId
			,SUM([dblGrossWeight]) dblGrossWeight
			,SUM([dblTareWeight]) dblTareWeight
			,SUM([dblGrossWeight] - [dblTareWeight]) dblNetWeight
		FROM
			tblICInventoryShipmentItemLot
		GROUP BY
			intInventoryShipmentItemId
	) ISISIL
		ON SHP.[intInventoryShipmentItemId] = ISISIL.[intInventoryShipmentItemId]
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inbound Shipment'
	,[strTransactionNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[strShippedItemId]					= 'lgis:' + CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[intEntityCustomerId]				= LGS.[intCustomerEntityId] 
	,[strCustomerName]					= E.[strName]
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= ISNULL(LGS.dtmShipmentDate, ISNULL(LGS.[dtmInventorizedDate], GETDATE()))
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL	
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= LGS.[intShipmentId]
	,[strShipmentNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[intCompanyLocationId]				= LGS.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName]
	,[intShipToLocationId]				= ISNULL(SL.[intEntityLocationId], EL.[intEntityLocationId])
	,[intFreightTermId]					= NULL
	,[intItemId]						= NULL
	,[strItemNo]						= ''
	,[strItemDescription]				= ''
	,[intItemUOMId]						= NULL
	,[strUnitMeasure]					= ''
	,[intShipmentItemUOMId]				= NULL
	,[strShipmentUnitMeasure]			= ''
	,[dblQtyShipped]					= 0.00
	,[dblQtyOrdered]					= 0.00
	,[dblShipmentQuantity]				= 0.00
	,[dblShipmentQtyShippedTotal]		= 0.00
	,[dblQtyRemaining]					= 0.00
	,[dblDiscount]						= 0.00
	,[dblPrice]							= 0.00
	,[dblShipmentUnitPrice]				= 0.00
	,[dblTotalTax]						= 0.00
	,[dblTotal]							= 0.00
	,[intAccountId]						= NULL
	,[intCOGSAccountId]					= NULL
	,[intSalesAccountId]				= NULL
	,[intInventoryAccountId]			= NULL
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= NULL
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= NULL
	,[strTaxGroup]						= NULL
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
FROM
	vyuLGShipmentHeader LGS		
INNER JOIN
	tblARCustomer C
		ON LGS.[intCustomerEntityId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEntity E
		ON C.[intEntityCustomerId]  = E.[intEntityId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON LGS.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
		(	SELECT 
				 [intEntityLocationId]
				,[strLocationName]
				,[strAddress]
				,[intEntityId] 
				,[strCountry]
				,[strState]
				,[strCity]
				,[strZipCode]
				,[intTermsId]
				,[intShipViaId]
			FROM 
				tblEntityLocation
			WHERE
				ysnDefaultLocation = 1
		) EL
			ON LGS.[intCustomerEntityId] = EL.[intEntityId]
LEFT OUTER JOIN
	tblEntityLocation SL
		ON C.intShipToId = SL.intEntityLocationId
LEFT OUTER JOIN
	tblARInvoice ARI
		ON LGS.[intShipmentId] = ARI.[intShipmentId]
WHERE
	ARI.[intInvoiceId] IS NULL
	AND LGS.[intShipmentId] IN (SELECT [intShipmentId] FROM vyuLGDropShipmentDetails)
	AND LGS.[ysnInventorized] = 1