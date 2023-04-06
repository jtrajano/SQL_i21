CREATE PROCEDURE [dbo].[uspARPopulateItemsForCosting]
	@strSessionId		NVARCHAR(50)	= NULL
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
SELECT	@INVENTORY_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	strName = 'Invoice'

DECLARE @CREDIT_MEMO_INVOICE_TYPE AS INT = 45
SELECT	@CREDIT_MEMO_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	strName = 'Credit Memo'

DECLARE	@AVERAGECOST 	AS INT	= 1
      , @CATEGORYCOST 	AS INT 	= 6
DECLARE @ZeroDecimal 	DECIMAL(18,6) = 0.000000	
DECLARE @ZeroBit 		BIT = CAST(0 AS BIT)	
DECLARE @OneBit 		BIT = CAST(1 AS BIT)

INSERT INTO tblARPostItemsForCosting
	([intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[strActualCostId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustRetailValue]
	,[strType]
	,[ysnAutoBlend]
	,[ysnGLOnly]
	,[strBOLNumber]
	,[intTicketId]
	,[intSourceEntityId]
	,[strSessionId]
)
SELECT 
	 [intItemId]				= ARID.[intItemId] 
	,[intItemLocationId]		= ARID.[intItemLocationId]
	,[intItemUOMId]				= CASE WHEN ITEM.ysnSeparateStockForUOMs = 0 THEN ICIUOM_STOCK.[intItemUOMId] ELSE ISNULL(dbo.fnGetMatchingItemUOMId(ARID.[intItemId], ICIUOM.intUnitMeasureId), ARID.[intItemUOMId]) END
	,[dtmDate]					= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]					= (CASE WHEN ARID.[intInventoryShipmentItemId] IS NOT NULL AND ARID.[strType] = 'Standard' AND ARID.[strTransactionType] = 'Invoice' AND ARID.[dblQtyShipped] > ARIDP.[dblQtyShipped] THEN ARID.[dblQtyShipped] - ARIDP.[dblQtyShipped]
										WHEN ARID.[intLoadDetailId] IS NOT NULL AND ARID.[strType] = 'Standard' AND ARID.[strTransactionType] = 'Invoice' AND ARID.[dblShipmentNetWt] > ARIDP.[dblShipmentNetWt] THEN ARID.[dblShipmentNetWt] - ARIDP.[dblShipmentNetWt]
										WHEN ARID.[intLoadDistributionDetailId] IS NOT NULL THEN ISNULL(NULLIF(ARID.[dblQtyUnitOrGross], 0), ISNULL(ARIDL.[dblQuantityShipped], ARID.[dblQtyShipped]))
										WHEN ARIDL.[intLotId] IS NULL OR LOT.[intItemUOMId] = ARID.[intItemUOMId] OR LOT.[intWeightUOMId] IS NULL THEN CASE WHEN ysnSeparateStockForUOMs = 0 THEN dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIUOM_STOCK.intItemUOMId, ISNULL(ARIDL.[dblQuantityShipped], ARID.[dblQtyShipped])) ELSE ISNULL(ARIDL.[dblQuantityShipped], ARID.[dblQtyShipped]) END
										ELSE dbo.fnMultiply(ARIDL.[dblQuantityShipped], ISNULL(NULLIF(ARIDL.[dblWeightPerQty], 0), 1))
								   END
								* (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = @ZeroBit THEN -1 ELSE 1 END
	,[dblUOMQty]				= CASE WHEN LOT.[intItemUOMId] = ARID.[intItemUOMId] THEN 1 ELSE ARID.[dblUnitQty] END
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE WHEN ARID.[ysnBlended] = @OneBit 
																	THEN (
																		SELECT SUM(ICIT.[dblCost]) 
																		FROM
																			(SELECT [intTransactionId], [strTransactionId], [dblCost], [ysnIsUnposted], [strTransactionForm] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
																		INNER JOIN
																			(SELECT [intWorkOrderId], [intBatchID], [strWorkOrderNo] FROM tblMFWorkOrder WITH (NOLOCK)) MFWO
																				ON ICIT.[strTransactionId] = MFWO.[strWorkOrderNo]
																				AND ICIT.[intTransactionId] = MFWO.[intBatchID] 
																		WHERE
																			MFWO.[intWorkOrderId] = (SELECT MAX(tblMFWorkOrder.[intWorkOrderId])FROM tblMFWorkOrder WITH (NOLOCK) WHERE tblMFWorkOrder.[intInvoiceDetailId] = ARID.[intInvoiceDetailId])
																			AND ICIT.[ysnIsUnposted] = @ZeroBit
																			AND ICIT.[strTransactionForm] = 'Produce'
																	)
																	ELSE
																		CASE	WHEN dbo.fnGetCostingMethod(ARID.[intItemId], ARID.[intItemLocationId]) = @AVERAGECOST THEN 
																					dbo.fnGetItemAverageCost(ARID.[intItemId], ARID.[intItemLocationId], ARID.intItemUOMId) 
																				ELSE 
																					ARID.[dblLastCost]  
																		END 
																END
																,ARID.[dblSplitPercent])
															,CASE WHEN LOT.[intItemUOMId] = ARID.[intItemUOMId] THEN 1 ELSE ARID.[dblUnitQty] END
														),@ZeroDecimal)
	,[dblSalesPrice]			= ARID.[dblPrice] 
	,[intCurrencyId]			= ARID.[intCurrencyId]
	,[dblExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intTransactionId]			= ARID.[intInvoiceId]
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
	,[strTransactionId]			= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]		= CASE WHEN ARID.strTransactionType = 'Credit Memo' THEN @CREDIT_MEMO_INVOICE_TYPE ELSE @INVENTORY_INVOICE_TYPE END
	,[intLotId]					= ISNULL(ARIDL.[intLotId], ARID.[intLotId])
	,[intSubLocationId]			= ISNULL(LOT.[intSubLocationId], ARID.[intSubLocationId])
	,[intStorageLocationId]		= ISNULL(LOT.[intStorageLocationId], ARID.[intStorageLocationId])
	,[strActualCostId]			= CASE WHEN (ARID.[intDistributionHeaderId] IS NOT NULL OR ARID.[intLoadDistributionHeaderId] IS NOT NULL) THEN ARID.[strActualCostId] ELSE NULL END
	,[intForexRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]				= ARID.[dblCurrencyExchangeRate]
	,[intStorageScheduleTypeId] = ARID.[intStorageScheduleTypeId]
    ,[dblUnitRetail]			= CASE WHEN ARID.ysnRetailValuation = 1 THEN ARID.dblPrice ELSE NULL END
	,[intCategoryId]			= ARID.[intCategoryId]
	,[dblAdjustRetailValue]		= CASE WHEN dbo.fnGetCostingMethod(ARID.[intItemId], ARID.[intItemLocationId]) = @CATEGORYCOST THEN ARID.[dblPrice] ELSE NULL END
	,[strType]					= ARID.[strType]
	,[ysnAutoBlend]				= ARID.[ysnAutoBlend]
	,[ysnGLOnly]				= CASE WHEN (((ISNULL(T.[intTicketTypeId], 0) <> 9 AND (ISNULL(T.[intTicketType], 0) <> 6 OR ISNULL(T.[strInOutFlag], '') <> 'O')) AND ARID.[intTicketId] IS NOT NULL) OR ARID.[intTicketId] IS NULL) THEN @ZeroBit ELSE @OneBit END
	,[strBOLNumber]				= ARID.strBOLNumber 
	,[intTicketId]				= ARID.intTicketId
	,[intSourceEntityId]		= ARID.intEntityCustomerId
	,[strSessionId]				= @strSessionId
FROM
    ##ARPostInvoiceDetail ARID
LEFT OUTER JOIN
	(SELECT [intInvoiceDetailId], [intLotId], [dblQuantityShipped], [dblWeightPerQty] FROM tblARInvoiceDetailLot WITH (NOLOCK)) ARIDL
		ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
LEFT OUTER JOIN
	(SELECT [intInvoiceDetailId], [dblQtyShipped], [dblShipmentNetWt] FROM tblARInvoiceDetail WITH (NOLOCK)) ARIDP
		ON ARIDP.[intInvoiceDetailId] = ARID.[intOriginalInvoiceDetailId]
LEFT OUTER JOIN
	(SELECT [intLotId], [intWeightUOMId], [intStorageLocationId], [intSubLocationId], [intItemUOMId] FROM tblICLot WITH (NOLOCK)) LOT
		ON LOT.[intLotId] = ARIDL.[intLotId]
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARID.[intLoadId]
LEFT OUTER JOIN 
	(SELECT [intTicketId], [intTicketTypeId], [intTicketType], [ysnDestinationWeightGradePost], [strInOutFlag] FROM tblSCTicket WITH (NOLOCK)) T 
		ON ARID.intTicketId = T.intTicketId
LEFT OUTER JOIN(
	SELECT intUnitMeasureId, intItemUOMId FROM tblICItemUOM ICUOM  WITH (NOLOCK)
	INNER JOIN tblICItem ITEM ON ICUOM.intItemId = ITEM.intItemId
) ICIUOM
ON ARID.intItemUOMId = ICIUOM.intItemUOMId
LEFT JOIN tblICItem ITEM ON ARID.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodity COM ON ITEM.intCommodityId = COM.intCommodityId
CROSS APPLY (
	SELECT intItemUOMId 
	FROM tblICItemUOM WITH (NOLOCK)
	WHERE intItemId = ARID.intItemId
	AND ysnStockUnit = 1
) ICIUOM_STOCK

WHERE
    ARID.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund')
    AND ARID.[intPeriodsToAccrue] <= 1
    AND ARID.[ysnImpactInventory] = @OneBit
	AND (((ARID.[strImportFormat] IS NULL OR ARID.[strImportFormat] <> 'CarQuest') AND (ARID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ARID.[intItemId], ARID.[intItemLocationId], ARID.[intItemUOMId]) <> 0)) OR ARID.[strImportFormat] = 'CarQuest') 		
	AND (
		(ARID.[intInventoryShipmentItemId] IS NULL AND ARID.[intLoadDetailId] IS NULL AND  ARID.[strTransactionType] <> 'Credit Memo')
		OR 
		(((ARID.[intInventoryShipmentItemId] IS NOT NULL AND ARID.[dblQtyShipped] > ARIDP.[dblQtyShipped]) OR (ARID.[intLoadDetailId] IS NOT NULL AND ARID.[dblShipmentNetWt] > ARIDP.[dblShipmentNetWt])) AND ARID.[strType] = 'Standard' AND ARID.[strTransactionType] = 'Invoice')
		OR
		((ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intLoadDetailId] IS NULL) AND ARID.[strTransactionType] = 'Credit Memo')
		OR
		(ARID.[intLoadDetailId] IS NOT NULL AND ARID.intTicketId IS NOT NULL)
		)
	AND ARID.[intItemId] IS NOT NULL
	AND (ARID.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment') OR (ARID.[ysnBlended] = @OneBit))
	AND ARID.[strTransactionType] <> 'Debit Memo'							
	AND ARID.[intStorageScheduleTypeId] IS NULL
	AND (ARID.intLoadId IS NULL OR (ARID.intLoadId IS NOT NULL AND LGL.[intPurchaseSale] NOT IN (2, 3)))
	AND (ARID.[ysnFromProvisional] = 0 OR (ARID.[ysnFromProvisional] = 1 AND ((ARID.[dblQtyShipped] <> ARIDP.[dblQtyShipped] AND ARID.[intInventoryShipmentItemId] IS NULL)) OR ((ARID.[dblQtyShipped] > ARIDP.[dblQtyShipped] AND ARID.[intInventoryShipmentItemId] IS NOT NULL))))
	--AND ISNULL(T.[intTicketTypeId], 0) <> 9
	AND (ARID.intTicketId IS NULL OR (ARID.intTicketId IS NOT NULL AND ((T.ysnDestinationWeightGradePost = 1 AND ISNULL(COM.intAdjustInventorySales, 0) <> 2) OR ISNULL(T.ysnDestinationWeightGradePost, 0) = 0)))
	AND ARID.strSessionId = @strSessionId 

--Bundle Items
INSERT INTO tblARPostItemsForCosting
	([intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[strActualCostId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustRetailValue]
	,[strType]
	,[ysnAutoBlend]
	,[strBOLNumber] 
	,[intTicketId]
	,[intSourceEntityId]
	,[strSessionId]
)
SELECT
	 [intItemId]				= ARIC.[intBundleItemId]
	,[intItemLocationId]		= ILOC.intItemLocationId
	,[intItemUOMId]				= dbo.fnGetMatchingItemUOMId(ARIC.[intBundleItemId], ARIC.intItemUnitMeasureId)
	,[dtmDate]					= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]					= ((dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIUOM_STOCK.intItemUOMId, ARID.[dblQtyShipped]) * ARIC.[dblQuantity]) * (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = @ZeroBit THEN -1 ELSE 1 END
	,[dblUOMQty]				= ICIUOM.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE	WHEN dbo.fnGetCostingMethod(ARIC.[intBundleItemId], ILOC.[intItemLocationId]) = @AVERAGECOST THEN 
																							dbo.fnGetItemAverageCost(ARIC.[intBundleItemId], ILOC.[intItemLocationId], ARIC.[intItemUnitMeasureId]) 
																						ELSE 
																							IPP.[dblLastCost]  
																				END 
																				,ARID.[dblSplitPercent]
																		), ICIUOM.[dblUnitQty]
													),@ZeroDecimal)
	,[dblSalesPrice]			= ARID.[dblPrice]
	,[intCurrencyId]			= ARID.[intCurrencyId]
	,[dblExchangeRate]			= ARID.[dblCurrencyExchangeRate]
	,[intTransactionId]			= ARID.[intInvoiceId]
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
	,[strTransactionId]			= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]		= CASE WHEN ARID.strTransactionType = 'Credit Memo' THEN @CREDIT_MEMO_INVOICE_TYPE ELSE @INVENTORY_INVOICE_TYPE END
	,[intLotId]					= NULL 
	,[intSubLocationId]			= ARID.[intSubLocationId]
	,[intStorageLocationId]		= ARID.[intStorageLocationId]
	,[strActualCostId]			= CASE WHEN (ARID.[intDistributionHeaderId] IS NOT NULL OR ARID.[intLoadDistributionHeaderId] IS NOT NULL) THEN ARID.[strActualCostId] ELSE NULL END
	,[intForexRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]				= ARID.[dblCurrencyExchangeRate]
	,[intStorageScheduleTypeId] = ARID.[intStorageScheduleTypeId]
    ,[dblUnitRetail]			= CASE WHEN CAT.ysnRetailValuation = @OneBit THEN ARID.dblPrice ELSE NULL END
	,[intCategoryId]			= ICI.[intCategoryId]
	,[dblAdjustRetailValue]		= CASE WHEN dbo.fnGetCostingMethod(ARIC.[intBundleItemId], ILOC.[intItemLocationId]) = @CATEGORYCOST THEN (ARID.[dblQtyShipped] * ARIC.[dblQuantity]) * ARID.[dblPrice] ELSE NULL END
	,[strType]					= ARID.[strType]
	,[ysnAutoBlend]				= ARID.[ysnAutoBlend]
	,[strBOLNumber]				= ARID.strBOLNumber 
	,[intTicketId]				= ARID.intTicketId
	,[intSourceEntityId]		= ARID.intEntityCustomerId
	,[strSessionId]				= @strSessionId
FROM tblARPostInvoiceDetail ARID
INNER JOIN tblICItemBundle ARIC WITH (NOLOCK) ON ARID.intItemId = ARIC.intItemId
INNER JOIN tblICItemLocation ILOC WITH (NOLOCK) ON ILOC.intItemId = ARIC.intBundleItemId AND ILOC.intLocationId = ARID.intCompanyLocationId
INNER JOIN tblICItem ICI WITH (NOLOCK) ON ARIC.intBundleItemId = ICI.[intItemId]
CROSS APPLY (
     SELECT intItemUOMId 
     FROM tblICItemUOM WITH (NOLOCK)
     WHERE intItemId = ARID.intItemId
     AND ysnStockUnit = 1
 ) ICIUOM_STOCK
LEFT OUTER JOIN tblICItemUOM ICIUOM WITH (NOLOCK) ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
LEFT JOIN tblICCategory CAT ON ICI.intCategoryId = CAT.intCategoryId
LEFT JOIN tblICItemPricing IPP ON IPP.intItemId = ICI.intItemId AND IPP.intItemLocationId = ILOC.intItemLocationId
LEFT OUTER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGL.[intLoadId] = ARID.[intLoadId]				 				 
WHERE (((ARID.[strImportFormat] IS NULL OR ARID.[strImportFormat] <> 'CarQuest') AND (ARID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ARIC.[intBundleItemId], ILOC.[intItemLocationId], ARIC.[intItemUnitMeasureId]) <> 0)) OR ARID.[strImportFormat] = 'CarQuest') 
	AND (
		((ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0) AND (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0) AND  ARID.[strTransactionType] <> 'Credit Memo')
		OR
		(((ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0) OR (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0)) AND ARID.[strTransactionType] = 'Credit Memo')
		)
    AND ARID.[ysnImpactInventory] = 1
	AND ARID.[intItemId] IS NOT NULL
	AND ARIC.[intBundleItemId] IS NOT NULL
	AND ARID.[strTransactionType] <> 'Debit Memo'	
	AND ARID.[strItemType] = 'Bundle'
	AND ICI.[strType] <> 'Non-Inventory'
	AND ARID.[intStorageScheduleTypeId] IS NULL
	AND (ARID.intLoadId IS NULL OR (ARID.intLoadId IS NOT NULL AND LGL.[intPurchaseSale] NOT IN (2, 3)))
	AND ARID.strSessionId = @strSessionId

-- Final Invoice
INSERT INTO tblARPostItemsForCosting
	([intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[strActualCostId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustRetailValue]
	,[strType]
	,[ysnAutoBlend]
	,[strBOLNumber] 
	,[intTicketId]
	,[intSourceEntityId]
	,[strSessionId]
) 
SELECT
	ARIC.[intItemId]
	,ARIC.[intItemLocationId]
	,ARIC.[intItemUOMId]
	,ARIC.[dtmDate]
	,[dblQty] = ARIDP.[dblQtyShipped]
	,ARIC.[dblUOMQty]
	,ARIC.[dblCost]
	,ARIC.[dblSalesPrice]
	,ARIC.[intCurrencyId]
	,ARIC.[dblExchangeRate]
	,ARIC.[intTransactionId]
	,ARIC.[intTransactionDetailId]
	,ARIC.[strTransactionId]
	,ARIC.[intTransactionTypeId]
	,ARIC.[intLotId]
	,ARIC.[intSubLocationId]
	,ARIC.[intStorageLocationId]
	,ARIC.[strActualCostId]
	,ARIC.[intForexRateTypeId]
	,ARIC.[dblForexRate]
	,ARIC.[intStorageScheduleTypeId]
    ,ARIC.[dblUnitRetail]
	,ARIC.[intCategoryId]
	,ARIC.[dblAdjustRetailValue]
	,ARID.[strType]
	,ARID.[ysnAutoBlend]
	,ARID.[strBOLNumber] 
	,ARID.[intTicketId]
	,ARID.[intEntityCustomerId]
	,@strSessionId
FROM tblARPostItemsForCosting ARIC WITH (NOLOCK)
INNER JOIN tblARPostInvoiceDetail ARID ON ARIC.intTransactionDetailId = ARID.intInvoiceDetailId
INNER JOIN tblARInvoiceDetail ARIDP ON ARID.intOriginalInvoiceDetailId = ARIDP.intInvoiceDetailId
WHERE ARID.[intSourceId] = 2
AND ((ARID.[dblQtyShipped] <> ARIDP.[dblQtyShipped] AND ARID.[intInventoryShipmentItemId] IS NULL) OR (ARID.[dblQtyShipped] < ARIDP.[dblQtyShipped] AND ARID.[intInventoryShipmentItemId] IS NOT NULL))
AND ARID.strSessionId = @strSessionId
AND ARIC.strSessionId = @strSessionId

UPDATE IC
SET strSourceType = 'Transport'
  , strSourceNumber	= LH.strTransaction
FROM tblARPostItemsForCosting IC
INNER JOIN tblARPostInvoiceHeader I WITH (NOLOCK) ON IC.intTransactionId = I.intInvoiceId AND IC.strTransactionId = I.strInvoiceNumber
INNER JOIN tblTRLoadDistributionHeader DH WITH (NOLOCK) ON I.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId 
INNER JOIN tblTRLoadHeader LH WITH (NOLOCK) ON DH.intLoadHeaderId = LH.intLoadHeaderId
WHERE IC.strType = 'Transport Delivery'
  AND IC.strSessionId = @strSessionId
  AND I.strSessionId = @strSessionId

RETURN 1