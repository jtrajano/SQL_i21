CREATE FUNCTION [dbo].[fnARGetItemsForStoragePosting]
(
	 @Invoices	[dbo].[InvoicePostingTable] READONLY
	,@Post		BIT	= 0
)
RETURNS @returntable TABLE
(
	 [intItemId]						INT											NOT NULL
	,[intItemLocationId]				INT											NULL
	,[intItemUOMId]						INT											NOT NULL
	,[dtmDate]							DATETIME									NOT NULL
	,[dblQty]							NUMERIC(38, 20)								NOT NULL DEFAULT 0
	,[dblUOMQty]						NUMERIC(38, 20)								NOT NULL DEFAULT 1
	,[dblCost]							NUMERIC(38, 20)								NOT NULL DEFAULT 0
	,[dblValue]							NUMERIC(38, 20)								NOT NULL DEFAULT 0
	,[dblSalesPrice]					NUMERIC(18, 6)								NOT NULL DEFAULT 0
	,[intCurrencyId]					INT											NULL
	,[dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1					NOT NULL
	,[intTransactionId]					INT											NOT NULL
	,[intTransactionDetailId]			INT											NULL
	,[strTransactionId]					NVARCHAR(40) COLLATE Latin1_General_CI_AS	NOT NULL
	,[intTransactionTypeId]				INT											NOT NULL
	,[intLotId]							INT											NULL
	,[intSubLocationId]					INT											NULL
	,[intStorageLocationId]				INT											NULL
	,[ysnIsStorage]						BIT											NULL
	,[strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL
	,[intSourceTransactionId]			INT NULL
	,[strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS	NULL
	,[intInTransitSourceLocationId]		INT											NULL
	,[intForexRateTypeId]				INT											NULL
	,[dblForexRate]						NUMERIC(38, 20)								NULL DEFAULT 1
)
AS
BEGIN

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33

SELECT	@INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	[strName] = 'Invoice'

DECLARE	@AVERAGECOST AS INT	= 1

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000			

INSERT INTO @returntable
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
	 [intItemId]					= ARID.[intItemId]  
	,[intItemLocationId]			= IST.[intItemLocationId]
	,[intItemUOMId]				= ARID.[intItemUOMId]
	,[dtmDate]					= ARI.[dtmShipDate]
	,[dblQty]						= (ARID.[dblQtyShipped] * (CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN @Post = 0 THEN -1 ELSE 1 END
	,[dblUOMQty]					= ItemUOM.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (	CASE WHEN ARID.[ysnBlended] = 1 
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
																		AND ICIT.[ysnIsUnposted] = 0
																		AND ICIT.[strTransactionForm] = 'Produce'
																)
																ELSE
																	CASE	WHEN dbo.fnGetCostingMethod(ARID.[intItemId], IST.[intItemLocationId]) = @AVERAGECOST THEN 
																				dbo.fnGetItemAverageCost(ARID.[intItemId], IST.[intItemLocationId], ARID.[intItemUOMId]) 
																			ELSE 
																				IST.[dblLastCost]
																	END 
															END
															,ItemUOM.[dblUnitQty]
														),@ZeroDecimal)
	,[dblSalesPrice]				= ARID.[dblPrice] 
	,[intCurrencyId]				= ARI.[intCurrencyId]
	,[dblExchangeRate]			= 1.00
	,[intTransactionId]			= ARI.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]			= ARI.[strInvoiceNumber] 
	,[intTransactionTypeId]		= @INVENTORY_INVOICE_TYPE
	,[intLotId]					= NULL 
	,[intSubLocationId]			= ARID.[intCompanyLocationSubLocationId]
	,[intStorageLocationId]		= ARID.[intStorageLocationId]
	,[strActualCostId]			= CASE WHEN (ISNULL(ARI.[intDistributionHeaderId],0) <> 0 OR ISNULL(ARI.[intLoadDistributionHeaderId],0) <> 0) THEN ARI.[strActualCostId] ELSE NULL END
FROM 
	(SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [intItemUOMId], [dblQtyShipped], [ysnBlended], [dblPrice], [intCompanyLocationSubLocationId], 
		[intStorageLocationId], [dblTotal], [intInventoryShipmentItemId], [intLoadDetailId], [intStorageScheduleTypeId]
	 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [dtmShipDate], [intCurrencyId], [intDistributionHeaderId], [intLoadDistributionHeaderId], [strActualCostId], [intCompanyLocationId],
		[strImportFormat], [ysnImpactInventory], [intPeriodsToAccrue], [intLoadId]
	 FROM @Invoices) ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId] AND [strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund') AND ISNULL([intPeriodsToAccrue],0) <= 1 
			AND 1 = CASE WHEN [strTransactionType] = 'Credit Memo' THEN [ysnImpactInventory] ELSE 1 END
INNER JOIN
	(SELECT [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH (NOLOCK) ) ItemUOM 
		ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
LEFT OUTER JOIN
	(SELECT [intItemId], [intLocationId], [strType], [intItemLocationId], [dblLastCost] FROM vyuICGetItemStock WITH (NOLOCK) ) IST
		ON ARID.[intItemId] = IST.[intItemId] 
		AND ARI.[intCompanyLocationId] = IST.[intLocationId]
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARI.[intLoadId]
WHERE				
	((ISNULL(ARI.[strImportFormat], '') <> 'CarQuest' AND (ARID.[dblTotal] <> 0 OR ARID.[dblQtyShipped] <> 0)) OR ISNULL(ARI.[strImportFormat], '') = 'CarQuest') 
	AND (ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0)
	AND (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0)
	AND ARID.[intItemId] IS NOT NULL AND ARID.[intItemId] <> 0
	AND (ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle') OR (ARID.[ysnBlended] = 1))
	AND ARI.[strTransactionType] <> 'Debit Memo'
	--AND ( ARID.[intStorageScheduleTypeId] IS NULL OR (ARID.[intStorageScheduleTypeId] IS NOT NULL AND ISNULL(ARID.[intStorageScheduleTypeId],0) <> 0) )
	AND (ARID.[intStorageScheduleTypeId] IS NOT NULL AND ISNULL(ARID.[intStorageScheduleTypeId],0) <> 0)
	AND ISNULL(LGL.[intPurchaseSale], 0) NOT IN (2, 3)
																												
	RETURN
END