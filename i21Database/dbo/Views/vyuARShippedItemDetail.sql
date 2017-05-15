CREATE VIEW [dbo].[vyuARShippedItemDetail]
AS

SELECT
	 [strShippedItemId]				= 'lgis:' + CAST(LGSPS.[intLoadId] AS NVARCHAR(250))
	,[strShippedItemDetailId]		= 'lgis:' + CAST(LGSPS.[intLoadDetailId] AS NVARCHAR(250))
	,[intShipmentId]				= LGSPS.[intLoadId]
	,[intShipmentPurchaseSalesContractId] = NULL 
	,[intLoadDetailId]				= LGSPS.[intLoadDetailId] 
	,[intCurrencyId]				= ISNULL(ARCC.[intCurrencyId], (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderDetailId]		= NULL
	,[intInventoryShipmentId]		= NULL	
	,[intInventoryShipmentItemId]	= NULL	
	,[intContractHeaderId]			= ARCC.[intContractHeaderId]
	,[strContractNumber]			= ARCC.[strContractNumber] 
	,[intContractDetailId]			= ARCC.[intContractDetailId] 
	,[intContractSeq]				= ARCC.[intContractSeq] 
	,[intItemId]					= LGSPS.[intSItemId]
	,[strItemNo]					= ICI.[strItemNo]
	,[strItemDescription]			= ICI.[strDescription]
	,[intItemUOMId]					= ICUOM.[intItemUOMId]
	,[strUnitMeasure]				= ICUM.[strUnitMeasure]
	,[intShipmentItemUOMId]			= ICUOM.[intItemUOMId] 
	,[strShipmentUnitMeasure]		= ICUM.[strUnitMeasure]
	,[dblQtyShipped]				= LGSPS.[dblSAllocatedQty]
	,[dblQtyOrdered]				= LGSPS.[dblSAllocatedQty]
	,[dblShipmentQuantity]			= LGSPS.[dblSAllocatedQty]	
	,[dblShipmentQtyShippedTotal]	= LGSPS.[dblSAllocatedQty]
	,[dblQtyRemaining]				= LGSPS.[dblSAllocatedQty]
	,[dblDiscount]					= 0.00
	,[dblPrice]						= ARCC.[dblCashPrice]
	,[dblShipmentUnitPrice]			= ARCC.[dblCashPrice]
	,[strPricing]					= ''
	,[dblTotalTax]					= 0.00
	,[dblTotal]						= LGSPS.[dblSAllocatedQty] * ARCC.[dblCashPrice]
	,[intLotId]						= NULL
	,[intAccountId]					= ARIA.[intAccountId]
	,[intCOGSAccountId]				= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]			= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]		= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]			= NULL
	,[strStorageLocationName]		= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS	
	,[intTaxGroupId]				= NULL
	,[strTaxGroup]					= NULL
	,[dblWeight]					= [dbo].[fnCalculateQtyBetweenUOM](ICUOM2.[intItemUOMId],ICUOM.[intItemUOMId],1) --ICUOM.[dblWeight]
	,[intWeightUOMId]				= LGSPS.[intWeightUnitMeasureId]
	,[strWeightUnitMeasure]			= LGSPS.[strWeightUOM] 
	,[dblGrossWt]					= LGSPS.[dblGrossWt] 
	,[dblTareWt]					= LGSPS.[dblTareWt] 
	,[dblNetWt]						= LGSPS.[dblNetWt]
	,[intCurrencyExchangeRateTypeId]= ARCC.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]	= ARCC.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]	= ARCC.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]		= ARCC.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]				= ARCC.[intSubCurrencyId]
	,[dblSubCurrencyRate]			= ARCC.[dblSubCurrencyRate]
	,[strSubCurrency]				= ARCC.[strSubCurrency]
	,[intDestinationGradeId]		= ARCC.[intDestinationGradeId]
	,[strDestinationGrade]			= ARCC.[strDestinationGrade]
	,[intDestinationWeightId]		= ARCC.[intDestinationWeightId]
	,[strDestinationWeight]			= ARCC.[strDestinationWeight]
FROM
	vyuLGDropShipmentDetailsView LGSPS
INNER JOIN
	vyuARCustomerContract ARCC
		ON LGSPS.intSContractDetailId = ARCC.intContractDetailId
INNER JOIN
	tblICItem ICI
		ON LGSPS.[intSItemId] = ICI.[intItemId]
LEFT JOIN
	tblICUnitMeasure ICUM
		ON LGSPS.[intSUnitMeasureId] = ICUM.[intUnitMeasureId]
LEFT OUTER JOIN
	tblICItemUOM ICUOM
		ON 	LGSPS.[intSItemId] = ICUOM.[intItemId] 
		AND LGSPS.[intSUnitMeasureId] = ICUOM.[intUnitMeasureId] 
LEFT JOIN
	tblICItemUOM ICIU1
		ON ARCC.[intPriceItemUOMId] = ICIU1.[intItemUOMId]	
LEFT OUTER JOIN
	tblICItemUOM ICUOM2
		ON 	LGSPS.[intSItemId] = ICUOM2.[intItemId] 
		AND LGSPS.[intWeightUnitMeasureId] = ICUOM2.[intUnitMeasureId]							
LEFT OUTER JOIN
	vyuARGetItemAccount ARIA
		ON LGSPS.[intSItemId] = ARIA.[intItemId]
		AND ARCC.[intCompanyLocationId] = ARIA.[intLocationId]
LEFT OUTER JOIN
	tblSMTerm SMT
		ON ARCC.[intTermId] = SMT.[intTermID]	
LEFT OUTER JOIN
	tblSMShipVia SMSV
		ON ARCC.[intShipViaId] = SMSV.[intEntityShipViaId]