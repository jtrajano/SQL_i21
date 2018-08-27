﻿CREATE PROCEDURE [dbo].[uspARPopulateItemsForCosting]

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
	

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000		

--IF(OBJECT_ID('tempdb..#ARItemsForCosting') IS NULL)
--BEGIN
--	CREATE TABLE #ARItemsForCosting
--		([intItemId] INT NOT NULL
--		,[intItemLocationId] INT NULL
--		,[intItemUOMId] INT NOT NULL
--		,[dtmDate] DATETIME NOT NULL
--		,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0
--		,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1
--		,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
--		,[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0 
--		,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
--		,[intCurrencyId] INT NULL
--		,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL
--		,[intTransactionId] INT NOT NULL
--		,[intTransactionDetailId] INT NULL
--		,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
--		,[intTransactionTypeId] INT NOT NULL
--		,[intLotId] INT NULL
--		,[intSubLocationId] INT NULL
--		,[intStorageLocationId] INT NULL
--		,[ysnIsStorage] BIT NULL
--		,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
--		,[intSourceTransactionId] INT NULL
--		,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
--		,[intInTransitSourceLocationId] INT NULL
--		,[intForexRateTypeId] INT NULL
--		,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1
--		,[intStorageScheduleTypeId] INT NULL
--		,[dblUnitRetail] NUMERIC(38, 20) NULL
--		,[intCategoryId] INT NULL 
--		,[dblAdjustCostValue] NUMERIC(38, 20) NULL
--		,[dblAdjustRetailValue] NUMERIC(38, 20) NULL
--	    ,[ysnPost] BIT NULL
--		,[ysnForValidation] BIT NULL)
--END

INSERT INTO #ARItemsForCosting
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
	,[ysnPost]
	,[ysnForValidation]
) 

SELECT 
	 [intItemId]				= ARID.[intItemId] 
	,[intItemLocationId]		= ARID.[intItemLocationId]
	,[intItemUOMId]				= ARID.[intItemUOMId]
	,[dtmDate]					= ARID.[dtmShipDate]
	,[dblQty]					= (CASE WHEN ARIDL.[intLotId] IS NULL THEN ARID.[dblQtyShipped] 
										WHEN LOT.[intWeightUOMId] IS NULL THEN ARIDL.[dblQuantityShipped]
										ELSE dbo.fnMultiply(ARIDL.[dblQuantityShipped], ARIDL.[dblWeightPerQty])
								   END
								* (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = 0 THEN -1 ELSE 1 END
	,[dblUOMQty]				= ARID.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE WHEN ARID.[ysnBlended] = 1 
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
																			AND ICIT.[ysnIsUnposted] = 0
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
															,ARID.[dblUnitQty]
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
	,[strActualCostId]			= CASE WHEN (ISNULL(ARID.[intDistributionHeaderId],0) <> 0 OR ISNULL(ARID.[intLoadDistributionHeaderId],0) <> 0) THEN ARID.[strActualCostId] ELSE NULL END
	,[intForexRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]				= ARID.[dblCurrencyExchangeRate]
	,[intStorageScheduleTypeId] = ARID.[intStorageScheduleTypeId]
    ,[dblUnitRetail]			= NULL
	,[intCategoryId]			= ARID.[intCategoryId]
	,[dblAdjustRetailValue]		= CASE WHEN dbo.fnGetCostingMethod(ARID.[intItemId], ARID.[intItemLocationId]) = @CATEGORYCOST THEN ARID.[dblPrice] ELSE NULL END
	,[ysnPost]					= ARID.[ysnPost]
	,[ysnForValidation]         = 1
FROM
    #ARPostInvoiceDetail ARID
LEFT OUTER JOIN
	(SELECT [intInvoiceDetailId], [intLotId], [dblQuantityShipped], [dblWeightPerQty] FROM tblARInvoiceDetailLot WITH (NOLOCK)) ARIDL
		ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
LEFT OUTER JOIN
	(SELECT [intLotId], [intWeightUOMId], [intStorageLocationId], [intSubLocationId] FROM tblICLot WITH (NOLOCK)) LOT
		ON LOT.[intLotId] = ARIDL.[intLotId]
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARID.[intLoadId]
LEFT OUTER JOIN 
	(SELECT [intTicketId], [intTicketTypeId], [intTicketType], [strInOutFlag] FROM tblSCTicket WITH (NOLOCK)) T 
		ON ARID.intTicketId = T.intTicketId
WHERE
    ARID.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund')
    AND ARID.[intPeriodsToAccrue] <= 1
    AND 1 = CASE WHEN ARID.[strTransactionType] = 'Credit Memo' THEN ARID.[ysnImpactInventory] ELSE 1 END					 				
	AND ((ISNULL(ARID.[strImportFormat], '') <> 'CarQuest' AND (ARID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ARID.[intItemId], ARID.[intItemLocationId], ARID.[intItemUOMId]) <> 0)) OR ISNULL(ARID.[strImportFormat], '') = 'CarQuest') 
	AND (ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0)
	AND (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0)
	AND ARID.[intItemId] IS NOT NULL AND ARID.[intItemId] <> 0
	AND (ISNULL(ARID.[strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment') OR (ARID.[ysnBlended] = 1))
	AND ARID.[strTransactionType] <> 'Debit Memo'							
	AND (ARID.[intStorageScheduleTypeId] IS NULL OR ISNULL(ARID.[intStorageScheduleTypeId],0) = 0)
	AND ISNULL(LGL.[intPurchaseSale], 0) NOT IN (2, 3)
	AND ISNULL(ARID.[strItemType],'') <> 'Finished Good'
	AND (((ISNULL(T.[intTicketTypeId], 0) <> 9 AND (ISNULL(T.[intTicketType], 0) <> 6 OR ISNULL(T.[strInOutFlag], '') <> 'O')) AND ISNULL(ARID.[intTicketId], 0) <> 0) OR ISNULL(ARID.[intTicketId], 0) = 0)
	--AND NOT(ARI.[intLoadDistributionHeaderId] IS NOT NULL AND ISNULL(ARID.[dblPrice], @ZeroDecimal) = 


INSERT INTO #ARItemsForCosting
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
	,[ysnPost]
	,[ysnForValidation]
) 

SELECT 
	 [intItemId]				= ARID.[intItemId] 
	,[intItemLocationId]		= ARID.[intItemLocationId]
	,[intItemUOMId]				= ARID.[intItemUOMId]
	,[dtmDate]					= ARID.[dtmShipDate]
	,[dblQty]					= (CASE WHEN ARIDL.[intLotId] IS NULL THEN ARID.[dblQtyShipped] 
										WHEN LOT.[intWeightUOMId] IS NULL THEN ARIDL.[dblQuantityShipped]
										ELSE dbo.fnMultiply(ARIDL.[dblQuantityShipped], ARIDL.[dblWeightPerQty])
								   END
								* (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = 0 THEN -1 ELSE 1 END
	,[dblUOMQty]				= ARID.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE WHEN ARID.[ysnBlended] = 1 
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
																			AND ICIT.[ysnIsUnposted] = 0
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
															,ARID.[dblUnitQty]
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
	,[strActualCostId]			= CASE WHEN (ISNULL(ARID.[intDistributionHeaderId],0) <> 0 OR ISNULL(ARID.[intLoadDistributionHeaderId],0) <> 0) THEN ARID.[strActualCostId] ELSE NULL END
	,[intForexRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]				= ARID.[dblCurrencyExchangeRate]
	,[intStorageScheduleTypeId] = ARID.[intStorageScheduleTypeId]
    ,[dblUnitRetail]			= NULL
	,[intCategoryId]			= ARID.[intCategoryId]
	,[dblAdjustRetailValue]		= CASE WHEN dbo.fnGetCostingMethod(ARID.[intItemId], ARID.[intItemLocationId]) = @CATEGORYCOST THEN ARID.[dblPrice] ELSE NULL END
	,[ysnPost]					= ARID.[ysnPost]
	,[ysnForValidation]         = 0
FROM
    #ARPostInvoiceDetail ARID
LEFT OUTER JOIN
	(SELECT [intInvoiceDetailId], [intLotId], [dblQuantityShipped], [dblWeightPerQty] FROM tblARInvoiceDetailLot WITH (NOLOCK)) ARIDL
		ON ARIDL.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
LEFT OUTER JOIN
	(SELECT [intLotId], [intWeightUOMId], [intStorageLocationId], [intSubLocationId] FROM tblICLot WITH (NOLOCK)) LOT
		ON LOT.[intLotId] = ARIDL.[intLotId]
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARID.[intLoadId]
LEFT OUTER JOIN 
	(SELECT [intTicketId], [intTicketTypeId], [intTicketType], [strInOutFlag] FROM tblSCTicket WITH (NOLOCK)) T 
		ON ARID.intTicketId = T.intTicketId
WHERE
    ARID.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund')
    AND ARID.[intPeriodsToAccrue] <= 1
    AND 1 = CASE WHEN ARID.[strTransactionType] = 'Credit Memo' THEN ARID.[ysnImpactInventory] ELSE 1 END					 				
	AND ((ISNULL(ARID.[strImportFormat], '') <> 'CarQuest' AND (ARID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ARID.[intItemId], ARID.[intItemLocationId], ARID.[intItemUOMId]) <> 0)) OR ISNULL(ARID.[strImportFormat], '') = 'CarQuest') 
	AND (ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0)
	AND (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0)
	AND ARID.[intItemId] IS NOT NULL AND ARID.[intItemId] <> 0
	AND (ISNULL(ARID.[strItemType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment') OR (ARID.[ysnBlended] = 1))
	AND ARID.[strTransactionType] <> 'Debit Memo'							
	AND (ARID.[intStorageScheduleTypeId] IS NULL OR ISNULL(ARID.[intStorageScheduleTypeId],0) = 0)
	AND ISNULL(LGL.[intPurchaseSale], 0) NOT IN (2, 3)
	--AND ((@ForValidation = 1 AND ISNULL(ARID.[strItemType],'') <> 'Finished Good') OR (@ForValidation = 0))
	AND (((ISNULL(T.[intTicketTypeId], 0) <> 9 AND (ISNULL(T.[intTicketType], 0) <> 6 OR ISNULL(T.[strInOutFlag], '') <> 'O')) AND ISNULL(ARID.[intTicketId], 0) <> 0) OR ISNULL(ARID.[intTicketId], 0) = 0)
	--AND NOT(ARI.[intLoadDistributionHeaderId] IS NOT NULL AND ISNULL(ARID.[dblPrice], @ZeroDecimal) = 

INSERT INTO #ARItemsForCosting
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
	,[ysnPost]
	,[ysnForValidation]
)
SELECT
	 [intItemId]				= ARIC.[intComponentItemId]
	,[intItemLocationId]		= IST.intItemLocationId
	,[intItemUOMId]				= ARIC.[intItemUnitMeasureId] 
	,[dtmDate]					= ARID.[dtmShipDate]
	,[dblQty]					= ((ARID.[dblQtyShipped] * ARIC.[dblQuantity]) * (CASE WHEN ARID.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN ARID.[ysnPost] = 0 THEN -1 ELSE 1 END
	,[dblUOMQty]				= ICIUOM.[dblUnitQty]
	-- If item is using average costing, it must use the average cost. 
	-- Otherwise, it must use the last cost value of the item. 
	,[dblCost]					= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE	WHEN dbo.fnGetCostingMethod(ARIC.[intComponentItemId], IST.[intItemLocationId]) = @AVERAGECOST THEN 
																							dbo.fnGetItemAverageCost(ARIC.[intComponentItemId], IST.[intItemLocationId], ARIC.[intItemUnitMeasureId]) 
																						ELSE 
																							IST.[dblLastCost]  
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
	,[strActualCostId]			= CASE WHEN (ISNULL(ARID.[intDistributionHeaderId],0) <> 0 OR ISNULL(ARID.[intLoadDistributionHeaderId],0) <> 0) THEN ARID.[strActualCostId] ELSE NULL END
	,[intForexRateTypeId]		= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]				= ARID.[dblCurrencyExchangeRate]
	,[intStorageScheduleTypeId] = ARID.[intStorageScheduleTypeId]
    ,[dblUnitRetail]			= CASE WHEN IST.ysnRetailValuation = 1 THEN ARID.dblPrice ELSE NULL END
	,[intCategoryId]			= IST.[intCategoryId]
	,[dblAdjustRetailValue]		= CASE WHEN dbo.fnGetCostingMethod(ARID.[intItemId], IST.[intItemLocationId]) = @CATEGORYCOST THEN ARID.[dblQtyShipped] * ARID.[dblPrice] ELSE NULL END
	,[ysnPost]					= ARID.[ysnPost]
	,[ysnForValidation]         = NULL
FROM
	(SELECT [intComponentItemId], [intItemUnitMeasureId], [intCompanyLocationId],[dblQuantity], [intItemId], [strType] FROM vyuARGetItemComponents WITH (NOLOCK)) ARIC
INNER JOIN
	#ARPostInvoiceDetail ARID
		ON ARIC.[intItemId] = ARID.[intItemId]	
INNER JOIN
	(SELECT [intItemId], [ysnAutoBlend] FROM tblICItem WITH (NOLOCK)) ICI
		ON ARIC.[intComponentItemId] = ICI.[intItemId]
LEFT OUTER JOIN
	(SELECT [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH (NOLOCK)) ICIUOM
		ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
LEFT OUTER JOIN
	(SELECT [intItemId], [intItemLocationId], intLocationId, dblLastCost, [intCategoryId], ysnRetailValuation FROM vyuICGetItemStock WITH (NOLOCK)) IST
		ON ARIC.[intComponentItemId] = IST.[intItemId]
		AND ARID.[intCompanyLocationId] = IST.[intLocationId]	
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARID.[intLoadId]				 				 
WHERE
	((ISNULL(ARID.[strImportFormat], '') <> 'CarQuest' AND (ARID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ARID.[intItemId], IST.[intItemLocationId], ARID.[intItemUOMId]) <> 0)) OR ISNULL(ARID.[strImportFormat], '') = 'CarQuest') 
	AND ISNULL(ARID.[intInventoryShipmentItemId],0) = 0
	AND ISNULL(ARID.[intLoadDetailId],0) = 0
	AND ISNULL(ARID.[intItemId],0) <> 0
	AND ISNULL(ARIC.[intComponentItemId],0) <> 0
	AND ARID.[strTransactionType] <> 'Debit Memo'
	AND ISNULL(ARIC.[strType],'') NOT IN ('Finished Good','Comment')
	AND (ARID.[intStorageScheduleTypeId] IS NULL OR ISNULL(ARID.[intStorageScheduleTypeId],0) = 0)	
	AND ISNULL(LGL.[intPurchaseSale], 0) NOT IN (2, 3)

RETURN 1
