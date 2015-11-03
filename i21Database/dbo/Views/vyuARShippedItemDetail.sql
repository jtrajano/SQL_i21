CREATE VIEW [dbo].[vyuARShippedItemDetail]
AS

SELECT
	 [strShippedItemId]						= 'lgis:' + CAST(LGSPS.[intShipmentId] AS NVARCHAR(250))
	,[strShippedItemDetailId]				= 'lgis:' + CAST(LGSPS.[intShipmentPurchaseSalesContractId] AS NVARCHAR(250))
	,[intShipmentId]						= LGSPS.[intShipmentId]
	,[intShipmentPurchaseSalesContractId]	= LGSPS.[intShipmentPurchaseSalesContractId] 
	,[intSalesOrderDetailId]				= NULL
	,[intInventoryShipmentId]				= NULL	
	,[intInventoryShipmentItemId]			= NULL	
	,[intContractHeaderId]					= CTCD.[intContractHeaderId]
	,[strContractNumber]					= CTCD.[strContractNumber] 
	,[intContractDetailId]					= CTCD.[intContractDetailId] 
	,[intContractSeq]						= CTCD.[intContractSeq] 
	,[intItemId]							= CTCD.[intItemId]
	,[strItemNo]							= ICI.[strItemNo]
	,[strItemDescription]					= ICI.[strDescription]
	,[intItemUOMId]							= CTCD.[intItemUOMId]
	,[strUnitMeasure]						= ICUM.[strUnitMeasure]
	,[intShipmentItemUOMId]					= CTCD.[intItemUOMId]
	,[strShipmentUnitMeasure]				= ICUM.[strUnitMeasure]
	,[dblQtyShipped]						= LGSPS.[dblSAllocatedQty]
	,[dblQtyOrdered]						= LGSPS.[dblSAllocatedQty]
	,[dblShipmentQuantity]					= LGSPS.[dblSAllocatedQty]	
	,[dblShipmentQtyShippedTotal]			= LGSPS.[dblSAllocatedQty]
	,[dblQtyRemaining]						= LGSPS.[dblSAllocatedQty]
	,[dblDiscount]							= 0.00
	,[dblPrice]								= CTCD.[dblCashPrice]
	,[dblShipmentUnitPrice]					= CTCD.[dblCashPrice]
	,[dblTotalTax]							= 0.00
	,[dblTotal]								= LGSPS.[dblSAllocatedQty] * CTCD.[dblCashPrice]
	,[intAccountId]							= ARIA.[intAccountId]
	,[intCOGSAccountId]						= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]					= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]				= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]					= NULL
	,[strStorageLocationName]				= NULL	
	,[intTaxGroupId]						= NULL
	,[strTaxGroup]							= NULL
FROM
	vyuLGDropShipmentDetails LGSPS
INNER JOIN
	vyuCTContractDetailView CTCD
		ON LGSPS.intSContractDetailId = CTCD.intContractDetailId
INNER JOIN
	tblICItem ICI
		ON CTCD.[intItemId] = ICI.[intItemId]
LEFT JOIN
	tblICItemUOM ICIU
		ON CTCD.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT JOIN
	tblICUnitMeasure ICUM
		ON ICUM.[intUnitMeasureId] = ICIU.[intUnitMeasureId]			
LEFT OUTER JOIN
	vyuARGetItemAccount ARIA
		ON CTCD.[intItemId] = ARIA.[intItemId]
		AND CTCD.[intCompanyLocationId] = ARIA.[intLocationId]
LEFT OUTER JOIN
	tblSMTerm SMT
		ON CTCD.[intTermId] = SMT.[intTermID]	
LEFT OUTER JOIN
	tblSMShipVia SMSV
		ON CTCD.[intShipViaId] = SMSV.[intEntityShipViaId]
