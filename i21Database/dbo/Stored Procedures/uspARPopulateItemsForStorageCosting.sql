CREATE PROCEDURE [dbo].[uspARPopulateItemsForStorageCosting]
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
SELECT	@INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	[strName] = 'Invoice'

DECLARE @CREDIT_MEMO_INVOICE_TYPE AS INT = 45
SELECT	@CREDIT_MEMO_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	strName = 'Credit Memo'

DECLARE	@AVERAGECOST AS INT	= 1

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000		
DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)	
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)

INSERT INTO ##ARItemsForStorageCosting
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
) 
SELECT 
	 [intItemId]				= ARID.[intItemId]  
	,[intItemLocationId]		= ARID.[intItemLocationId]
	,[intItemUOMId]				= ARID.[intItemUOMId]
	,[dtmDate]					= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]					= (ARID.[dblQtyShipped] * (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = @ZeroBit THEN -1 ELSE 1 END
	,[dblUOMQty]				= ARID.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (	CASE WHEN ARID.[ysnBlended] = @OneBit 
																THEN (
																	SELECT SUM(ICIT.[dblCost]) 
																	FROM
																		(SELECT [intTransactionId], [strTransactionId], [dblCost], [ysnIsUnposted], [strTransactionForm] FROM tblICInventoryTransaction WITH (NOLOCK))ICIT
																	INNER JOIN
																		(SELECT [intWorkOrderId], [strWorkOrderNo], [intBatchID] FROM tblMFWorkOrder WITH (NOLOCK)) MFWO
																			ON ICIT.[strTransactionId] = MFWO.[strWorkOrderNo]
																			AND ICIT.[intTransactionId] = MFWO.[intBatchID] 
																	WHERE
																		MFWO.[intWorkOrderId] = (SELECT MAX(tblMFWorkOrder.[intWorkOrderId]) FROM tblMFWorkOrder WITH (NOLOCK) WHERE tblMFWorkOrder.[intInvoiceDetailId] = ARID.[intInvoiceDetailId])
																		AND ICIT.[ysnIsUnposted] = @ZeroBit
																		AND ICIT.[strTransactionForm] = 'Produce'
																)
																ELSE
																	CASE	WHEN dbo.fnGetCostingMethod(ARID.[intItemId], ARID.[intItemLocationId]) = @AVERAGECOST THEN 
																				dbo.fnGetItemAverageCost(ARID.[intItemId], ARID.[intItemLocationId], ARID.[intItemUOMId]) 
																			ELSE 
																				ARID.[dblLastCost]
																	END 
															END
															,ARID.[dblUnitQty]
														),@ZeroDecimal)
	,[dblSalesPrice]			= ARID.[dblPrice] 
	,[intCurrencyId]			= ARID.[intCurrencyId]
	,[dblExchangeRate]			= 1.00
	,[intTransactionId]			= ARID.[intInvoiceId]
	,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
	,[strTransactionId]			= ARID.[strInvoiceNumber] 
	,[intTransactionTypeId]		= CASE WHEN ARID.strTransactionType = 'Credit Memo' THEN @CREDIT_MEMO_INVOICE_TYPE ELSE @INVENTORY_INVOICE_TYPE END
	,[intLotId]					= NULL 
	,[intSubLocationId]			= ARID.[intSubLocationId]
	,[intStorageLocationId]		= ARID.[intStorageLocationId]
	,[strActualCostId]			= CASE WHEN (ISNULL(ARID.[intDistributionHeaderId],0) <> 0 OR ISNULL(ARID.[intLoadDistributionHeaderId],0) <> 0) THEN ARID.[strActualCostId] ELSE NULL END
FROM ##ARPostInvoiceDetail ARID
LEFT OUTER JOIN tblLGLoad LGL WITH (NOLOCK) ON LGL.[intLoadId] = ARID.[intLoadId]
WHERE ARID.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund') 
  AND ARID.[intPeriodsToAccrue] <= 1 
  AND ARID.[ysnImpactInventory] = @OneBit			
  AND (((ARID.[strImportFormat] IS NULL OR ARID.[strImportFormat] <> 'CarQuest') AND (ARID.[dblTotal] <> 0 OR ARID.[dblQtyShipped] <> 0)) OR ARID.[strImportFormat] = 'CarQuest') 
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[intLoadDetailId] IS NULL
  AND ARID.[intItemId] IS NOT NULL
  AND (ARID.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle') OR (ARID.[ysnBlended] = @OneBit))
  AND ARID.[strTransactionType] <> 'Debit Memo'
  AND ARID.[intStorageScheduleTypeId] IS NOT NULL
  AND LGL.[intPurchaseSale] NOT IN (2, 3)

RETURN 1
