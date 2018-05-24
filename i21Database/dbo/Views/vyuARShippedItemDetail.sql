CREATE VIEW [dbo].[vyuARShippedItemDetail]
AS

SELECT
	 [strShippedItemId]				= 'lgis:' + CAST(LS.[intLoadId] AS NVARCHAR(250))
	,[strShippedItemDetailId]		= 'lgis:' + CAST(LS.[intLoadDetailId] AS NVARCHAR(250))
	,[intShipmentId]				= LS.[intLoadId]
	,[intShipmentPurchaseSalesContractId] = NULL 
	,[intLoadDetailId]				= LS.[intLoadDetailId] 
	,[intCurrencyId]				= LS.[intLoadDetailId]
	,[intSalesOrderDetailId]		= LS.[intSalesOrderDetailId]
	,[intInventoryShipmentId]		= LS.[intInventoryShipmentId]	
	,[intInventoryShipmentItemId]	= LS.[intInventoryShipmentItemId]	
	,[intContractHeaderId]			= LS.[intContractHeaderId]
	,[strContractNumber]			= ARCC.[strContractNumber] 
	,[intContractDetailId]			= LS.[intContractDetailId] 
	,[intContractSeq]				= ARCC.[intContractSeq] 
	,[intItemId]					= LS.[intItemId]
	,[strItemNo]					= ICI.[strItemNo]
	,[strItemDescription]			= ICI.[strDescription]
	,[intOrderUOMId]				= LS.[intOrderUOMId]
	,[strOrderUnitMeasure]			= OUOM.[strUnitMeasure]
	,[intItemUOMId]					= LS.[intItemUOMId]
	,[strUnitMeasure]				= SUOM.[strUnitMeasure]
	,[intPriceUOMId]				= LS.[intWeightUOMId]
	,[strPriceUnitMeasure]			= WUOM.[strUnitMeasure]
	,[intShipmentItemUOMId]			= LS.[intShipmentItemUOMId]
	,[strShipmentUnitMeasure]		= SUOM.[strUnitMeasure]
	,[dblQtyShipped]				= LS.[dblQtyShipped]
	,[dblQtyOrdered]				= LS.[dblQtyOrdered]
	,[dblShipmentQuantity]			= LS.[dblShipmentQuantity]
	,[dblShipmentQtyShippedTotal]	= LS.[dblShipmentQtyShippedTotal]
	,[dblQtyRemaining]				= LS.[dblQtyRemaining]
	,[dblDiscount]					= LS.[dblDiscount]
	,[dblPrice]						= LS.[dblPrice]
	,[dblShipmentUnitPrice]			= LS.[dblShipmentUnitPrice]
	,[strPricing]					= LS.[strPricing]
	,[dblTotalTax]					= LS.[dblTotalTax]
	,[dblTotal]						= LS.[dblTotal]
	,[intLotId]						= LS.[intLotId]
	,[intAccountId]					= ARIA.[intAccountId]
	,[intCOGSAccountId]				= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]			= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]		= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]			= LS.[intStorageLocationId]
	,[strStorageLocationName]		= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS	
	,[intTaxGroupId]				= NULL
	,[strTaxGroup]					= NULL
	,[dblWeight]					= LS.[dblWeight]
	,[intWeightUOMId]				= LS.[intWeightUOMId]
	,[strWeightUnitMeasure]			= ARCC.strUnitMeasure
	,[dblGrossWt]					= LS.[dblGrossWt]
	,[dblTareWt]					= LS.[dblTareWt]
	,[dblNetWt]						= LS.[dblNetWt]
	,[intCurrencyExchangeRateTypeId]= LS.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]	= ARCC.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]	= LS.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]		= LS.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]				= LS.[intSubCurrencyId]
	,[dblSubCurrencyRate]			= LS.[dblSubCurrencyRate]
	,[strSubCurrency]				= ARCC.[strSubCurrency]
	,[intDestinationGradeId]		= LS.[intDestinationGradeId]
	,[strDestinationGrade]			= ARCC.[strDestinationGrade]
	,[intDestinationWeightId]		= LS.[intDestinationWeightId]
	,[strDestinationWeight]			= ARCC.[strDestinationWeight]
	,[intBookId]					= ARCC.[intBookId]
	,[intSubBookId]					= ARCC.[intSubBookId]
	,[strBook]						= ARCC.[strBook]
	,[strSubBook]					= ARCC.[strSubBook]
FROM
	vyuLGLoadScheduleForInvoice LS
LEFT OUTER JOIN (
	SELECT intContractHeaderId
		 , intContractDetailId
		 , strContractNumber
		 , intContractSeq
		 , strDestinationGrade
		 , strDestinationWeight
		 , strUnitMeasure
		 , strPriceUnitMeasure
		 , intOrderUOMId
		 , intPriceItemUOMId
		 , strSubCurrency
		 , strCurrencyExchangeRateType
		 , intCompanyLocationId
		 , intTermId
		 , intShipViaId
		 , intBookId
		 , intSubBookId
		 , strBook
		 , strSubBook
	 FROM dbo.vyuCTCustomerContract WITH (NOLOCK)
) ARCC ON LS.[intContractDetailId] = ARCC.intContractDetailId
INNER JOIN (
	SELECT [intItemId]
		 , [strItemNo]
		 , [strDescription] 
	FROM tblICItem WITH(NOLOCK)
) ICI ON LS.[intItemId] = ICI.[intItemId]
LEFT JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) SUOM ON LS.[intItemUOMId] = SUOM.intItemUOMId	
LEFT JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) WUOM ON LS.[intWeightUOMId] = WUOM.intItemUOMId			
LEFT JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) OUOM ON LS.[intOrderUOMId] = OUOM.intItemUOMId						
LEFT OUTER JOIN (
	SELECT [intItemId]
		 , [intAccountId]
		 , [intLocationId]
		 , [intCOGSAccountId]
		 , [intSalesAccountId]
		 , [intInventoryAccountId] 
	FROM vyuARGetItemAccount
) ARIA ON LS.[intItemId] = ARIA.[intItemId]
	 AND ARCC.[intCompanyLocationId] = ARIA.[intLocationId]
