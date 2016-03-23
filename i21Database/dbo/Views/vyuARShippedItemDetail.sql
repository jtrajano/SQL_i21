CREATE VIEW [dbo].[vyuARShippedItemDetail]
AS

SELECT
	 [strShippedItemId]						= 'lgis:' + CAST(LGSPS.[intShipmentId] AS NVARCHAR(250))
	,[strShippedItemDetailId]				= 'lgis:' + CAST(LGSPS.[intShipmentPurchaseSalesContractId] AS NVARCHAR(250))
	,[intShipmentId]						= LGSPS.[intShipmentId]
	,[intShipmentPurchaseSalesContractId]	= LGSPS.[intShipmentPurchaseSalesContractId] 
	,[intCurrencyId]						= ISNULL(CTCD.[intCurrencyId], (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderDetailId]				= NULL
	,[intInventoryShipmentId]				= NULL	
	,[intInventoryShipmentItemId]			= NULL	
	,[intContractHeaderId]					= CTCD.[intContractHeaderId]
	,[strContractNumber]					= CTCD.[strContractNumber] 
	,[intContractDetailId]					= CTCD.[intContractDetailId] 
	,[intContractSeq]						= CTCD.[intContractSeq] 
	,[intItemId]							= LGSPS.[intPItemId]
	,[strItemNo]							= ICI.[strItemNo]
	,[strItemDescription]					= ICI.[strDescription]
	,[intItemUOMId]							= ICUOM.[intItemUOMId]
	,[strUnitMeasure]						= ICUM.[strUnitMeasure]
	,[intShipmentItemUOMId]					= ICUOM.[intItemUOMId] 
	,[strShipmentUnitMeasure]				= ICUM.[strUnitMeasure]
	,[dblQtyShipped]						= LGSPS.[dblSAllocatedQty]
	,[dblQtyOrdered]						= LGSPS.[dblSAllocatedQty]
	,[dblShipmentQuantity]					= LGSPS.[dblSAllocatedQty]	
	,[dblShipmentQtyShippedTotal]			= LGSPS.[dblSAllocatedQty]
	,[dblQtyRemaining]						= LGSPS.[dblSAllocatedQty]
	,[dblDiscount]							= 0.00
	,[dblPrice]								= [dbo].[fnCalculateQtyBetweenUOM](ICUOM.[intItemUOMId],CTCD.[intPriceItemUOMId],1) * CTCD.[dblCashPrice]
	,[dblShipmentUnitPrice]					= CTCD.[dblCashPrice]
	,[dblTotalTax]							= 0.00
	,[dblTotal]								= [dbo].[fnCalculateQtyBetweenUOM](ICUOM.[intItemUOMId],CTCD.[intPriceItemUOMId],LGSPS.[dblSAllocatedQty]) * CTCD.[dblCashPrice]
	,[intAccountId]							= ARIA.[intAccountId]
	,[intCOGSAccountId]						= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]					= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]				= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]					= NULL
	,[strStorageLocationName]				= NULL	
	,[intTaxGroupId]						= NULL
	,[strTaxGroup]							= NULL
	,[dblWeight]							= ICUOM.[dblWeight]
	,[intWeightUOMId]						= LGSPS.[intWeightUnitMeasureId]
	,[strWeightUnitMeasure]					= LGSPS.[strWeightUOM] 
	,[dblGrossWt]							= LGSPS.[dblGrossWt] 
	,[dblTareWt]							= LGSPS.[dblTareWt] 
	,[dblNetWt]								= LGSPS.[dblNetWt] 
FROM
	vyuLGDropShipmentDetails LGSPS
INNER JOIN
	vyuCTContractDetailView CTCD
		ON LGSPS.intSContractDetailId = CTCD.intContractDetailId
INNER JOIN
	tblICItem ICI
		ON LGSPS.[intPItemId] = ICI.[intItemId]
LEFT JOIN
	tblICUnitMeasure ICUM
		ON LGSPS.[intSUnitMeasureId] = ICUM.[intUnitMeasureId]
LEFT OUTER JOIN
	tblICItemUOM ICUOM
		ON 	LGSPS.[intSItemId] = ICUOM.[intItemId] 
		AND LGSPS.[intSUnitMeasureId] = ICUOM.[intUnitMeasureId] 
LEFT JOIN
	tblICItemUOM ICIU1
		ON CTCD.[intPriceItemUOMId] = ICIU1.[intItemUOMId]						
LEFT OUTER JOIN
	vyuARGetItemAccount ARIA
		ON LGSPS.[intPItemId] = ARIA.[intItemId]
		AND CTCD.[intCompanyLocationId] = ARIA.[intLocationId]
LEFT OUTER JOIN
	tblSMTerm SMT
		ON CTCD.[intTermId] = SMT.[intTermID]	
LEFT OUTER JOIN
	tblSMShipVia SMSV
		ON CTCD.[intShipViaId] = SMSV.[intEntityShipViaId]
