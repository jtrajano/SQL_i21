﻿CREATE VIEW [dbo].[vyuARShippedItems]
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
	,[intLoadId]						= NULL
	,[intLoadDetailId]					= NULL
	,[strLoadNumber]					= NULL
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= ARCR.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= ARCR.[intContractSeq]
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
	,[dblShipmentQuantity]				= SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000)	
	,[dblShipmentQtyShippedTotal]		= SOD.[dblQtyShipped]
	,[dblQtyRemaining]					= SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000)
	,[dblDiscount]						= SOD.[dblDiscount] 
	,[dblPrice]							= SOD.[dblPrice]
	,[dblShipmentUnitPrice]				= SOD.[dblPrice]
	,[strPricing]						= SOD.[strPricing]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
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
	,[ysnBlended]						= SOD.[ysnBlended]
	,[intRecipeId]						= SOD.[intRecipeId]
	,[intSubLocationId]					= SOD.[intSubLocationId]
	,[intCostTypeId]					= SOD.[intCostTypeId]
	,[intMarginById]					= SOD.[intMarginById]
	,[intCommentTypeId]					= SOD.[intCommentTypeId]
	,[dblMargin]						= SOD.[dblMargin]
	,[dblRecipeQuantity]				= SOD.[dblRecipeQuantity]
	,[intStorageScheduleTypeId]			= SOD.[intStorageScheduleTypeId]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
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
	vyuARCustomerContract ARCR	
		ON SOD.[intContractHeaderId] = ARCR.[intContractHeaderId]
		AND SOD.[intContractDetailId] = ARCR.[intContractDetailId]
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
	(SELECT D.intLineNo FROM tblICInventoryShipmentItem D INNER JOIN tblICInventoryShipment H ON H.[intInventoryShipmentId] = D.[intInventoryShipmentId] WHERE H.[intOrderType] = 2) ISD
		ON SOD.[intSalesOrderDetailId] = ISD.[intLineNo]
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID] 		
WHERE
	SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000) <> 0.000000
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
	,[intLoadId]						= NULL
	,[intLoadDetailId]					= NULL
	,[strLoadNumber]					= NULL
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= ARCC.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= ARCC.[intContractSeq]
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
	,[dblShipmentQuantity]				= SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000)
	,[dblShipmentQtyShippedTotal]		= SOD.[dblQtyShipped]
	,[dblQtyRemaining]					= SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000)
	,[dblDiscount]						= SOD.[dblDiscount]
	,[dblPrice]							= SOD.[dblPrice]	
	,[dblShipmentUnitPrice]				= SOD.[dblPrice]
	,[strPricing]						= SOD.[strPricing]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
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
	,[ysnBlended]						= SOD.[ysnBlended]
	,[intRecipeId]						= SOD.[intRecipeId]
	,[intSubLocationId]					= SOD.[intSubLocationId]
	,[intCostTypeId]					= SOD.[intCostTypeId]
	,[intMarginById]					= SOD.[intMarginById]
	,[intCommentTypeId]					= SOD.[intCommentTypeId]
	,[dblMargin]						= SOD.[dblMargin]
	,[dblRecipeQuantity]				= SOD.[dblRecipeQuantity]
	,[intStorageScheduleTypeId]			= SOD.[intStorageScheduleTypeId]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
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
	vyuARCustomerContract ARCC	
		ON SOD.[intContractHeaderId] = ARCC.[intContractHeaderId]
		AND SOD.[intContractDetailId] = ARCC.[intContractDetailId]
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
	tblSMCurrency SMC
		ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID] 
WHERE
	SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
		FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
		WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped)
	AND SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000) <> 0.000000
	
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
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= SOD.[intContractHeaderId]
	,[strContractNumber]				= ARCC.[strContractNumber]
	,[intContractDetailId]				= SOD.[intContractDetailId]
	,[intContractSeq]					= ARCC.[intContractSeq]
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
	,[strPricing]						= SOD.[strPricing]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intStorageLocationId]				= ISNULL(SHP.intStorageLocationId, SOD.[intStorageLocationId])
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
	,[ysnBlended]						= SOD.[ysnBlended]
	,[intRecipeId]						= SOD.[intRecipeId]
	,[intSubLocationId]					= ISNULL(SHP.intSubLocationId, SOD.[intSubLocationId])
	,[intCostTypeId]					= SOD.[intCostTypeId]
	,[intMarginById]					= SOD.[intMarginById]
	,[intCommentTypeId]					= SOD.[intCommentTypeId]
	,[dblMargin]						= SOD.[dblMargin]
	,[dblRecipeQuantity]				= SOD.[dblRecipeQuantity]
	,[intStorageScheduleTypeId]			= SOD.[intStorageScheduleTypeId]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblSOSalesOrderDetail SOD
		ON SO.[intSalesOrderId] = SOD.[intSalesOrderId]
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
LEFT OUTER JOIN 
	vyuARCustomerContract ARCC	
		ON SOD.[intContractHeaderId] = ARCC.[intContractHeaderId]
		AND SOD.[intContractDetailId] = ARCC.[intContractDetailId]
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
		,ISI.intSubLocationId
		,ISI.intStorageLocationId
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
		,ISI.intSubLocationId
		,ISI.intStorageLocationId
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
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
	tblICStorageLocation SL
		ON ISNULL(SHP.[intStorageLocationId], SOD.[intStorageLocationId]) = SL.[intStorageLocationId]
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0			
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ARCC.[intCurrencyId], ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= ISNULL(ARCC.[intContractHeaderId], LGICShipment.[intContractHeaderId])
	,[strContractNumber]				= ISNULL(ARCC.[strContractNumber], LGICShipment.[strContractNumber])
	,[intContractDetailId]				= ISNULL(ARCC.[intContractDetailId], LGICShipment.[intContractDetailId])
	,[intContractSeq]					= ISNULL(ARCC.[intContractSeq], LGICShipment.[intContractSeq])
	,[intCompanyLocationId]				= ICIS.[intShipFromLocationId]
	,[strLocationName]					= SMCL.[strLocationName] 
	,[intShipToLocationId]				= ICIS.[intShipToLocationId]
	,[intFreightTermId]					= ICIS.[intFreightTermId]
	,[intItemId]						= ICISI.[intItemId]	
	,[strItemNo]						= ICI.[strItemNo] 
	,[strItemDescription]				= ICI.[strDescription] 
	,[intItemUOMId]						= ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId])
	,[strUnitMeasure]					= ISNULL(ARCC.[strUnitMeasure], ICUM.[strUnitMeasure])
	,[intOrderUOMId]					= ARCC.[intOrderUOMId]
	,[strOrderUnitMeasure]				= ARCC.[strOrderUnitMeasure]
	,[intShipmentItemUOMId]				= ICISI.[intItemUOMId]
	,[strShipmentUnitMeasure]			= ICUM1.[strUnitMeasure]
	,[dblQtyShipped]					= ISNULL(ARCC.[dblShipQuantity], ICISI.[dblQuantity]) 	
	,[dblQtyOrdered]					= CASE WHEN ARCC.[intContractDetailId] IS NOT NULL THEN ARCC.dblDetailQuantity ELSE 0 END 
	,[dblShipmentQuantity]				= ISNULL(ARCC.[dblShipQuantity], ICISI.[dblQuantity])  --dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0))
	,[dblShipmentQtyShippedTotal]		= ISNULL(ARCC.[dblShipQuantity], ICISI.[dblQuantity]) 
	,[dblQtyRemaining]					= ISNULL(ARCC.[dblShipQuantity], ICISI.[dblQuantity]) 
	,[dblDiscount]						= 0 
	,[dblPrice]							= ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[dblShipmentUnitPrice]				= ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) * ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[intStorageLocationId]				= ICISI.[intStorageLocationId]
	,[strStorageLocationName]			= ICSL.[strName]
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= SCT.strTicketNumber
	,[intTicketId]						= SCT.intTicketId
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
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= ARCC.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= ARCC.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
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
	vyuARCustomerContract ARCC	
		ON ICISI.[intLineNo] = ARCC.[intContractDetailId]
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
	tblICItemUOM ICUM3
		ON ICISI.[intWeightUOMId] = ICUM3.[intItemUOMId]				
LEFT JOIN
	tblICUnitMeasure ICIU2
		ON ICUM3.[intUnitMeasureId] = ICIU2.[intUnitMeasureId]					
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	tblICStorageLocation ICSL
		ON ICISI.[intStorageLocationId] = ICSL.[intStorageLocationId]				
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] SMCL
		ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON ARCC.[intSubCurrencyId] = SMC.[intCurrencyID]	
LEFT OUTER JOIN
	tblSCTicket SCT
		ON ICISI.[intSourceId] = SCT.[intTicketId]
						
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0

UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ISNULL(ICISC.[intCurrencyId], ARCC.[intCurrencyId]),ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= ARCC.[intContractHeaderId]
	,[strContractNumber]				= ARCC.[strContractNumber]
	,[intContractDetailId]				= ARCC.[intContractDetailId]
	,[intContractSeq]					= ARCC.[intContractSeq]
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
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= 1 * ICISC.[dblAmount]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= NULL
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= SCT.strTicketNumber
	,[intTicketId]						= SCT.intTicketId
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
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= ICISC.[intCurrencyId]
	,[dblSubCurrencyRate]				= ICISC.[dblRate] 
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	tblICInventoryShipmentCharge ICISC
INNER JOIN
	tblICInventoryShipment ICIS
		ON ICISC.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
		AND ICIS.[ysnPosted] = 1
		AND ISNULL(ICISC.[ysnPrice],0) = 1
INNER JOIN	
		tblICInventoryShipmentItem ICISI 
			ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
LEFT OUTER JOIN 
	vyuARCustomerContract ARCC	
		ON ICISC.[intContractId] = ARCC.[intContractHeaderId]
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
	tblARInvoiceDetail ARID
		ON ICISC.intInventoryShipmentChargeId = ARID.[intInventoryShipmentChargeId]
LEFT OUTER JOIN
	[tblSMCompanyLocation] SMCL
		ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON ICISC.[intCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
    tblSCTicket SCT
        ON ICISI.[intSourceId] = SCT.[intTicketId]
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
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= NULL
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
	,[strPricing]						= ''
	,[dblTotalTax]						= 0.00
	,[dblTotal]							= 0.00
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
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= ARSID.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= ARSID.[dblSubCurrencyRate]
	,[strSubCurrency]					= ARSID.[strSubCurrency]
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


UNION ALL

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= SO.[intSalesOrderId]
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= SO.[strSalesOrderNumber]
	,[dtmProcessDate]					= SO.[dtmDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ''	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= MFG.[intRecipeItemId] 
	,[intContractHeaderId]				= NULL
	,[strContractNumber]				= NULL
	,[intContractDetailId]				= NULL
	,[intContractSeq]					= NULL
	,[intCompanyLocationId]				= SO.[intCompanyLocationId]
	,[strLocationName]					= CL.[strLocationName] 
	,[intShipToLocationId]				= SO.[intShipToLocationId]
	,[intFreightTermId]					= SO.[intFreightTermId]
	,[intItemId]						= MFG.[intItemId]	
	,[strItemNo]						= I.[strItemNo] 
	,[strItemDescription]				= I.[strDescription] 
	,[intItemUOMId]						= MFG.[intItemUOMId]
	,[strUnitMeasure]					= U.[strUnitMeasure]
	,[intOrderUOMId]					= MFG.[intItemUOMId]
	,[strOrderUnitMeasure]				= U.[strUnitMeasure]
	,[intShipmentItemUOMId]				= MFG.[intItemUOMId]
	,[strShipmentUnitMeasure]			= U.[strUnitMeasure]
	,[dblQtyShipped]					= MFG.[dblQuantity]	
	,[dblQtyOrdered]					= MFG.[dblQuantity]	 
	,[dblShipmentQuantity]				= MFG.[dblQuantity]		
	,[dblShipmentQtyShippedTotal]		= MFG.[dblQuantity]	
	,[dblQtyRemaining]					= MFG.[dblQuantity]	
	,[dblDiscount]						= 0.00
	,[dblPrice]							= MFG.[dblPrice]
	,[dblShipmentUnitPrice]				= MFG.[dblPrice]
	,[strPricing]						= ''
	,[dblTotalTax]						= 0.00
	,[dblTotal]							= MFG.[dblLineTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= ''
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= NULL
	,[strTaxGroup]						= ''
	,[dblWeight]						= 0.00
	,[intWeightUOMId]					= NULL
	,[strWeightUnitMeasure]				= ''
	,[dblGrossWt]						= 0.00
	,[dblTareWt]						= 0.00
	,[dblNetWt]							= 0.00
	,[strPONumber]						= SO.[strPONumber]
	,[strBOLNumber]						= SO.[strBOLNumber]
	,[intSplitId]						= SO.[intSplitId]
	,[intEntitySalespersonId]			= SO.[intEntitySalespersonId]
	,[strSalespersonName]				= ESP.[strName]
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= NULL
	,[dblSubCurrencyRate]				= 1
	,[strSubCurrency]					= ''
FROM
	tblSOSalesOrder SO
CROSS APPLY
	[dbo].[fnMFGetInvoiceChargesByShipment](0,SO.[intSalesOrderId]) MFG
INNER JOIN
	tblICItem I
		ON MFG.[intItemId] = I.[intItemId]
INNER JOIN
	tblARCustomer C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
LEFT JOIN
	tblICItemUOM IU
		ON MFG.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure U
		ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblARInvoiceDetail	ARID
		ON MFG.[intRecipeItemId] = ARID.[intRecipeItemId]
LEFT OUTER JOIN
	(SELECT D.[intOrderId] FROM tblICInventoryShipmentItem D INNER JOIN tblICInventoryShipment H ON H.[intInventoryShipmentId] = D.[intInventoryShipmentId] WHERE H.[intOrderType] = 2) ISD
		ON SO.[intSalesOrderId] = ISD.[intOrderId] 
WHERE
	SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	AND ISNULL(ARID.[intRecipeItemId],0) = 0
	AND ISNULL(ISD.[intOrderId],0) = 0	

UNION ALL

SELECT DISTINCT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ICISI.[intCurrencyId],ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= ICIS.[dtmShipDate] 
	,[intInventoryShipmentId]			= ICIS.[intInventoryShipmentId]
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= ICIS.[strShipmentNumber] 	
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intLoadId]						= NULL
	,[strLoadNumber]					= NULL
	,[intLoadDetailId]					= NULL
	,[intRecipeItemId]					= MFG.[intRecipeItemId]
	,[intContractHeaderId]				= NULL
	,[strContractNumber]				= NULL
	,[intContractDetailId]				= NULL
	,[intContractSeq]					= NULL
	,[intCompanyLocationId]				= ICIS.[intShipFromLocationId]
	,[strLocationName]					= SMCL.[strLocationName] 
	,[intShipToLocationId]				= ICIS.[intShipToLocationId]
	,[intFreightTermId]					= ICIS.[intFreightTermId]
	,[intItemId]						= MFG.[intItemId]	
	,[strItemNo]						= ICI.[strItemNo] 
	,[strItemDescription]				= ICI.[strDescription] 
	,[intItemUOMId]						= MFG.[intItemUOMId]
	,[strUnitMeasure]					= ICUM.[strUnitMeasure]
	,[strOrderUnitMeasure]				= ''
	,[intShipmentItemUOMId]				= NULL		
	,[intShipmentItemUOMId]				= MFG.[intItemUOMId]
	,[strShipmentUnitMeasure]			= ICUM.[strUnitMeasure]
	,[dblQtyShipped]					= MFG.[dblQuantity] 	
	,[dblQtyOrdered]					= 0
	,[dblShipmentQuantity]				= MFG.[dblQuantity]
	,[dblShipmentQtyShippedTotal]		= MFG.[dblQuantity]
	,[dblQtyRemaining]					= MFG.[dblQuantity]
	,[dblDiscount]						= 0 
	,[dblPrice]							= MFG.[dblPrice]
	,[dblShipmentUnitPrice]				= MFG.[dblPrice]
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= MFG.[dblLineTotal]
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
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= ICISI.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	tblICInventoryShipmentItem ICISI
CROSS APPLY
	[dbo].[fnMFGetInvoiceChargesByShipment](ICISI.[intInventoryShipmentItemId],0) MFG	
INNER JOIN
	tblICInventoryShipment ICIS
		ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
		AND ICIS.[ysnPosted] = 1
INNER JOIN
	tblARCustomer ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	tblICItem ICI
		ON MFG.[intItemId] = ICI.[intItemId]
LEFT JOIN
	tblICItemUOM ICIU
		ON MFG.[intItemUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	tblICUnitMeasure ICUM
		ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]		
INNER JOIN
	tblEMEntity EME
		ON ARC.[intEntityCustomerId] = EME.[intEntityId]			
LEFT OUTER JOIN
	tblARInvoiceDetail ARID
		ON MFG.[intRecipeItemId] = ARID.[intRecipeItemId]
		AND ICIS.[strShipmentNumber] = ARID.[strShipmentNumber]
LEFT OUTER JOIN
	[tblSMCompanyLocation] SMCL
		ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]	
LEFT OUTER JOIN
	tblSMCurrency SMC
		ON ICISI.[intCurrencyId] = SMC.[intCurrencyID] 
WHERE ISNULL(ARID.[intRecipeItemId],0) = 0

UNION ALL 

SELECT [strTransactionType]				= 'Load Schedule'
	,[strTransactionNumber]				= L.[strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(L.intLoadId AS NVARCHAR(250))
	,[intEntityCustomerId]				= LD.intCustomerEntityId
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ARCC.[intCurrencyId], ARC.[intCurrencyId]), (
											SELECT TOP 1 intDefaultCurrencyId
											FROM tblSMCompanyPreference
											WHERE intDefaultCurrencyId IS NOT NULL
												AND intDefaultCurrencyId <> 0
											))
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= L.dtmScheduledDate
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= NULL
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intLoadId]						= L.intLoadId
	,[intLoadDetailId]					= LD.intLoadDetailId
	,[strLoadNumber]					= L.strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= ARCC.[intContractHeaderId]
	,[strContractNumber]				= ARCC.strContractNumber
	,[intContractDetailId]				= ISNULL(ARCC.[intContractDetailId], LD.[intPContractDetailId])
	,[intContractSeq]					= ARCC.[intContractSeq]
	,[intCompanyLocationId]				= LD.intSCompanyLocationId
	,[strLocationName]					= SMCL.[strLocationName]
	,[intShipToLocationId]				= 0--ICIS.[intShipToLocationId]
	,[intFreightTermId]					= ARCC.[intFreightTermId]
	,[intItemId]						= LD.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ICI.[strDescription]
	,[intItemUOMId]						= ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId])
	,[strUnitMeasure]					= ISNULL(ARCC.[strUnitMeasure],ICUM.[strUnitMeasure])
	,[intOrderUOMId]					= ARCC.[intOrderUOMId]
	,[strOrderUnitMeasure]				= ARCC.[strOrderUnitMeasure]
	,[intShipmentItemUOMId]				= ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId])
	,[strShipmentUnitMeasure]			= ISNULL(ARCC.[strUnitMeasure],ICUM.[strUnitMeasure])
	,[dblQtyShipped]					= ISNULL(ARCC.[dblShipQuantity],LD.[dblQuantity])
	,[dblQtyOrdered]					= ISNULL([dblOrderQuantity],0)
	,[dblShipmentQuantity]				= ISNULL(ARCC.[dblShipQuantity],LD.[dblQuantity]) --dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0))
	,[dblShipmentQtyShippedTotal]		= ISNULL(ARCC.[dblShipQuantity],LD.[dblQuantity])
	,[dblQtyRemaining]					= ISNULL(ARCC.[dblShipQuantity],LD.[dblQuantity])
	,[dblDiscount]						= 0
	,[dblPrice]							= ARCC.[dblCashPrice] 
	,[dblShipmentUnitPrice]				= ARCC.[dblCashPrice]
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), ISNULL(LD.[intWeightItemUOMId], ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId])), ISNULL(LD.[dblQuantity], 0)) * ARCC.[dblCashPrice]
	,[intStorageLocationId]				= SL.[intStorageLocationId]
	,[strStorageLocationName]			= SL.[strName]
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= ''
	,[intTicketId]						= NULL
	,[intTaxGroupId]					= NULL --SOD.[intTaxGroupId]
	,[strTaxGroup]						= NULL --TG.[strTaxGroup]
	,[dblWeight]						= [dbo].[fnCalculateQtyBetweenUOM](LD.[intWeightItemUOMId], ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), 1) --ICIU1.[dblWeight]
	,[intWeightUOMId]					= LD.intWeightItemUOMId --ICIU2.[intUnitMeasureId]
	,[strWeightUnitMeasure]				= ICIU2.[strUnitMeasure]
	,[dblGrossWt]						= LDL.dblGross
	,[dblTareWt]						= LDL.dblTare
	,[dblNetWt]							= LDL.dblNet
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= ''
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= ARCC.[intSubCurrencyId] 
	,[dblSubCurrencyRate]				= ARCC.[dblSubCurrencyRate] 
	,[strSubCurrency]					= SMC.[strCurrency]
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId  = LD.intLoadId
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
INNER JOIN tblARCustomer ARC ON LD.intCustomerEntityId = ARC.intEntityCustomerId
INNER JOIN tblICItem ICI ON LD.intItemId = ICI.intItemId
LEFT JOIN tblICLot LO ON LO.intLotId = LDL.intLotId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LO.intStorageLocationId
LEFT JOIN vyuARCustomerContract ARCC ON ARCC.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblICItemUOM ICIU ON LD.intItemUOMId = ICIU.intItemUOMId
LEFT JOIN tblICUnitMeasure ICUM ON ICIU.intUnitMeasureId = ICUM.intUnitMeasureId
LEFT JOIN tblICItemUOM ICIU1 ON LD.intItemUOMId = ICIU1.intItemUOMId
LEFT JOIN tblICUnitMeasure ICUM1 ON ICIU1.intUnitMeasureId = ICUM1.intUnitMeasureId
LEFT JOIN tblICItemUOM ICUM3 ON LD.intWeightItemUOMId = ICUM3.intItemUOMId
LEFT JOIN tblICUnitMeasure ICIU2 ON ICUM3.intUnitMeasureId = ICIU2.intUnitMeasureId
INNER JOIN tblEMEntity EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN tblARInvoiceDetail ARID ON LDL.intLoadDetailId = ARID.[intLoadDetailId]
LEFT OUTER JOIN [tblSMCompanyLocation] SMCL ON LD.intSCompanyLocationId = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN tblSMCurrency SMC ON ARCC.[intSubCurrencyId] = SMC.[intCurrencyID] 
WHERE
	L.[ysnPosted] = 1
	AND ISNULL(ARID.[intLoadDetailId], 0) = 0

UNION
		
SELECT  [strTransactionType]			= 'Load Schedule'
	,[strTransactionNumber]				= [strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(LWS.intLoadDetailId AS NVARCHAR(250))
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[strCustomerName]					= [strCustomerName]
	,[intCurrencyId]					= [intCurrencyId]
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= [dtmProcessDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= NULL
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intLoadId]						= intLoadId
	,[intLoadDetailId]					= LWS.intLoadDetailId
	,[strLoadNumber]					= strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= LWS.[intContractHeaderId]
	,[strContractNumber]				= [strContractNumber]
	,[intContractDetailId]				= LWS.[intContractDetailId]
	,[intContractSeq]					= [intContractSeq]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[strLocationName]					= [strLocationName]
	,[intShipToLocationId]				= 0 --ICIS.[intShipToLocationId]
	,[intFreightTermId]					= NULL
	,[intItemId]						= LWS.[intItemId]
	,[strItemNo]						= [strItemNo]
	,[strItemDescription]				= LWS.[strItemDescription]
	,[intItemUOMId]						= NULL
	,[strUnitMeasure]					= NULL
	,[intOrderUOMId]					= NULL
	,[strOrderUnitMeasure]				= NULL
	,[intShipmentItemUOMId]				= NULL
	,[strShipmentUnitMeasure]			= NULL
	,[dblQtyShipped]					= 1
	,[dblQtyOrdered]					= 1
	,[dblShipmentQuantity]				= 1 
	,[dblShipmentQtyShippedTotal]		= 1
	,[dblQtyRemaining]					= 1
	,[dblDiscount]						= 0
	,[dblPrice]							= LWS.[dblPrice]
	,[dblShipmentUnitPrice]				= [dblShipmentUnitPrice]
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= LWS.[dblTotal]
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
	,[dblWeight]						= NULL
	,[intWeightUOMId]					= NULL
	,[strWeightUnitMeasure]				= NULL
	,[dblGrossWt]						= 1
	,[dblTareWt]						= 1
	,[dblNetWt]							= 1
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= ''
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= LWS.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM vyuLGLoadWarehouseServicesForInvoice LWS
LEFT OUTER JOIN tblARInvoiceDetail ARID ON ARID.intLoadDetailId = LWS.[intLoadDetailId]
LEFT OUTER JOIN tblSMCurrency SMC ON LWS.[intCurrencyId] = SMC.[intCurrencyID] 
WHERE LWS.[ysnPosted] = 1 AND ISNULL(ARID.[intLoadDetailId], 0) = 0 AND ISNULL(LWS.intItemId,0) <> 0

UNION
		
SELECT  [strTransactionType]			= 'Load Schedule'
	,[strTransactionNumber]				= [strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(LC.intLoadDetailId AS NVARCHAR(250))
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[strCustomerName]					= [strCustomerName]
	,[intCurrencyId]					= [intCurrencyId]
	,[intSalesOrderId]					= NULL
	,[intSalesOrderDetailId]			= NULL
	,[strSalesOrderNumber]				= ''
	,[dtmProcessDate]					= [dtmProcessDate]
	,[intInventoryShipmentId]			= NULL
	,[intInventoryShipmentItemId]		= NULL
	,[intInventoryShipmentChargeId]		= NULL
	,[strInventoryShipmentNumber]		= NULL
	,[intShipmentId]					= NULL
	,[strShipmentNumber]				= NULL
	,[intLoadId]						= intLoadId
	,[intLoadDetailId]					= LC.intLoadDetailId
	,[strLoadNumber]					= strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= LC.[intContractHeaderId]
	,[strContractNumber]				= [strContractNumber]
	,[intContractDetailId]				= LC.[intContractDetailId]
	,[intContractSeq]					= [intContractSeq]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[strLocationName]					= [strLocationName]
	,[intShipToLocationId]				= 0 --ICIS.[intShipToLocationId]
	,[intFreightTermId]					= NULL
	,[intItemId]						= LC.[intItemId]
	,[strItemNo]						= [strItemNo]
	,[strItemDescription]				= LC.[strItemDescription]
	,[intItemUOMId]						= NULL
	,[strUnitMeasure]					= NULL
	,[intOrderUOMId]					= NULL
	,[strOrderUnitMeasure]				= NULL
	,[intShipmentItemUOMId]				= NULL
	,[strShipmentUnitMeasure]			= NULL
	,[dblQtyShipped]					= 1
	,[dblQtyOrdered]					= 1
	,[dblShipmentQuantity]				= 1 
	,[dblShipmentQtyShippedTotal]		= 1
	,[dblQtyRemaining]					= 1
	,[dblDiscount]						= 0
	,[dblPrice]							= LC.[dblPrice]
	,[dblShipmentUnitPrice]				= [dblShipmentUnitPrice]
	,[strPricing]						= ''
	,[dblTotalTax]						= 0
	,[dblTotal]							= LC.[dblTotal]
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
	,[dblWeight]						= 1
	,[intWeightUOMId]					= NULL
	,[strWeightUnitMeasure]				= NULL
	,[dblGrossWt]						= 1
	,[dblTareWt]						= 1
	,[dblNetWt]							= 1
	,[strPONumber]						= ''
	,[strBOLNumber]						= ''
	,[intSplitId]						= NULL
	,[intEntitySalespersonId]			= NULL
	,[strSalespersonName]				= ''
	,[ysnBlended]						= NULL
	,[intRecipeId]						= NULL
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intSubCurrencyId]					= LC.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM vyuLGLoadCostForCustomer LC
LEFT OUTER JOIN tblARInvoiceDetail ARID ON ARID.intLoadDetailId = LC.[intLoadDetailId]
LEFT OUTER JOIN tblSMCurrency SMC ON LC.[intCurrencyId] = SMC.[intCurrencyID] 
WHERE LC.[ysnPosted] = 1 AND ISNULL(ARID.[intLoadDetailId], 0) = 0

