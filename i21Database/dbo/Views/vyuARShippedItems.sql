CREATE VIEW [dbo].[vyuARShippedItems]
AS
SELECT NEWID() AS id, ShippedItems.* FROM 
(
SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
	,[intRecipeItemId]					= SOD.[intRecipeItemId]
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
	,[strVFDDocumentNumber]				= SOD.[strVFDDocumentNumber]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intStorageLocationId]				= SOD.[intStorageLocationId]
	,[strStorageLocationName]			= CAST(ISNULL(SL.[strName],'') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= NULL
	,[strDestinationGrade]				= ''
	,[intDestinationWeightId]			= NULL
	,[strDestinationWeight]				= ''
	,[intCurrencyExchangeRateTypeId]	= SOD.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= SOD.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= SOD.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	(SELECT [intSalesOrderId], 
			[strSalesOrderNumber],
			[intEntityCustomerId], 
			[intCurrencyId],
			[dtmDate],
			[strPONumber],
			[strBOLNumber],
			[intSplitId],
			[intEntitySalespersonId],
			[intCompanyLocationId],
			[intShipToLocationId],
			[intFreightTermId],
			[intTermId],
			[intShipViaId],
			[strTransactionType],
			[strOrderStatus]
	FROM tblSOSalesOrder  WITH (NOLOCK)) SO
INNER JOIN
	(SELECT [intSalesOrderId],
			[intItemId],
			[intContractHeaderId],
			[intContractDetailId],
			[intStorageLocationId],
			[intItemUOMId],
			[intTaxGroupId],
			[intSalesOrderDetailId],
			[intSubCurrencyId],
			[intRecipeItemId],
			[strItemDescription],
			[dblQtyShipped],
			[dblQtyOrdered],
			[dblDiscount],
			[dblPrice],
			[dblTotalTax],
			[dblTotal],
			[strPricing],
			[ysnBlended],
			[intRecipeId],
			[intSubLocationId],
			[intCostTypeId],
			[intMarginById],
			[intCommentTypeId],
			[dblMargin],
			[dblRecipeQuantity],
			[intStorageScheduleTypeId],
			[dblSubCurrencyRate],
			[intCurrencyExchangeRateTypeId],
			[intCurrencyExchangeRateId],
			[dblCurrencyExchangeRate],
			[strVFDDocumentNumber]
		FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOD ON SO.[intSalesOrderId] = SOD.[intSalesOrderId] 
INNER JOIN
	(SELECT [intItemId],
			[strLotTracking],
			[strItemNo]
	 FROM tblICItem WITH (NOLOCK)) I ON SOD.[intItemId] = I.[intItemId] AND (dbo.fnIsStockTrackingItem(I.[intItemId]) = 0 OR ISNULL(strLotTracking, 'No') = 'No')
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) C ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) E ON C.[intEntityCustomerId] = E.[intEntityId]
LEFT OUTER JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCR	 ON SOD.[intContractHeaderId] = ARCR.[intContractHeaderId] AND SOD.[intContractDetailId] = ARCR.[intContractDetailId]
LEFT JOIN
	(SELECT [intEntityId],
			[strName]
	 FROM tblEMEntity WITH (NOLOCK)) ESP ON SO.[intEntitySalespersonId] = ESP.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intTermID],
			[strTerm]
	 FROM tblSMTerm WITH (NOLOCK)) T ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	(SELECT [intEntityShipViaId],
			[strShipVia]
	 FROM tblSMShipVia WITH (NOLOCK)) S ON SO.[intShipViaId] = S.[intEntityShipViaId] 
LEFT OUTER JOIN
	(SELECT [intStorageLocationId],
		[strName]
	 FROM tblICStorageLocation WITH (NOLOCK)) SL ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId],
		[intWeightUOMId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U2 ON IU.[intWeightUOMId] = U2.[intUnitMeasureId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[intItemId],
		[intItemUOMId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU2 ON IU.[intWeightUOMId] = IU2.[intUnitMeasureId] AND  SOD.[intItemId] = IU2.[intItemId]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		[strLocationName]
	 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	(SELECT [intTaxGroupId],
		[strTaxGroup]
	 FROM tblSMTaxGroup WITH (NOLOCK)) TG ON SOD.[intTaxGroupId] = TG.intTaxGroupId
LEFT OUTER JOIN
	(SELECT D.intLineNo 
	 FROM (SELECT [intLineNo],
				[intInventoryShipmentId]
		   FROM tblICInventoryShipmentItem WITH (NOLOCK)) D 
	 INNER JOIN 
		(SELECT [intInventoryShipmentId], [intOrderType]
		 FROM tblICInventoryShipment WITH (NOLOCK)
		) H ON H.[intInventoryShipmentId] = D.[intInventoryShipmentId]
	  WHERE H.[intOrderType] = 2) ISD ON SOD.[intSalesOrderDetailId] = ISD.[intLineNo]
LEFT OUTER JOIN
	(SELECT intCurrencyID,
			[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON SOD.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE
      SO.[strTransactionType] = 'Order' AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
	  AND ((SOD.[dblQtyOrdered] - ISNULL(SOD.[dblQtyShipped], 0.000000) <> 0.000000) OR (ISNULL(ISD.[intLineNo],0) = 0))
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLotId]							= NULL
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
	,[strVFDDocumentNumber]				= SOD.[strVFDDocumentNumber]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intStorageLocationId]				= SOD.[intStorageLocationId]
	,[strStorageLocationName]			= CAST(ISNULL(SL.[strName],'') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId]
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= NULL
	,[strDestinationGrade]				= ''
	,[intDestinationWeightId]			= NULL
	,[strDestinationWeight]				= ''
	,[intCurrencyExchangeRateTypeId]	= SOD.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= SOD.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= SOD.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	(SELECT [intSalesOrderId], 
			[strSalesOrderNumber],
			[intEntityCustomerId], 
			[intCurrencyId],
			[dtmDate],
			[strPONumber],
			[strBOLNumber],
			[intSplitId],
			[intEntitySalespersonId],
			[intCompanyLocationId],
			[intShipToLocationId],
			[intFreightTermId],
			[intTermId],
			[intShipViaId],
			[strTransactionType],
			strOrderStatus
	FROM tblSOSalesOrder WITH (NOLOCK)) SO
INNER JOIN
	(SELECT [intSalesOrderId],
			[intItemId],
			[intContractHeaderId],
			[intContractDetailId],
			[intStorageLocationId],
			[intItemUOMId],
			[intTaxGroupId],
			[intSalesOrderDetailId],
			[intSubCurrencyId],
			[intRecipeItemId],
			[strItemDescription],
			[dblQtyShipped],
			[dblQtyOrdered],
			[dblDiscount],
			[dblPrice],
			[dblTotalTax],
			[dblTotal],
			[strPricing],
			[ysnBlended],
			[intRecipeId],
			[intSubLocationId],
			[intCostTypeId],
			[intMarginById],
			[intCommentTypeId],
			[dblMargin],
			[dblRecipeQuantity],
			[intStorageScheduleTypeId],
			[dblSubCurrencyRate],
			[intCurrencyExchangeRateTypeId],
			[strVFDDocumentNumber],
			[intCurrencyExchangeRateId],
			[dblCurrencyExchangeRate]
	 FROM tblSOSalesOrderDetail WITH (NOLOCK)
	 WHERE [intSalesOrderDetailId] NOT IN (SELECT ISNULL(ARID.[intSalesOrderDetailId],0) 
										FROM (SELECT intInvoiceId,
												intSalesOrderDetailId,
												dblQtyShipped 
											  FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
										INNER JOIN 
											(SELECT intInvoiceId
											FROM tblARInvoice WITH (NOLOCK)) ARI ON ARID.intInvoiceId = ARI.intInvoiceId)) SOD ON SO.[intSalesOrderId] = SOD.[intSalesOrderId] AND intItemId IS NULL AND strItemDescription <> ''
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) C ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) E ON C.[intEntityCustomerId] = E.[intEntityId] 
LEFT OUTER JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCC	 ON SOD.[intContractHeaderId] = ARCC.[intContractHeaderId] AND SOD.[intContractDetailId] = ARCC.[intContractDetailId]
LEFT JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) ESP ON SO.[intEntitySalespersonId] = ESP.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intTermID],
		[strTerm]
	 FROM tblSMTerm WITH (NOLOCK))  T ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	(SELECT [intEntityShipViaId],
		[strShipVia]
	 FROM tblSMShipVia WITH (NOLOCK)) S
		ON SO.[intShipViaId] = S.[intEntityShipViaId] 
LEFT OUTER JOIN
	(SELECT [intStorageLocationId],
		[strName]
	 FROM tblICStorageLocation WITH (NOLOCK)) SL
		ON SOD.[intStorageLocationId] = SL.[intStorageLocationId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId],
		[intWeightUOMId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U2 ON IU.[intWeightUOMId] = U2.[intUnitMeasureId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId],
		[intItemId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU2 ON IU.[intWeightUOMId] = IU2.[intUnitMeasureId] AND  SOD.[intItemId] = IU2.[intItemId]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	(SELECT [intTaxGroupId],
		[strTaxGroup]
	 FROM tblSMTaxGroup WITH (NOLOCK)) TG ON SOD.[intTaxGroupId] = TG.intTaxGroupId
LEFT OUTER JOIN
	(SELECT [intCurrencyID],
			[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON SOD.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE
    SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
         FROM 
			(SELECT intInvoiceId, [intSalesOrderDetailId], dblQtyShipped FROM tblARInvoiceDetail WITH (NOLOCK))  tblARInvoiceDetail
		 INNER JOIN 
			(SELECT intInvoiceId FROM tblARInvoice WITH (NOLOCK)) tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
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
	,[intCurrencyId]					= ISNULL(SHP.[intCurrencyId],ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0)))
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
	,[intLoadDetailId]					= NULL
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
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
	,[strVFDDocumentNumber]				= SOD.[strVFDDocumentNumber]
	,[dblTotalTax]						= SOD.[dblTotalTax]
	,[dblTotal]							= SOD.[dblTotal]
	,[intStorageLocationId]				= ISNULL(SHP.intStorageLocationId, SOD.[intStorageLocationId])
	,[strStorageLocationName]			= CAST(ISNULL(SL.[strName],'') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= SCT.[strTicketNumber]
	,[strCustomerReference]				= SCT.[strCustomerReference]
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
	,[intDestinationGradeId]			= ISNULL(SHP.[intDestinationGradeId], ARCC.[intDestinationGradeId])
	,[strDestinationGrade]				= ISNULL(SHP.[strDestinationGrade], ARCC.[strDestinationGrade])
	,[intDestinationWeightId]			= ISNULL(SHP.[intDestinationWeightId], ARCC.[intDestinationWeightId])
	,[strDestinationWeight]				= ISNULL(SHP.[strDestinationWeight], ARCC.[strDestinationWeight])
	,[intCurrencyExchangeRateTypeId]	= ISNULL(SHP.[intForexRateTypeId], SOD.[intCurrencyExchangeRateTypeId])
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= NULL
	,[dblCurrencyExchangeRate]			= SHP.[dblForexRate]
	,[intSubCurrencyId]					= SOD.[intSubCurrencyId]
	,[dblSubCurrencyRate]				= SOD.[dblSubCurrencyRate]
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	(SELECT [intSalesOrderId], 
			[strSalesOrderNumber],
			[intEntityCustomerId], 
			[intCurrencyId],
			[dtmDate],
			[strPONumber],
			[strBOLNumber],
			[intSplitId],
			[intEntitySalespersonId],
			[intCompanyLocationId],
			[intShipToLocationId],
			[intFreightTermId],
			[intTermId],
			[intShipViaId]
	FROM tblSOSalesOrder WITH (NOLOCK)
	WHERE [strTransactionType] = 'Order' AND strOrderStatus <> 'Cancelled') SO
INNER JOIN
	(SELECT [intSalesOrderId],
			[intItemId],
			[intContractHeaderId],
			[intContractDetailId],
			[intStorageLocationId],
			[intItemUOMId],
			[intTaxGroupId],
			[intSalesOrderDetailId],
			[intSubCurrencyId],
			[intRecipeItemId],
			[strItemDescription],
			[dblQtyShipped],
			[dblQtyOrdered],
			[dblDiscount],
			[dblPrice],
			[dblTotalTax],
			[dblTotal],
			[strPricing],
			[ysnBlended],
			[intRecipeId],
			[intSubLocationId],
			[intCostTypeId],
			[intMarginById],
			[intCommentTypeId],
			[dblMargin],
			[dblRecipeQuantity],
			[intStorageScheduleTypeId],
			[dblSubCurrencyRate],
			[intCurrencyExchangeRateTypeId],
			[strVFDDocumentNumber]
	 FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) C ON SO.intEntityCustomerId = C.intEntityCustomerId
LEFT OUTER JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq], 
			[intDestinationGradeId],
			[strDestinationGrade],
			[intDestinationWeightId],
			[strDestinationWeight]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCC	 ON SOD.[intContractHeaderId] = ARCC.[intContractHeaderId] AND SOD.[intContractDetailId] = ARCC.[intContractDetailId]
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) E ON C.[intEntityCustomerId] = E.[intEntityId]
LEFT JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) ESP ON SO.[intEntitySalespersonId] = ESP.[intEntityId] 
LEFT OUTER JOIN
	(SELECT [intTermID],
		[strTerm]
	 FROM tblSMTerm WITH (NOLOCK)) T ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	(SELECT [intEntityShipViaId],
		[strShipVia]
	 FROM tblSMShipVia WITH (NOLOCK)) S
		ON SO.[intShipViaId] = S.[intEntityShipViaId]
INNER JOIN
	(SELECT [intItemId],
		[strItemNo]
	 FROM tblICItem WITH (NOLOCK)) I ON SOD.[intItemId] = I.[intItemId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU ON SOD.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]		
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId] 
LEFT OUTER JOIN
	(SELECT [intTaxGroupId],
		[strTaxGroup]
	 FROM tblSMTaxGroup WITH (NOLOCK)) TG ON SOD.[intTaxGroupId] = TG.intTaxGroupId 
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
		,ISI.[intDestinationGradeId]
		,CTDG.[strDestinationGrade]
		,ISI.[intDestinationWeightId]
		,CTDW.[strDestinationWeight]
		,ISH.[intCurrencyId]
		,ISI.[intForexRateTypeId]
		,ISI.[dblForexRate] 
	FROM
		(SELECT [intInventoryShipmentItemId],
			[intLineNo],
			[intItemId],
			[dblQuantity],
			[intItemUOMId],
			[dblUnitPrice],
			[intSourceId],
			[intWeightUOMId],
			[intSubLocationId],
			[intStorageLocationId],
			[intDestinationGradeId],
			[intDestinationWeightId],
			[intInventoryShipmentId],
			[intForexRateTypeId],
			[dblForexRate]
		 FROM tblICInventoryShipmentItem WITH (NOLOCK)) ISI
	INNER JOIN
		(SELECT [intInventoryShipmentId],
			[intShipFromLocationId],
			[strShipmentNumber],
			[dtmShipDate],
			[intFreightTermId],
			[intCurrencyId]			
		 FROM tblICInventoryShipment WITH (NOLOCK)
		 WHERE [ysnPosted] = 1) ISH
			ON ISI.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	LEFT JOIN
		(SELECT [intItemUOMId],
			[intUnitMeasureId]
		FROM tblICItemUOM WITH (NOLOCK)) IU ON ISI.[intItemUOMId] = IU.[intItemUOMId]
	LEFT JOIN
		(SELECT [intUnitMeasureId],
			[strUnitMeasure]
		 FROM tblICUnitMeasure WITH (NOLOCK)) U ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
	LEFT OUTER JOIN
		(SELECT [intCompanyLocationId],
			strLocationName
		 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON ISH.[intShipFromLocationId] = CL.[intCompanyLocationId]
	LEFT OUTER JOIN
		(SELECT [intInventoryShipmentItemId]
		 FROM tblARInvoiceDetail WITH (NOLOCK)
		 WHERE [intInventoryShipmentItemId] IS NULL	) IND
			ON ISI.[intInventoryShipmentItemId] = IND.[intInventoryShipmentItemId]
	LEFT OUTER JOIN
			(
				SELECT
					[intWeightGradeId]		= [intWeightGradeId]
					,[strDestinationGrade]	= [strWeightGradeDesc]
				FROM
					tblCTWeightGrade WITH (NOLOCK)
			) CTDG
				ON ISI.[intDestinationGradeId] = CTDG.[intWeightGradeId]
	LEFT OUTER JOIN
		(
			SELECT
				[intWeightGradeId]		= [intWeightGradeId]
				,[strDestinationWeight]	= [strWeightGradeDesc]
			FROM
				tblCTWeightGrade WITH (NOLOCK)
		) CTDW
			ON ISI.[intDestinationWeightId] = CTDW.[intWeightGradeId]
	WHERE		
		ISI.[intLineNo] = SOD.[intSalesOrderDetailId]		 
		 
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
		,ISI.[intDestinationGradeId]
		,CTDG.[strDestinationGrade]
		,ISI.[intDestinationWeightId]
		,CTDW.[strDestinationWeight]
		,ISH.[intCurrencyId]
		,ISI.[intForexRateTypeId]
		,ISI.[dblForexRate] 
	) SHP
LEFT OUTER JOIN
	(SELECT [intTicketId],
		[strTicketNumber],
		[strCustomerReference]
	 FROM tblSCTicket WITH (NOLOCK)) SCT ON SHP.[intSourceId] = SCT.[intTicketId]
LEFT OUTER JOIN
	(
		SELECT
			intInventoryShipmentItemId
			,SUM([dblGrossWeight]) dblGrossWeight
			,SUM([dblTareWeight]) dblTareWeight
			,SUM([dblGrossWeight] - [dblTareWeight]) dblNetWeight
		FROM
			tblICInventoryShipmentItemLot WITH (NOLOCK)
		GROUP BY
			intInventoryShipmentItemId
	) ISISIL
		ON SHP.[intInventoryShipmentItemId] = ISISIL.[intInventoryShipmentItemId]
LEFT JOIN
	(SELECT [intItemUOMId],
			[intUnitMeasureId]
		FROM tblICItemUOM WITH (NOLOCK)) IU1
		ON SHP.[intItemUOMId] = IU1.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U1
		ON IU1.[intUnitMeasureId] = U1.[intUnitMeasureId]	
LEFT JOIN
	(SELECT [intItemUOMId],
			[intUnitMeasureId]
		FROM tblICItemUOM WITH (NOLOCK)) IU2 ON SHP.[intWeightUOMId] = IU2.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U2 ON IU2.[intUnitMeasureId] = U2.[intUnitMeasureId]
LEFT OUTER JOIN
	(SELECT [intInventoryShipmentItemId]		
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		ON SHP.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
LEFT OUTER JOIN
	(SELECT [intCurrencyID],
		[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON SOD.[intSubCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
	(SELECT [intStorageLocationId],
			[strName]
	 FROM tblICStorageLocation WITH (NOLOCK)) SL ON ISNULL(SHP.[intStorageLocationId], SOD.[intStorageLocationId]) = SL.[intStorageLocationId] 	
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ISNULL(SHP.[intForexRateTypeId], SOD.[intCurrencyExchangeRateTypeId]) = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0			
	
UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ICIS.[intCurrencyId], ISNULL((SELECT TOP 1 intCurrencyId FROM tblICInventoryShipmentCharge WITH (NOLOCK) WHERE intInventoryShipmentId = ICIS.[intInventoryShipmentId] AND intCurrencyId IS nOT NULL),ISNULL(ISNULL(ARCC.[intCurrencyId], ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))))
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
	,[intLoadDetailId]					= NULL
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
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
	,[dblQtyShipped]					= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) --ISNULL(ARCC.[dblShipQuantity], ICISI.[dblQuantity]) 	
	,[dblQtyOrdered]					= CASE WHEN ARCC.[intContractDetailId] IS NOT NULL THEN ARCC.dblDetailQuantity ELSE 0 END 
	,[dblShipmentQuantity]				= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) --ISNULL(ICISI.[dblQuantity], ARCC.[dblShipQuantity])
	,[dblShipmentQtyShippedTotal]		= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) --ISNULL(ICISI.[dblQuantity], ARCC.[dblShipQuantity]) 
	,[dblQtyRemaining]					= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) --ISNULL(ICISI.[dblQuantity], ARCC.[dblShipQuantity]) 
	,[dblDiscount]						= 0 
	,[dblPrice]							= ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[dblShipmentUnitPrice]				= ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[strPricing]						= ''
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ARCC.[intItemUOMId], ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0)) * ISNULL(ARCC.[dblCashPrice], ICISI.[dblUnitPrice])
	,[intStorageLocationId]				= ICISI.[intStorageLocationId]
	,[strStorageLocationName]			= CAST(ISNULL(ICSL.[strName],'') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= SCT.strTicketNumber
	,[strCustomerReference]				= SCT.strCustomerReference
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
	,[intSubLocationId]					= ICISI.[intSubLocationId]
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intDestinationGradeId]			= ISNULL(ICISI.[intDestinationGradeId], ARCC.[intDestinationGradeId])
	,[strDestinationGrade]				= ISNULL(CTDG.[strDestinationGrade], ARCC.[strDestinationGrade])
	,[intDestinationWeightId]			= ISNULL(ICISI.[intDestinationWeightId], ARCC.[intDestinationWeightId])
	,[strDestinationWeight]				= ISNULL(CTDW.[strDestinationWeight], ARCC.[strDestinationWeight])
	,[intCurrencyExchangeRateTypeId]	= ICISI.[intForexRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= NULL
	,[dblCurrencyExchangeRate]			= ICISI.[dblForexRate]
	,[intSubCurrencyId]					= NULL
	,[dblSubCurrencyRate]				= 1
	,[strSubCurrency]					= ''
FROM
	(SELECT [intInventoryShipmentId],
		[intDestinationGradeId],
		[intDestinationWeightId],
		[intSubLocationId],
		[intWeightUOMId],
		[intItemUOMId],
		[intStorageLocationId],
		[dblUnitPrice],
		[intInventoryShipmentItemId],
		[intLineNo],
		[intItemId],
		[intSourceId],
		[dblQuantity],
		[intForexRateTypeId],
		[dblForexRate]
	 FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
INNER JOIN
	(SELECT [intInventoryShipmentId],
			[intShipFromLocationId],
			[strShipmentNumber],
			[dtmShipDate],
			[intFreightTermId],
			[intOrderType],
			[intEntityCustomerId],
			[intShipToLocationId],
			[intCurrencyId]
	FROM tblICInventoryShipment WITH (NOLOCK)
	WHERE [intOrderType] <> 2 AND [ysnPosted] = 1 ) ICIS ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]		  
LEFT OUTER JOIN
	(
		SELECT
			intInventoryShipmentItemId
			,SUM([dblGrossWeight]) dblGrossWeight
			,SUM([dblTareWeight]) dblTareWeight
			,SUM([dblGrossWeight] - [dblTareWeight]) dblNetWeight
		FROM
			tblICInventoryShipmentItemLot WITH (NOLOCK)
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
			(SELECT intInventoryShipmentItemId 
			 FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI1
		INNER JOIN
			(SELECT [intInventoryShipmentItemId],
				[intLotId]
			 FROM tblICInventoryShipmentItemLot WITH (NOLOCK)) ICISIL1
				ON ICISI1.[intInventoryShipmentItemId] = ICISIL1.[intInventoryShipmentItemId]
		INNER JOIN
			(SELECT [intLotId],
				[intTransactionDetailId]
			 FROM tblICInventoryLot  WITH (NOLOCK)
			 WHERE [ysnIsUnposted] = 0) ICIL1
				ON ICISIL1.[intLotId] = ICIL1.[intLotId] 				 
		INNER JOIN 
			(SELECT [intInventoryReceiptItemId],
				[intLineNo]
			 FROM tblICInventoryReceiptItem WITH (NOLOCK)) ICIRI1
				ON ICIL1.[intTransactionDetailId] = ICIRI1.[intInventoryReceiptItemId]
		INNER JOIN 
			(SELECT [intContractDetailId],
				intShipmentId,
				intTrackingNumber,
				strContractNumber,
				intContractHeaderId,
				intContractSeq
			FROM vyuLGShipmentContainerPurchaseContracts WITH (NOLOCK)) LGSD
				ON ICIRI1.[intLineNo] = LGSD.[intContractDetailId]
	) LGICShipment
		ON ICISI.[intInventoryShipmentItemId] = LGICShipment.[intInventoryShipmentItemId]
LEFT OUTER JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq], 
			[intDestinationGradeId],
			[strDestinationGrade],
			[intDestinationWeightId],
			[strDestinationWeight],
			[intSubCurrencyId],
			[intCurrencyId],
			[strUnitMeasure],
			[intOrderUOMId],
			[intItemUOMId],
			[strOrderUnitMeasure],
			[dblCashPrice],
			[dblDetailQuantity]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCC	 ON ICISI.[intLineNo] = ARCC.[intContractDetailId] AND ICIS.[intOrderType] = 1
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationGrade]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDG
		ON ICISI.[intDestinationGradeId] = CTDG.[intWeightGradeId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationWeight]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDW
		ON ICISI.[intDestinationWeightId] = CTDW.[intWeightGradeId]
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) ARC ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	(SELECT [intItemId],
		[strItemNo],
		[strDescription]
	 FROM tblICItem WITH (NOLOCK)) ICI ON ICISI.[intItemId] = ICI.[intItemId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU ON ICISI.[intItemUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]	
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU1 ON ICISI.[intItemUOMId] = ICIU1.[intItemUOMId] 
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM1 ON ICIU1.[intUnitMeasureId] = ICUM1.[intUnitMeasureId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICUM3 ON ICISI.[intWeightUOMId] = ICUM3.[intItemUOMId]				
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICIU2 ON ICUM3.[intUnitMeasureId] = ICIU2.[intUnitMeasureId]					
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intStorageLocationId],
		[strName]
	 FROM tblICStorageLocation WITH (NOLOCK)) ICSL ON ICISI.[intStorageLocationId] = ICSL.[intStorageLocationId]				
LEFT OUTER JOIN
	(SELECT [intInventoryShipmentItemId]		
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ICISI.[intInventoryShipmentItemId] = ARID.[intInventoryShipmentItemId]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	(SELECT [intCurrencyID],
		[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON ARCC.[intSubCurrencyId] = SMC.[intCurrencyID]	
LEFT OUTER JOIN
	(SELECT [intTicketId],
			[strTicketNumber],
			[strCustomerReference]
	 FROM tblSCTicket WITH (NOLOCK)) SCT ON ICISI.[intSourceId] = SCT.[intTicketId]		
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ICISI.[intForexRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE ISNULL(ARID.[intInventoryShipmentItemId],0) = 0

UNION ALL

SELECT
	 [strTransactionType]				= 'Inventory Shipment'
	,[strTransactionNumber]				= ICIS.[strShipmentNumber] 
	,[strShippedItemId]					= 'icis:' + CAST(ICIS.[intInventoryShipmentId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= ICIS.[intEntityCustomerId]
	,[strCustomerName]					= EME.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(ISNULL(ICISC.[intCurrencyId], ARCC.[intCurrencyId]),ARC.[intCurrencyId]), 
										(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLoadDetailId]					= NULL
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= 1 * ICISC.[dblAmount]
	,[intStorageLocationId]				= ICISI.[intStorageLocationId]
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= SCT.strTicketNumber
	,[strCustomerReference]				= SCT.strCustomerReference
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
	,[intSubLocationId]					= ICISI.[intSubLocationId]
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intDestinationGradeId]			= NULL
	,[strDestinationGrade]				= ''
	,[intDestinationWeightId]			= NULL
	,[strDestinationWeight]				= ''
	,[intCurrencyExchangeRateTypeId]	= ICISC.[intForexRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= NULL
	,[dblCurrencyExchangeRate]			= ICISC.[dblForexRate]
	,[intSubCurrencyId]					= NULL
	,[dblSubCurrencyRate]				= 1
	,[strSubCurrency]					= ''
FROM
	(SELECT [intChargeId],
			intInventoryShipmentId,
			intContractId,
			intCostUOMId,
			intInventoryShipmentChargeId,
			intCurrencyId,
			dblAmount,
			[intForexRateTypeId],
			[dblForexRate]
	FROM tblICInventoryShipmentCharge WITH (NOLOCK)
	WHERE  ISNULL([ysnPrice],0) = 1) ICISC
INNER JOIN
	(SELECT [intInventoryShipmentId],
			[intShipFromLocationId],
			[strShipmentNumber],
			[dtmShipDate],
			[intFreightTermId],
			[intOrderType],
			[intEntityCustomerId],
			[intShipToLocationId]			
	FROM tblICInventoryShipment WITH (NOLOCK)
	WHERE [ysnPosted] = 1 ) ICIS
		ON ICISC.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]			 
LEFT OUTER JOIN	
		(SELECT [intInventoryShipmentId],
			intSourceId,
			intSubLocationId,
			intStorageLocationId
		 FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI 
			ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
LEFT OUTER JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq], 
			[intDestinationGradeId],
			[strDestinationGrade],
			[intDestinationWeightId],
			[strDestinationWeight],
			[intSubCurrencyId],
			[intCurrencyId],
			[strUnitMeasure],
			[intOrderUOMId],
			[intItemUOMId],
			[strOrderUnitMeasure],
			[dblCashPrice],
			[dblDetailQuantity]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCC	ON ICISC.[intContractId] = ARCC.[intContractHeaderId]
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	(SELECT [intItemId],
		[strItemNo],
		[strDescription]
	 FROM tblICItem WITH (NOLOCK)) ICI ON ICISC.[intChargeId] = ICI.[intItemId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU ON ICISC.[intCostUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]		
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intInventoryShipmentItemId],
		[intInventoryShipmentChargeId]	
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ICISC.intInventoryShipmentChargeId = ARID.[intInventoryShipmentChargeId]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
	(SELECT [intCurrencyID],
		[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON ICISC.[intCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
	(SELECT [intTicketId],
			[strTicketNumber],
			[strCustomerReference]
	 FROM tblSCTicket WITH (NOLOCK)) SCT ON ICISI.[intSourceId] = SCT.[intTicketId]
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ICISC.[intForexRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE ISNULL(ARID.[intInventoryShipmentChargeId],0) = 0

--UNION ALL

--SELECT
--	 [strTransactionType]				= 'Inbound Shipment'
--	,[strTransactionNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
--	,[strShippedItemId]					= 'lgis:' + CAST(LGS.intShipmentId AS NVARCHAR(250))
--	,[intEntityCustomerId]				= LGS.[intCustomerEntityId] 
--	,[strCustomerName]					= E.[strName]
--	,[intCurrencyId]					= ISNULL(ISNULL(ARSID.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
--	,[intSalesOrderId]					= NULL
--	,[intSalesOrderDetailId]			= NULL
--	,[strSalesOrderNumber]				= ''
--	,[dtmProcessDate]					= ISNULL(LGS.dtmShipmentDate, ISNULL(LGS.[dtmInventorizedDate], GETDATE()))
--	,[intInventoryShipmentId]			= NULL
--	,[intInventoryShipmentItemId]		= NULL	
--	,[intInventoryShipmentChargeId]		= NULL
--	,[strInventoryShipmentNumber]		= ''	
--	,[intShipmentId]					= LGS.[intShipmentId]
--	,[strShipmentNumber]				= CAST(LGS.intShipmentId AS NVARCHAR(250))
--	,[intLoadId]						= NULL	
--	,[intLoadDetailId]					= NULL
--	,[intLotId]							= ARSID.[intLotId]
--	,[strLoadNumber]					= NULL
--	,[intRecipeItemId]					= NULL
--	,[intContractHeaderId]				= NULL
--	,[strContractNumber]				= ''
--	,[intContractDetailId]				= NULL
--	,[intContractSeq]					= NULL
--	,[intCompanyLocationId]				= LGS.[intCompanyLocationId]
--	,[strLocationName]					= CL.[strLocationName]
--	,[intShipToLocationId]				= ISNULL(SL.[intEntityLocationId], EL.[intEntityLocationId])
--	,[intFreightTermId]					= NULL
--	,[intItemId]						= NULL
--	,[strItemNo]						= ''
--	,[strItemDescription]				= ''
--	,[intItemUOMId]						= NULL
--	,[strUnitMeasure]					= ''
--	,[intOrderUOMId]					= NULL
--	,[strOrderUnitMeasure]				= ''
--	,[intShipmentItemUOMId]				= NULL
--	,[strShipmentUnitMeasure]			= ''
--	,[dblQtyShipped]					= 0.00
--	,[dblQtyOrdered]					= 0.00
--	,[dblShipmentQuantity]				= 0.00
--	,[dblShipmentQtyShippedTotal]		= 0.00
--	,[dblQtyRemaining]					= 0.00
--	,[dblDiscount]						= 0.00
--	,[dblPrice]							= 0.00
--	,[dblShipmentUnitPrice]				= 0.00
--	,[strPricing]						= ''
--	,[strVFDDocumentNumber]				= NULL
--	,[dblTotalTax]						= 0.00
--	,[dblTotal]							= 0.00
--	,[intStorageLocationId]				= NULL
--	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
--	,[intTermID]						= NULL
--	,[strTerm]							= ''
--	,[intEntityShipViaId]				= NULL
--	,[strShipVia]						= ''
--	,[strTicketNumber]					= NULL
--	,[strCustomerReference]				= NULL
--	,[intTicketId]						= NULL
--	,[intTaxGroupId]					= NULL
--	,[strTaxGroup]						= NULL
--	,[dblWeight]						= 0.00
--	,[intWeightUOMId]					= NULL
--	,[strWeightUnitMeasure]				= ''
--	,[dblGrossWt]						= 0.00
--	,[dblTareWt]						= 0.00
--	,[dblNetWt]							= 0.00
--	,[strPONumber]						= ''
--	,[strBOLNumber]						= ''
--	,[intSplitId]						= NULL
--	,[intEntitySalespersonId]			= NULL
--	,[strSalespersonName]				= NULL
--	,[ysnBlended]						= NULL
--	,[intRecipeId]						= NULL
--	,[intSubLocationId]					= NULL
--	,[intCostTypeId]					= NULL
--	,[intMarginById]					= NULL
--	,[intCommentTypeId]					= NULL
--	,[dblMargin]						= NULL
--	,[dblRecipeQuantity]				= NULL
--	,[intStorageScheduleTypeId]			= NULL
--	,[intDestinationGradeId]			= NULL
--	,[strDestinationGrade]				= ''
--	,[intDestinationWeightId]			= NULL
--	,[strDestinationWeight]				= ''
--	,[intCurrencyExchangeRateTypeId]	= ARSID.[intCurrencyExchangeRateTypeId]
--	,[strCurrencyExchangeRateType]		= ARSID.[strCurrencyExchangeRateType]
--	,[intCurrencyExchangeRateId]		= ARSID.[intCurrencyExchangeRateId]
--	,[dblCurrencyExchangeRate]			= ARSID.[dblCurrencyExchangeRate]
--	,[intSubCurrencyId]					= ARSID.[intSubCurrencyId]
--	,[dblSubCurrencyRate]				= ARSID.[dblSubCurrencyRate]
--	,[strSubCurrency]					= ARSID.[strSubCurrency]
--FROM
--	(SELECT [intSubCurrencyId],
--			[dblSubCurrencyRate],
--			[strSubCurrency],
--			[intShipmentId],
--			[intCurrencyId],
--			[intCurrencyExchangeRateTypeId],
--			[strCurrencyExchangeRateType],
--			[intCurrencyExchangeRateId],
--			[dblCurrencyExchangeRate],
--			[intLotId]
--	 FROM vyuARShippedItemDetail WITH (NOLOCK))ARSID
--INNER JOIN
--	(SELECT [intShipmentId],
--		intCustomerEntityId,
--		intCompanyLocationId,
--		dtmShipmentDate,
--		dtmInventorizedDate
--	 FROM vyuLGShipmentHeader WITH (NOLOCK)
--	 WHERE [ysnInventorized] = 1
--		AND [intShipmentId] IN (SELECT [intShipmentId] FROM vyuLGDropShipmentDetails WITH (NOLOCK))) LGS		
--		ON ARSID.[intShipmentId] = LGS.[intShipmentId]
--INNER JOIN
--	(SELECT [intEntityCustomerId],
--			[intCurrencyId],
--			[intShipToId]
--	 FROM tblARCustomer WITH (NOLOCK)) C
--		ON LGS.[intCustomerEntityId] = C.[intEntityCustomerId] 
--INNER JOIN
--	(SELECT [intEntityId],
--			strName
--	 FROM tblEMEntity WITH (NOLOCK)) E ON C.[intEntityCustomerId]  = E.[intEntityId]
--LEFT OUTER JOIN
--	(SELECT [intCompanyLocationId],
--		strLocationName
--	 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON LGS.[intCompanyLocationId] = CL.[intCompanyLocationId]
--LEFT OUTER JOIN
--		(	SELECT 
--				 [intEntityLocationId]
--				,[strLocationName]
--				,[strAddress]
--				,[intEntityId] 
--				,[strCountry]
--				,[strState]
--				,[strCity]
--				,[strZipCode]
--				,[intTermsId]
--				,[intShipViaId]
--			FROM 
--				[tblEMEntityLocation] WITH (NOLOCK)
--			WHERE
--				ysnDefaultLocation = 1
--		) EL
--			ON LGS.[intCustomerEntityId] = EL.[intEntityId]
--LEFT OUTER JOIN
--	(SELECT intEntityLocationId 
--	 FROM [tblEMEntityLocation] WITH (NOLOCK)) SL
--		ON C.intShipToId = SL.intEntityLocationId
--LEFT OUTER JOIN
--	(SELECT [intInventoryShipmentItemId],
--		[intShipmentId]	
--	 FROM tblARInvoiceDetail WITH (NOLOCK)
--	 WHERE intInvoiceId IS NULL) ARID ON LGS.[intShipmentId] = ARID.[intShipmentId]
		 

UNION ALL

SELECT
	 [strTransactionType]				= 'Sales Order'
	,[strTransactionNumber]				= SO.[strSalesOrderNumber]
	,[strShippedItemId]					= 'arso:' + CAST(SO.[intSalesOrderId] AS NVARCHAR(250))
	,[intEntityCustomerId]				= SO.[intEntityCustomerId]
	,[strCustomerName]					= E.[strName]
	,[intCurrencyId]					= ISNULL(ISNULL(SO.[intCurrencyId], C.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLoadDetailId]					= NULL
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0.00
	,[dblTotal]							= MFG.[dblLineTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= T.[intTermID]
	,[strTerm]							= T.[strTerm]
	,[intEntityShipViaId]				= S.[intEntityShipViaId] 
	,[strShipVia]						= S.[strShipVia]
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intRecipeId]						= MFR.intRecipeId
	,[intSubLocationId]					= NULL
	,[intCostTypeId]					= NULL
	,[intMarginById]					= NULL
	,[intCommentTypeId]					= NULL
	,[dblMargin]						= NULL
	,[dblRecipeQuantity]				= NULL
	,[intStorageScheduleTypeId]			= NULL
	,[intDestinationGradeId]			= NULL
	,[strDestinationGrade]				= ''
	,[intDestinationWeightId]			= NULL
	,[strDestinationWeight]				= ''
	,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARID.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= NULL
	,[dblSubCurrencyRate]				= 1
	,[strSubCurrency]					= ''
FROM
	(SELECT [intSalesOrderId], 
			[strSalesOrderNumber],
			[intEntityCustomerId], 
			[intCurrencyId],
			[dtmDate],
			[strPONumber],
			[strBOLNumber],
			[intSplitId],
			[intEntitySalespersonId],
			[intCompanyLocationId],
			[intShipToLocationId],
			[intFreightTermId],
			[intTermId],
			[intShipViaId],
			[strTransactionType],
			[strOrderStatus]
	FROM tblSOSalesOrder  WITH (NOLOCK)
	WHERE [strTransactionType] = 'Order' AND strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')) SO
CROSS APPLY
	[dbo].[fnMFGetInvoiceChargesByShipment](0,SO.[intSalesOrderId]) MFG
INNER JOIN
	(SELECT [intItemId],
		[strItemNo],
		[strDescription]
	 FROM tblICItem WITH (NOLOCK)) I
		ON MFG.[intItemId] = I.[intItemId]
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) C
		ON SO.[intEntityCustomerId] = C.[intEntityCustomerId] 
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) E ON C.[intEntityCustomerId] = E.[intEntityId]
LEFT JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) ESP ON SO.[intEntitySalespersonId] = ESP.[intEntityId]
LEFT OUTER JOIN
	(SELECT [intTermID],
		[strTerm]
	 FROM tblSMTerm WITH (NOLOCK)) T ON SO.[intTermId] = T.[intTermID] 
LEFT OUTER JOIN
	(SELECT [intEntityShipViaId],
		[strShipVia]
	 FROM tblSMShipVia WITH (NOLOCK)) S
		ON SO.[intShipViaId] = S.[intEntityShipViaId] 
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) IU ON MFG.[intItemUOMId] = IU.[intItemUOMId]
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) U ON IU.[intUnitMeasureId] = U.[intUnitMeasureId]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) CL ON SO.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	(SELECT [intInventoryShipmentItemId],
			[intRecipeItemId],
			[intCurrencyExchangeRateTypeId],
			[intCurrencyExchangeRateId],
			[dblCurrencyExchangeRate]
	 FROM tblARInvoiceDetail WITH (NOLOCK))ARID ON MFG.[intRecipeItemId] = ARID.[intRecipeItemId]
LEFT OUTER JOIN
	(SELECT intRecipeItemId,
		intRecipeId
	 FROM tblMFRecipeItem WITH (NOLOCK)) MFR
		ON MFG.intRecipeItemId = MFR.intRecipeItemId
LEFT OUTER JOIN
	(SELECT D.[intOrderId] FROM (SELECT [intOrderId],
									[intInventoryShipmentId]
								 FROM tblICInventoryShipmentItem WITH (NOLOCK)
								WHERE ISNULL([intOrderId],0) = 0) D 
	 INNER JOIN (SELECT [intInventoryShipmentId]
				 FROM tblICInventoryShipment WITH (NOLOCK)
				 WHERE [intOrderType] = 2) H ON H.[intInventoryShipmentId] = D.[intInventoryShipmentId]) ISD
		ON SO.[intSalesOrderId] = ISD.[intOrderId] 
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ARID.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
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
	,[intCurrencyId]					= ISNULL(ISNULL(ICISI.[intCurrencyId],ARC.[intCurrencyId]), (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WITH (NOLOCK) WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
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
	,[intLoadDetailId]					= NULL
	,[intLotId]							= NULL
	,[strLoadNumber]					= NULL
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= MFG.[dblLineTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= ICISI.[intDestinationGradeId]
	,[strDestinationGrade]				= CTDG.[strDestinationGrade]
	,[intDestinationWeightId]			= ICISI.[intDestinationWeightId]
	,[strDestinationWeight]				= CTDW.[strDestinationWeight]
	,[intCurrencyExchangeRateTypeId]	= ICISI.[intForexRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= NULL
	,[dblCurrencyExchangeRate]			= ICISI.[dblForexRate]
	,[intSubCurrencyId]					= ICISI.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM
	(SELECT [intDestinationGradeId],
		[intInventoryShipmentId],
		[intDestinationWeightId],
		[intCurrencyId],
		[intInventoryShipmentItemId],
		[intForexRateTypeId],
		[dblForexRate]
	FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
CROSS APPLY
	[dbo].[fnMFGetInvoiceChargesByShipment](ICISI.[intInventoryShipmentItemId],0) MFG	
INNER JOIN
	(SELECT [intInventoryShipmentId],
		intEntityCustomerId,
		strShipmentNumber,
		intShipFromLocationId,
		dtmShipDate,
		intShipToLocationId,
		intFreightTermId
	FROM tblICInventoryShipment WITH (NOLOCK)
	WHERE [ysnPosted] = 1) ICIS
		ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]		 
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationGrade]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDG
		ON ICISI.[intDestinationGradeId] = CTDG.[intWeightGradeId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationWeight]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDW
		ON ICISI.[intDestinationWeightId] = CTDW.[intWeightGradeId]
INNER JOIN
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) ARC
		ON ICIS.[intEntityCustomerId] = ARC.[intEntityCustomerId]
INNER JOIN
	(SELECT [intItemId],
		[strItemNo],
		[strDescription]
	 FROM tblICItem WITH (NOLOCK)) ICI
		ON MFG.[intItemId] = ICI.[intItemId]
LEFT JOIN
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU ON MFG.[intItemUOMId] = ICIU.[intItemUOMId] 
LEFT JOIN
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]		
INNER JOIN
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]			
LEFT OUTER JOIN
	(SELECT [intInventoryShipmentItemId],
		[intRecipeItemId],
		[strShipmentNumber]	
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON MFG.[intRecipeItemId] = ARID.[intRecipeItemId]
		AND ICIS.[strShipmentNumber] = ARID.[strShipmentNumber]
LEFT OUTER JOIN
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON ICIS.[intShipFromLocationId] = SMCL.[intCompanyLocationId]	
LEFT OUTER JOIN
	(SELECT [intCurrencyID],
		[strCurrency],
		[intCent]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON ICISI.[intCurrencyId] = SMC.[intCurrencyID]
LEFT OUTER JOIN
(SELECT intRecipeItemId,
		intRecipeId
	 FROM tblMFRecipeItem WITH(NOLOCK)) MFI
		ON MFG.intRecipeItemId = MFI.intRecipeItemId
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ICISI.[intForexRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
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
	,[intLotId]							= LDL.[intLotId] 
	,[strLoadNumber]					= L.strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= ARCC.[intContractHeaderId]
	,[strContractNumber]				= ARCC.strContractNumber
	,[intContractDetailId]				= ISNULL(ARCC.[intContractDetailId], LD.[intPContractDetailId])
	,[intContractSeq]					= ARCC.[intContractSeq]
	,[intCompanyLocationId]				= LD.intSCompanyLocationId
	,[strLocationName]					= SMCL.[strLocationName]
	,[intShipToLocationId]				= NULL--ICIS.[intShipToLocationId]
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
	,[dblQtyShipped]					= [dbo].[fnCalculateQtyBetweenUOM](ISNULL(ARCC.[intOrderUOMId],LD.[intWeightItemUOMId]), ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), LD.[dblQuantity])
	,[dblQtyOrdered]					= ISNULL(LD.dblQuantity,0)
	,[dblShipmentQuantity]				= [dbo].[fnCalculateQtyBetweenUOM](ISNULL(ARCC.[intOrderUOMId],LD.[intWeightItemUOMId]), ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), LD.[dblQuantity]) --dbo.fnCalculateQtyBetweenUOM(ICISI.[intItemUOMId], ISNULL(ICISI.[intWeightUOMId],ICISI.[intItemUOMId]), ISNULL(ICISI.[dblQuantity],0))
	,[dblShipmentQtyShippedTotal]		= [dbo].[fnCalculateQtyBetweenUOM](ISNULL(ARCC.[intOrderUOMId],LD.[intWeightItemUOMId]), ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), LD.[dblQuantity])
	,[dblQtyRemaining]					= [dbo].[fnCalculateQtyBetweenUOM](ISNULL(ARCC.[intOrderUOMId],LD.[intWeightItemUOMId]), ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), LD.[dblQuantity])
	,[dblDiscount]						= 0
	,[dblPrice]							= ARCC.[dblCashPrice] 
	,[dblShipmentUnitPrice]				= ARCC.[dblCashPrice]
	,[strPricing]						= ''
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId]), ISNULL(LD.[intWeightItemUOMId], ISNULL(ARCC.[intItemUOMId],LD.[intItemUOMId])), ISNULL(LD.[dblQuantity], 0)) * ARCC.[dblCashPrice]
	,[intStorageLocationId]				= SL.[intStorageLocationId]
	,[strStorageLocationName]			= CAST(ISNULL(SL.[strName],'') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= ARCC.[intDestinationGradeId]
	,[strDestinationGrade]				= ARCC.[strDestinationGrade]
	,[intDestinationWeightId]			= ARCC.[intDestinationWeightId]
	,[strDestinationWeight]				= ARCC.[strDestinationWeight]
	,[intCurrencyExchangeRateTypeId]	= ARCC.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= ARCC.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARCC.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARCC.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= ARCC.[intSubCurrencyId] 
	,[dblSubCurrencyRate]				= ARCC.[dblSubCurrencyRate] 
	,[strSubCurrency]					= SMC.[strCurrency]
FROM 
	(SELECT intLoadId,
			[strLoadNumber],
			[dtmScheduledDate]
	 FROM tblLGLoad WITH (NOLOCK)
	 WHERE ysnPosted = 1) L
JOIN (SELECT intLoadId, 
			intLoadDetailId, 
			intCustomerEntityId,
			intItemId,
			intSContractDetailId,
			intItemUOMId,
			intWeightItemUOMId,
			intSCompanyLocationId,
			intPContractDetailId,
			dblQuantity
	  FROM tblLGLoadDetail WITH (NOLOCK)) LD ON L.intLoadId  = LD.intLoadId
INNER JOIN 
	(SELECT [intEntityCustomerId],
			[intCurrencyId]
	 FROM tblARCustomer WITH (NOLOCK)) ARC ON LD.intCustomerEntityId = ARC.intEntityCustomerId
INNER JOIN 
	(SELECT [intItemId],
		[strItemNo],
		[strDescription]
	 FROM tblICItem WITH (NOLOCK)) ICI ON LD.intItemId = ICI.intItemId
LEFT JOIN (SELECT intLoadDetailId,
			intLotId,
			dblGross,
			dblTare,
			dblNet
	  FROM tblLGLoadDetailLot WITH (NOLOCK)) LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN 
	(SELECT intLotId,
			intStorageLocationId
	FROM tblICLot WITH (NOLOCK)) LO ON LO.intLotId = LDL.intLotId
LEFT JOIN 
	(SELECT [intStorageLocationId],
		[strName]
	 FROM tblICStorageLocation WITH (NOLOCK)) SL ON SL.intStorageLocationId = LO.intStorageLocationId
LEFT JOIN 
	(SELECT [intContractHeaderId],
			[intContractDetailId],
			[strContractNumber],
			[intContractSeq], 
			[intDestinationGradeId],
			[strDestinationGrade],
			[intDestinationWeightId],
			[strDestinationWeight],
			[intSubCurrencyId],
			[intCurrencyId],
			[strUnitMeasure],
			[intOrderUOMId],
			[intItemUOMId],
			[strOrderUnitMeasure],
			[dblCashPrice],
			[dblDetailQuantity],
			[intFreightTermId],
			[dblShipQuantity],
			[dblOrderQuantity],
			[dblSubCurrencyRate],
			[intCurrencyExchangeRateTypeId],
			[strCurrencyExchangeRateType],
			[intCurrencyExchangeRateId],
			[dblCurrencyExchangeRate]
	 FROM vyuARCustomerContract WITH (NOLOCK)) ARCC ON ARCC.intContractDetailId = LD.intSContractDetailId
LEFT JOIN 
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU ON LD.intItemUOMId = ICIU.intItemUOMId
LEFT JOIN 
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM ON ICIU.intUnitMeasureId = ICUM.intUnitMeasureId
LEFT JOIN 
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICIU1 ON LD.intItemUOMId = ICIU1.intItemUOMId
LEFT JOIN 
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICUM1 ON ICIU1.intUnitMeasureId = ICUM1.intUnitMeasureId
LEFT JOIN 
	(SELECT [intItemUOMId],
		[intUnitMeasureId]
	 FROM tblICItemUOM WITH (NOLOCK)) ICUM3 ON LD.intWeightItemUOMId = ICUM3.intItemUOMId
LEFT JOIN 
	(SELECT [intUnitMeasureId],
		[strUnitMeasure]
	 FROM tblICUnitMeasure WITH (NOLOCK)) ICIU2 ON ICUM3.intUnitMeasureId = ICIU2.intUnitMeasureId
INNER JOIN 
	(SELECT [intEntityId],
			strName
	 FROM tblEMEntity WITH (NOLOCK)) EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentItemId],
		[intRecipeItemId],
		[strShipmentNumber],
		[intLoadDetailId]
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON LD.intLoadDetailId = ARID.[intLoadDetailId]
LEFT OUTER JOIN 
	(SELECT [intCompanyLocationId],
		strLocationName
	 FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON LD.intSCompanyLocationId = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN 
	(SELECT [intCurrencyID],
		[strCurrency]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON ARCC.[intSubCurrencyId] = SMC.[intCurrencyID]
WHERE
	ISNULL(ARID.[intLoadDetailId], 0) = 0
	 

UNION
		
SELECT  [strTransactionType]			= 'Load Schedule'
	,[strTransactionNumber]				= [strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(LWS.intLoadDetailId AS NVARCHAR(250))
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[strCustomerName]					= [strCustomerName]
	,[intCurrencyId]					= LWS.[intCurrencyId]
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
	,[intLotId]							= NULL
	,[strLoadNumber]					= strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= LWS.[intContractHeaderId]
	,[strContractNumber]				= [strContractNumber]
	,[intContractDetailId]				= LWS.[intContractDetailId]
	,[intContractSeq]					= [intContractSeq]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[strLocationName]					= [strLocationName]
	,[intShipToLocationId]				= NULL --ICIS.[intShipToLocationId]
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= LWS.[dblTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= ARID.[intDestinationGradeId]
	,[strDestinationGrade]				= CTDG.[strDestinationGrade]
	,[intDestinationWeightId]			= ARID.[intDestinationWeightId]
	,[strDestinationWeight]				= CTDW.[strDestinationWeight]
	,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARID.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= LWS.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM 
	(SELECT [intLoadDetailId],
			[intCurrencyId],
			strLoadNumber, 
			intEntityCustomerId,
			strCustomerName,
			dtmProcessDate,
			intLoadId,
			intContractHeaderId,
			strContractNumber,
			intContractDetailId,
			intContractSeq,
			intCompanyLocationId,
			strLocationName,
			intItemId,
			strItemNo,
			strItemDescription,
			dblPrice,
			dblShipmentUnitPrice,
			dblTotal,
			ysnPosted
	 FROM vyuLGLoadWarehouseServicesForInvoice WITH (NOLOCK)
	 WHERE [ysnPosted] = 1 AND ISNULL(intItemId,0) <> 0) LWS
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentItemId],
		[intRecipeItemId],
		[strShipmentNumber],
		[intDestinationGradeId], 
		[intLoadDetailId],
		[intDestinationWeightId],
		[intCurrencyExchangeRateTypeId],
		[intCurrencyExchangeRateId],
		[dblCurrencyExchangeRate]
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARID.intLoadDetailId = LWS.[intLoadDetailId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationGrade]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDG
		ON ARID.[intDestinationGradeId] = CTDG.[intWeightGradeId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationWeight]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDW
		ON ARID.[intDestinationWeightId] = CTDW.[intWeightGradeId]
LEFT OUTER JOIN 
	(SELECT [intCurrencyID],
		[strCurrency],
		[intCent]
	 FROM tblSMCurrency WITH (NOLOCK)) SMC ON LWS.[intCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ARID.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
WHERE LWS.[ysnPosted] = 1 AND ISNULL(ARID.[intLoadDetailId], 0) = 0 AND ISNULL(LWS.intItemId,0) <> 0

UNION
		
SELECT  [strTransactionType]			= 'Load Schedule'
	,[strTransactionNumber]				= [strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(LC.intLoadDetailId AS NVARCHAR(250))
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[strCustomerName]					= [strCustomerName]
	,[intCurrencyId]					= LC.[intCurrencyId]
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
	,[intLoadId]						= LC.intLoadId
	,[intLoadDetailId]					= LC.intLoadDetailId
	,[intLotId]							= LGLDL.[intLotId]
	,[strLoadNumber]					= strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= LC.[intContractHeaderId]
	,[strContractNumber]				= [strContractNumber]
	,[intContractDetailId]				= LC.[intContractDetailId]
	,[intContractSeq]					= [intContractSeq]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[strLocationName]					= [strLocationName]
	,[intShipToLocationId]				= NULL --ICIS.[intShipToLocationId]
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= LC.[dblTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= ARID.[intDestinationGradeId]
	,[strDestinationGrade]				= CTDG.[strDestinationGrade]
	,[intDestinationWeightId]			= ARID.[intDestinationWeightId]
	,[strDestinationWeight]				= CTDW.[strDestinationWeight]
	,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARID.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= LC.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM	
	(SELECT intLoadId, 
			[intLoadDetailId], 
			[intCurrencyId], 
			strLoadNumber,
			intEntityCustomerId, 
			strCustomerName, 
			intContractHeaderId, 
			strContractNumber, 
			dtmProcessDate, 
			intContractDetailId, 
			intContractSeq,
			intCompanyLocationId, 
			strLocationName, 
			intItemId, 
			strItemNo, 
			strItemDescription, 
			dblPrice, 
			dblShipmentUnitPrice, 
			dblTotal,
			ysnPosted
	 FROM vyuLGLoadCostForCustomer WITH (NOLOCK) 
	 WHERE [ysnPosted] = 1) LC
LEFT OUTER JOIN
	(SELECT intLoadDetailId, 
		[intDestinationGradeId], 
		[intDestinationWeightId],
		[intCurrencyExchangeRateTypeId],
		[intCurrencyExchangeRateId],
		[dblCurrencyExchangeRate]
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARID.intLoadDetailId = LC.[intLoadDetailId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationGrade]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDG
		ON ARID.[intDestinationGradeId] = CTDG.[intWeightGradeId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationWeight]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDW
		ON ARID.[intDestinationWeightId] = CTDW.[intWeightGradeId]
LEFT OUTER JOIN 
	(SELECT [intCurrencyID], 
		[strCurrency], 
		[intCent] 
	FROM tblSMCurrency WITH (NOLOCK)) SMC ON LC.[intCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ARID.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN
	(
		SELECT 
			 LGLSC.[intLoadId]
			,LDL.[intLotId]
			,LDL.[intLoadDetailId]
		FROM
			tblLGLoadDetailLot LDL
		INNER JOIN
			(
				SELECT
					 [intLoadId]
					,[intLoadDetailLotId]
				FROM
					tblLGLoadStorageCost 
			) LGLSC
				ON LDL.[intLoadDetailLotId] = LGLSC.[intLoadDetailLotId]
	) LGLDL
		ON LC.[intLoadId] = LGLDL.[intLoadId]
		AND LC.[intLoadDetailId] = LGLDL.[intLoadDetailId]
WHERE LC.[ysnPosted] = 1 AND ISNULL(ARID.[intLoadDetailId], 0) = 0

UNION

SELECT  [strTransactionType]			= 'Load Schedule'
	,[strTransactionNumber]				= [strLoadNumber]
	,[strShippedItemId]					= 'lgis:' + CAST(LC.intLoadDetailId AS NVARCHAR(250))
	,[intEntityCustomerId]				= [intEntityCustomerId]
	,[strCustomerName]					= [strCustomerName]
	,[intCurrencyId]					= LC.[intCurrencyId]
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
	,[intLoadId]						= LC.intLoadId
	,[intLoadDetailId]					= LC.intLoadDetailId
	,[intLotId]							= LGLDL.intLotId 
	,[strLoadNumber]					= strLoadNumber
	,[intRecipeItemId]					= NULL
	,[intContractHeaderId]				= LC.[intContractHeaderId]
	,[strContractNumber]				= [strContractNumber]
	,[intContractDetailId]				= LC.[intContractDetailId]
	,[intContractSeq]					= [intContractSeq]
	,[intCompanyLocationId]				= [intCompanyLocationId]
	,[strLocationName]					= [strLocationName]
	,[intShipToLocationId]				= NULL --ICIS.[intShipToLocationId]
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
	,[strVFDDocumentNumber]				= NULL
	,[dblTotalTax]						= 0
	,[dblTotal]							= LC.[dblTotal]
	,[intStorageLocationId]				= NULL
	,[strStorageLocationName]			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,[intTermID]						= NULL
	,[strTerm]							= ''
	,[intEntityShipViaId]				= NULL
	,[strShipVia]						= ''
	,[strTicketNumber]					= NULL
	,[strCustomerReference]				= NULL
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
	,[intDestinationGradeId]			= ARID.[intDestinationGradeId]
	,[strDestinationGrade]				= CTDG.[strDestinationGrade]
	,[intDestinationWeightId]			= ARID.[intDestinationWeightId]
	,[strDestinationWeight]				= CTDW.[strDestinationWeight]
	,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= ARID.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]					= LC.[intCurrencyId]
	,[dblSubCurrencyRate]				= CASE WHEN ISNULL(SMC.[intCent], 0) = 0 THEN 1.000000 ELSE CAST(SMC.[intCent] AS NUMERIC(18,6)) END
	,[strSubCurrency]					= SMC.[strCurrency]
FROM 
	(SELECT intLoadId, 
		[intLoadDetailId], 
		[intCurrencyId],
		strLoadNumber, 
		intEntityCustomerId, 
		strCustomerName, 
		intContractHeaderId, 
		strContractNumber, 
		dtmProcessDate, 
		intContractDetailId, 
		intContractSeq,
		intCompanyLocationId, 
		strLocationName, 
		intItemId, 
		strItemNo, 
		strItemDescription,
		dblPrice, 
		dblShipmentUnitPrice, 
		dblTotal,
		ysnPosted
	 FROM vyuLGLoadStorageCostForInvoice WITH (NOLOCK)
	 WHERE [ysnPosted] = 1) LC
LEFT OUTER JOIN 
	(SELECT intLoadDetailId, 
		[intDestinationGradeId], 
		[intDestinationWeightId],
		[intCurrencyExchangeRateTypeId],
		[intCurrencyExchangeRateId],
		[dblCurrencyExchangeRate]
	FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARID.intLoadDetailId = LC.[intLoadDetailId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationGrade]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDG
		ON ARID.[intDestinationGradeId] = CTDG.[intWeightGradeId]
LEFT OUTER JOIN
	(
		SELECT
			[intWeightGradeId]		= [intWeightGradeId]
			,[strDestinationWeight]	= [strWeightGradeDesc]
		FROM
			tblCTWeightGrade WITH (NOLOCK)
	) CTDW
		ON ARID.[intDestinationWeightId] = CTDW.[intWeightGradeId]
LEFT OUTER JOIN 
	(SELECT [intCurrencyID], 
		[strCurrency], 
		[intCent] 
	FROM tblSMCurrency WITH (NOLOCK)) SMC ON LC.[intCurrencyId] = SMC.[intCurrencyID] 
LEFT OUTER JOIN
	tblSMCurrencyExchangeRateType SMCRT
		ON ARID.[intCurrencyExchangeRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN
	(
		SELECT 
			 LGLSC.[intLoadId]
			,LDL.[intLotId]
			,LDL.[intLoadDetailId]
		FROM
			tblLGLoadDetailLot LDL
		INNER JOIN
			(
				SELECT
					 [intLoadId]
					,[intLoadDetailLotId]
				FROM
					tblLGLoadStorageCost 
			) LGLSC
				ON LDL.[intLoadDetailLotId] = LGLSC.[intLoadDetailLotId]
	) LGLDL
		ON LC.[intLoadId] = LGLDL.[intLoadId]
		AND LC.[intLoadDetailId] = LGLDL.[intLoadDetailId]
WHERE LC.[ysnPosted] = 1 AND ISNULL(ARID.[intLoadDetailId], 0) = 0
) ShippedItems
