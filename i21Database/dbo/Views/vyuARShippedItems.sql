CREATE VIEW [dbo].[vyuARShippedItems]
AS

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SO.[dtmDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= CTCD.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= CTCD.[intContractSeq]
	,[intCompanyLocationId]				= SO.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SO.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= I.[strItemNo] 
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SOD.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intOrderUOMId]					= SOD.[intItemUOMId]
	,[strOrderUnitMeasure]				= U.[strUnitMeasure]
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
	,[dblWeight]						= [dbo].[fnCalculateQtyBetweenUOM](IU2.[intItemUOMId],SOD.[intItemUOMId],1) --IU.[dblWeight]
	,[intWeightUOMId]					= IU.[intWeightUOMId]
	,[strWeightUnitMeasure]				= U2.[strUnitMeasure]
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
	,[intEntitySalespersonId]			= SO.[intEntitySalespersonId]
	,[strSalespersonName]				= ESP.[strName]
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
	tblEMEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId]
LEFT OUTER JOIN 
	vyuCTContractDetailView CTCD	
		ON SOD.[intContractHeaderId] = CTCD.[intContractHeaderId]
		AND SOD.[intContractDetailId] = CTCD.[intContractDetailId]
LEFT JOIN
	tblEMEntity ESP
		ON SO.[intEntitySalespersonId] = ESP.[intEntityId]
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
LEFT JOIN
	tblICUnitMeasure U2
		ON IU.[intWeightUOMId] = U2.[intUnitMeasureId]
LEFT JOIN
	tblICItemUOM IU2
		ON IU.[intWeightUOMId] = IU2.[intUnitMeasureId]
		AND  SOD.[intItemId] = IU2.[intItemId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMTaxGroup TG
		ON SOD.[intTaxGroupId] = TG.intTaxGroupId
LEFT OUTER JOIN 
	(SELECT intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped FROM tblARInvoiceDetail ID GROUP BY intSalesOrderDetailId) AS ID
		ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
LEFT OUTER JOIN
	(SELECT D.intLineNo FROM tblICInventoryShipmentItem D INNER JOIN tblICInventoryShipment H ON H.[intInventoryShipmentId] = D.[intInventoryShipmentId] WHERE H.[intOrderType] = 2) ISD
		ON SOD.[intSalesOrderDetailId] = ISD.[intLineNo] 
		
WHERE
	SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000) > 0.000000
	AND ISNULL(ISD.[intLineNo],0) = 0
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SO.[dtmDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= CTCD.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= CTCD.[intContractSeq]
	,[intCompanyLocationId]				= SO.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SO.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= NULL
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SOD.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intOrderUOMId]					= SOD.[intItemUOMId]
	,[strOrderUnitMeasure]				= U.[strUnitMeasure]
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
	,[dblWeight]						= [dbo].[fnCalculateQtyBetweenUOM](IU2.[intItemUOMId],SOD.[intItemUOMId],1) --IU.[dblWeight]
	,[intWeightUOMId]					= IU.[intWeightUOMId]
	,[strWeightUnitMeasure]				= U2.[strUnitMeasure]
	,[dblGrossWt]						= 0.00	
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
	,[intEntitySalespersonId]			= SO.[intEntitySalespersonId]
	,[strSalespersonName]				= ESP.[strName]
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
	tblEMEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId] 
LEFT OUTER JOIN 
	vyuCTContractDetailView CTCD	
		ON SOD.[intContractHeaderId] = CTCD.[intContractHeaderId]
		AND SOD.[intContractDetailId] = CTCD.[intContractDetailId]
LEFT JOIN
	tblEMEntity ESP
		ON SO.[intEntitySalespersonId] = ESP.[intEntityId]
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
LEFT JOIN
	tblICUnitMeasure U2
		ON IU.[intWeightUOMId] = U2.[intUnitMeasureId]
LEFT JOIN
	tblICItemUOM IU2
		ON IU.[intWeightUOMId] = IU2.[intUnitMeasureId]
		AND  SOD.[intItemId] = IU2.[intItemId]
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
		WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped)
	AND SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(ID.[dblQtyShipped], 0.000000) > 0.000000
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= SHP.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(SHP.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= SOD.[intSalesOrderDetailId]
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SHP.[dtmShipDate]
	,[intInventoryShipmentId]			= SHP.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]		= SHP.[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= SHP.[strShipmentNumber] 	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= CTCD.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= CTCD.[intContractSeq]
	,[intCompanyLocationId]				= SHP.[intShipFromLocationId]
	,[strLocationName]					= SHP.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SHP.[intFreightTermId]
	,[intItemId]						= SOD.[intItemId]	
	,[strItemNo]						= I.[strItemNo] 
	,[strItemDescription]				= SOD.[strItemDescription]
	,[intItemUOMId]						= SHP.[intItemUOMId]
	,[strUnitMeasure]					= SHP.[strUnitMeasure]
	,[intOrderUOMId]					= SOD.[intItemUOMId]
	,[strOrderUnitMeasure]				= U.[strUnitMeasure]
	,[intShipmentItemUOMId]				= SHP.[intItemUOMId]
	,[strShipmentUnitMeasure]			= SHP.[strUnitMeasure]
	,[dblQtyShipped]					= SHP.[dblQuantity]	
	,[dblQtyOrdered]					= SOD.[dblQtyOrdered] 
	,[dblShipmentQuantity]				= SHP.[dblQuantity]	
	,[dblShipmentQtyShippedTotal]		= SHP.[dblQuantity]
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
	,[intTaxGroupId]					= SOD.[intTaxGroupId]
	,[strTaxGroup]						= TG.[strTaxGroup]
	,[dblWeight]						= [dbo].[fnCalculateQtyBetweenUOM](IU2.[intItemUOMId],SOD.[intItemUOMId],1) --IU1.[dblWeight]
	,[intWeightUOMId]					= IU2.[intUnitMeasureId]
	,[strWeightUnitMeasure]				= U2.[strUnitMeasure]
	,[dblGrossWt]						= ISISIL.dblGrossWeight 
	,[dblTareWt]						= ISISIL.dblTareWeight 
	,[dblNetWt]							= ISISIL.dblNetWeight
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
	,[intEntitySalespersonId]			= SO.[intEntitySalespersonId]
	,[strSalespersonName]				= ESP.[strName]
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
LEFT OUTER JOIN 
	vyuCTContractDetailView CTCD	
		ON SOD.[intContractHeaderId] = CTCD.[intContractHeaderId]
		AND SOD.[intContractDetailId] = CTCD.[intContractDetailId]
INNER JOIN
	tblEMEntity E
		ON C.[intEntityCustomerId] = E.[intEntityId]
LEFT JOIN
	tblEMEntity ESP
		ON SO.[intEntitySalespersonId] = ESP.[intEntityId] 
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
		,ISI.[intWeightUOMId]
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
		,ISI.[intWeightUOMId]
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
LEFT JOIN
	tblICItemUOM IU1
		ON SHP.[intItemUOMId] = IU1.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U1
		ON IU1.[intUnitMeasureId] = U1.[intUnitMeasureId]	
LEFT JOIN
	tblICItemUOM IU2
		ON SHP.[intWeightUOMId] = IU2.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U2
		ON IU2.[intUnitMeasureId] = U2.[intUnitMeasureId]
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON SHP.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0			
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(CTCD.[intCurrencyId], ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= ICIS.[dtmShipDate] 
	,[intInventoryShipmentId]			= ICIS.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]		= ICISI.[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ICIS.[strShipmentNumber] 	
	,[intShipmentId]					= LGICShipment.[intShipmentId]
	,[strShipmentNumber]				= NULL
	,[intContractHeaderId]				= ISNULL(CTCD.[intContractHeaderId], LGICShipment.[intContractHeaderId])
	,[strContractNumber]				= ISNULL(CTCD.[strContractNumber], LGICShipment.[strContractNumber])
	,[intContractDetailId]				= ISNULL(CTCD.[intContractDetailId], LGICShipment.[intContractDetailId])
	,[intContractSeq]					= ISNULL(CTCD.[intContractSeq], LGICShipment.[intContractSeq])
	,[intCompanyLocationId]				= ICIS.[intShipFromLocationId]
	,[strLocationName]					= SMCL.[strLocationName] 
	,[intShipToLocationId]				= ICIS.[intShipToLocationId]
	,[intFreightTermId]					= ICIS.[intFreightTermId]
	,[intItemId]						= ICISI.[intItemId]	
	,[strItemNo]						= ICI.[strItemNo] 
	,[strItemDescription]				= ICI.[strDescription] 
	,[intItemUOMId]						= ICISI.[intItemUOMId]
	,[strUnitMeasure]					= ICUM.[strUnitMeasure]
	,[intOrderUOMId]					= CTCD.[intItemUOMId]
	,[strOrderUnitMeasure]				= ISNULL(ICUM2.[strUnitMeasure],'')
	,[intShipmentItemUOMId]				= ICISI.[intItemUOMId]
	,[strShipmentUnitMeasure]			= ICUM1.[strUnitMeasure]
	,[dblQtyShipped]					= ICISI.[dblQuantity] 	
	,[dblQtyOrdered]					= CASE WHEN CTCD.[intContractDetailId] IS NOT NULL THEN CTCD.dblDetailQuantity ELSE 0 END 
	,[dblShipmentQuantity]				= ICISI.[dblQuantity] --dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0))
	,[dblShipmentQtyShippedTotal]		= ICISI.[dblQuantity]
	,[dblQtyRemaining]					= ICISI.[dblQuantity]
	,[dblDiscount]						= 0 
	,[dblPrice]							= ICISI.[dblUnitPrice]
	,[dblShipmentUnitPrice]				= ICISI.[dblUnitPrice]
	,[dblTotalTax]						= 0
	,[dblTotal]							= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) * ICISI.[dblUnitPrice]
	,[intAccountId]						= ARIA.[intAccountId]
	,[intCOGSAccountId]					= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]				= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]			= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]				= ICISI.[intStorageLocationId]
	,[strStorageLocationName]			= ICSL.[strName]
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= NULL --SOD.[intTaxGroupId]
	,[strTaxGroup]						= NULL --TG.[strTaxGroup]
	,[dblWeight]						= [dbo].[fnCalculateQtyBetweenUOM](ICISI.[intWeightUOMId],ICISI.[intItemUOMId],1) --ICIU1.[dblWeight]
	,[intWeightUOMId]					= ICIU2.[intUnitMeasureId]
	,[strWeightUnitMeasure]				= ICIU2.[strUnitMeasure]
	,[dblGrossWt]						= ISISIL.dblGrossWeight 
	,[dblTareWt]						= ISISIL.dblTareWeight 
	,[dblNetWt]							= ISISIL.dblNetWeight
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= ''
FROM
	tblICInventoryShipmentItem ICISI
INNER JOIN
	tblICInventoryShipment ICIS
		ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
		AND ICIS.[intOrderType] <> 2
		AND ICIS.[ysnPosted] = 1
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
		ON ICISI.[intInventoryShipmentItemId] = ISISIL.[intInventoryShipmentItemId]
LEFT OUTER JOIN
	(
		SELECT TOP 1
			 LGSD.[intShipmentId]
			,LGSD.[intTrackingNumber]
			,ICISI1.[intInventoryShipmentItemId]
			,LGSD.[intContractDetailId]
			,LGSD.[strContractNumber] 
			,LGSD.[intContractHeaderId]
			,LGSD.[intContractSeq] 
		FROM
			tblICInventoryShipmentItem ICISI1
		INNER JOIN
			tblICInventoryShipmentItemLot ICISIL1
				ON ICISI1.[intInventoryShipmentItemId] = ICISIL1.[intInventoryShipmentItemId]
		INNER JOIN
			tblICInventoryLot ICIL1
				ON ICISIL1.[intLotId] = ICIL1.[intLotId] 
				AND ICIL1.[ysnIsUnposted] = 0
		INNER JOIN tblICInventoryReceiptItem ICIRI1
				ON ICIL1.[intTransactionDetailId] = ICIRI1.[intInventoryReceiptItemId]
		INNER JOIN vyuLGShipmentContainerPurchaseContracts LGSD
				ON ICIRI1.[intLineNo] = LGSD.[intContractDetailId]
	) LGICShipment
		ON ICISI.[intInventoryShipmentItemId] = LGICShipment.[intInventoryShipmentItemId]
LEFT OUTER JOIN 
	vyuCTContractDetailView CTCD	
		ON ICISI.[intLineNo] = CTCD.[intContractDetailId]
		AND ICIS.[intOrderType] = 1 
INNER JOIN
	tblARCustomer ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	tblICItem ICI
		ON ICISI.[intItemId] = ICI.[intItemId]
LEFT JOIN
	tblICItemUOM ICIU
		ON ICISI.[intItemUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	tblICUnitMeasure ICUM
		ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]	
LEFT JOIN
	tblICItemUOM ICIU1
		ON ICISI.[intItemUOMId] = ICIU1.[intItemUOMId] 
LEFT JOIN
	tblICUnitMeasure ICUM1
		ON ICIU1.[intUnitMeasureId] = ICUM1.[intUnitMeasureId]
LEFT JOIN
	tblICUnitMeasure ICUM2
		ON CTCD.[intUnitMeasureId] = ICUM2.[intUnitMeasureId]
LEFT JOIN
	tblICItemUOM ICUM3
		ON ICISI.[intWeightUOMId] = ICUM3.[intItemUOMId]				
LEFT JOIN
	tblICUnitMeasure ICIU2
		ON ICUM3.[intUnitMeasureId] = ICIU2.[intUnitMeasureId]					
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	vyuARGetItemAccount ARIA
		ON ICISI.[intItemId] = ARIA.[intItemId]
		AND ICIS.[intShipFromLocationId] = ARIA.[intLocationId]	
LEFT OUTER JOIN
	tblICStorageLocation ICSL
		ON ICISI.[intStorageLocationId] = ICSL.[intStorageLocationId]				
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] SMCL
		ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]	
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0

UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ISNULL(ICISC.[intCurrencyId], CTCD.[intCurrencyId]),ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= ICIS.[dtmShipDate] 
	,[intInventoryShipmentId]			= ICIS.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= ICISC.[intInventoryShipmentChargeId]
	,[strInventoryShipmentNumber]		= ICIS.[strShipmentNumber] 	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intContractHeaderId]				= CTCD.[intContractHeaderId]
	,[strContractNumber]				= CTCD.[strContractNumber]
	,[intContractDetailId]				= CTCD.[intContractDetailId]
	,[intContractSeq]					= CTCD.[intContractSeq]
	,[intCompanyLocationId]				= ICIS.[intShipFromLocationId]
	,[strLocationName]					= SMCL.[strLocationName] 
	,[intShipToLocationId]				= ICIS.[intShipToLocationId]
	,[intFreightTermId]					= ICIS.[intFreightTermId]
	,[intItemId]						= ICISC.[intChargeId]	
	,[strItemNo]						= ICI.[strItemNo] 
	,[strItemDescription]				= ICI.[strDescription] 
	,[intItemUOMId]						= ICISC.[intCostUOMId]
	,[strUnitMeasure]					= ICUM.[strUnitMeasure]
	,[strOrderUnitMeasure]				= ''
	,[intShipmentItemUOMId]				= NULL		
	,[intShipmentItemUOMId]				= ICISC.[intCostUOMId]
	,[strShipmentUnitMeasure]			= ICUM.[strUnitMeasure]
	,[dblQtyShipped]					= 1 	
	,[dblQtyOrdered]					= 0 
	,[dblShipmentQuantity]				= 1
	,[dblShipmentQtyShippedTotal]		= 1
	,[dblQtyRemaining]					= 1
	,[dblDiscount]						= 0 
	,[dblPrice]							= ICISC.[dblAmount]
	,[dblShipmentUnitPrice]				= ICISC.[dblAmount]
	,[dblTotalTax]						= 0
	,[dblTotal]							= 1 * ICISC.[dblAmount]
	,[intAccountId]						= ARIA.[intAccountId]
	,[intCOGSAccountId]					= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]				= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]			= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= NULL
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= NULL --SOD.[intTaxGroupId]
	,[strTaxGroup]						= NULL --TG.[strTaxGroup]
	,[dblWeight]						= 0.00
	,[intWeightUOMId]					= NULL
	,[strWeightUnitMeasure]				= ''
	,[dblGrossWt]						= 0
	,[dblTareWt]						= 0
	,[dblNetWt]							= 0
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= ''
FROM
	tblICInventoryShipmentCharge ICISC
INNER JOIN
	tblICInventoryShipment ICIS
		ON ICISC.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
		AND ICIS.[ysnPosted] = 1
LEFT OUTER JOIN 
	vyuCTContractDetailView CTCD	
		ON ICISC.[intContractId] = CTCD.[intContractHeaderId]
INNER JOIN
	tblARCustomer ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	tblICItem ICI
		ON ICISC.[intChargeId] = ICI.[intItemId]
LEFT JOIN
	tblICItemUOM ICIU
		ON ICISC.[intCostUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	tblICUnitMeasure ICUM
		ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]		
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	vyuARGetItemAccount ARIA
		ON ICISC.[intChargeId] = ARIA.[intItemId]
		AND ICIS.[intShipFromLocationId] = ARIA.[intLocationId]			
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON ICISC.intInventoryShipmentChargeId = ARID.[intInventoryShipmentChargeId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] SMCL
		ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]	
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0

UNION ALL

SELECT
	 [strTransactionType]				= 'Inbound Shipment'
	,[strTransactionNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[strShippedItemId]					= 'lgis:' + CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[intEntityCustomerId]				= LGS.[intCustomerEntityId] 
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ARSID.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= ISNULL(LGS.dtmShipmentDate, ISNULL(LGS.[dtmInventorizedDate], GETDATE()))
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL	
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= LGS.[intShipmentId]
	,[strShipmentNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
	,[intContractHeaderId]				= NULL
	,[strContractNumber]				= ''
	,[intContractDetailId]				= NULL
	,[intContractSeq]					= NULL
	,[intCompanyLocationId]				= LGS.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName]
	,[intShipToLocationId]				= ISNULL(SL.[intEntityLocationId], EL.[intEntityLocationId])
	,[intFreightTermId]					= NULL
	,[intItemId]						= NULL
	,[strItemNo]						= ''
	,[strItemDescription]				= ''
	,[intItemUOMId]						= NULL
	,[strUnitMeasure]					= ''
	,[intOrderUOMId]					= NULL
	,[strOrderUnitMeasure]				= ''
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
	,[dblWeight]						= 0.00
	,[intWeightUOMId]					= NULL
	,[strWeightUnitMeasure]				= ''
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= NULL
FROM
	vyuARShippedItemDetail ARSID
INNER JOIN
	vyuLGShipmentHeader LGS		
		ON ARSID.[intShipmentId] = LGS.[intShipmentId]
INNER JOIN
	tblARCustomer C
		ON LGS.[intCustomerEntityId] = C.[intEntityCustomerId] 
INNER JOIN
	tblEMEntity E
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
				[tblEMEntityLocation]
			WHERE
				ysnDefaultLocation = 1
		) EL
			ON LGS.[intCustomerEntityId] = EL.[intEntityId]
LEFT OUTER JOIN
	[tblEMEntityLocation] SL
		ON C.intShipToId = SL.intEntityLocationId
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON LGS.[intShipmentId] = ARID.[intShipmentId]
WHERE
	ARID.[intInvoiceId] IS NULL
	AND LGS.[intShipmentId] IN (SELECT [intShipmentId] FROM vyuLGDropShipmentDetails)
	AND LGS.[ysnInventorized] = 1