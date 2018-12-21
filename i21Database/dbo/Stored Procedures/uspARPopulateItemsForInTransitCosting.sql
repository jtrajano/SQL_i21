CREATE PROCEDURE [dbo].[uspARPopulateItemsForInTransitCosting]

AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
DECLARE	@AVERAGECOST AS INT	= 1

SELECT	@INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	[strName] = 'Invoice'

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000			

--IF(OBJECT_ID('tempdb..#ARItemsForInTransitCosting') IS NOT NULL)
--BEGIN
--	CREATE TABLE #ARItemsForInTransitCosting
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
--		,[ysnPost] BIT NULL)
--END

INSERT INTO #ARItemsForInTransitCosting
	([intItemId] 
	,[intItemLocationId] 
	,[intItemUOMId] 
	,[dtmDate] 
	,[dblQty] 
	,[dblUOMQty] 
	,[dblCost] 
	,[dblValue] 
	,[dblSalesPrice] 
	,[intCurrencyId] 
	,[dblExchangeRate] 
	,[intTransactionId] 
	,[intTransactionDetailId] 
	,[strTransactionId] 
	,[intTransactionTypeId] 
	,[intLotId] 
	,[intSourceTransactionId] 
	,[strSourceTransactionId] 
	,[intSourceTransactionDetailId] 
	,[intFobPointId] 
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intLinkedItem])
-- FOR Provisional and Standard Invoices From Inventory Shipment
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= - ICIT.[dblQty] --ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ARID.[dblQtyShipped]), @ZeroDecimal)  --ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
FROM 
	#ARPostInvoiceDetail ARID
INNER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId], intChildItemLinkId  FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
INNER JOIN
	(SELECT [intInventoryShipmentId], [strShipmentNumber] FROM tblICInventoryShipment) ICIS
		ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId], [intInTransitSourceLocationId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)
			WHERE ISNULL([intInTransitSourceLocationId], 0) <> 0 ) ICIT
		ON ICIT.[intTransactionId] = ICISI.[intInventoryShipmentId] 
		AND ICIS.[strShipmentNumber] = ICIT.[strTransactionId]
		AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId]
		AND ARID.[intItemId] = ICIT.[intItemId]
		AND [ysnIsUnposted] = 0			 
WHERE
	--ICIT.[intFobPointId] IS NOT NULL AND 
	ISNULL(ARID.[intLoadDetailId], 0) = 0
	AND (
			(ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0)
		OR
			(ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1)
		)
	AND NOT (ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') AND ARID.[intOriginalInvoiceId] IS NOT NULL AND ARID.[intLoadDetailId] IS NOT NULL)


UNION ALL

SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= -ICIT.[dblQty] --ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ARID.[dblQtyShipped]), @ZeroDecimal) --
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
FROM 
	#ARPostInvoiceDetail ARID
INNER JOIN
    (SELECT [intLoadId], [intLoadDetailId], [intSCompanyLocationId] FROM tblLGLoadDetail WITH (NOLOCK)) LGLD
		ON ARID.[intLoadDetailId] = LGLD.[intLoadDetailId] 
INNER JOIN
    (SELECT [intLoadId], [intPurchaseSale], [strLoadNumber] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGLD.[intLoadId] = LGL.[intLoadId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId],
		[intInTransitSourceLocationId], [ysnIsUnposted]
	FROM tblICInventoryTransaction WITH (NOLOCK)
	WHERE ISNULL([intInTransitSourceLocationId], 0) <> 0) ICIT
		ON ICIT.[intTransactionId] = LGL.[intLoadId] 
		AND ICIT.[intTransactionDetailId] = LGLD.[intLoadDetailId] 
		AND ICIT.[strTransactionId] = LGL.[strLoadNumber] 			 
		AND ARID.[intItemId] = ICIT.[intItemId]
		AND ICIT.[ysnIsUnposted] = 0		
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId], [intChildItemLinkId]  FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]	
WHERE
	--ICIT.[intFobPointId] IS NOT NULL AND 
	(
		(ARID.[strType] <> 'Provisional' AND ARID.[ysnFromProvisional] = 0)
	OR
		(ARID.[strType] = 'Provisional' AND ARID.[ysnProvisionalWithGL] = 1)
	)
	AND ISNULL(LGL.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICISI.[intInventoryShipmentItemId], 0) = 0
	AND NOT (ARID.[strTransactionType] IN ('Credit Memo', 'Credit Note') AND ARID.[intOriginalInvoiceId] IS NOT NULL AND ARID.[intLoadDetailId] IS NOT NULL)

UNION ALL
-- FOR Credit Note Reversal
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARID.[dtmPostDate], ARID.[dtmShipDate])
	,[dblQty]						= ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARID.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARID.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARID.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
FROM 
	#ARPostInvoiceDetail ARID
INNER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId], [intChildItemLinkId]  FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
INNER JOIN
	(SELECT [intInventoryShipmentId], [strShipmentNumber] FROM tblICInventoryShipment) ICIS
		ON ICISI.[intInventoryShipmentId] = ICIS.[intInventoryShipmentId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId], [intInTransitSourceLocationId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
		ON ICIT.[intTransactionId] = ICISI.[intInventoryShipmentId] 
		AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId] 
		AND ICIS.[strShipmentNumber] = ICIT.[strTransactionId]
		AND ARID.[intItemId] = ICIT.[intItemId]
		AND [ysnIsUnposted] = 0			 
WHERE
	(ARID.[strTransactionType] = 'Credit Note' OR (ARID.[strTransactionType] = 'Credit Memo' AND ARID.[ysnFromProvisional] = 0))
	AND ICIT.[intFobPointId] = @FOB_DESTINATION
	AND ISNULL(ARID.[intLoadDetailId], 0) = 0
	AND ARID.[intOriginalInvoiceId] IS NOT NULL 
	AND ARID.[intOriginalInvoiceId] <> 0


UNION ALL

SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ISNULL(ARI.[dtmPostDate], ARI.[dtmShipDate])
	,[dblQty]						= ICIT.[dblQty]
	,[dblUOMQty]					= ICIT.[dblUOMQty]
	,[dblCost]						= ICIT.[dblCost]
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARI.[intCurrencyId]
	,[dblExchangeRate]				= 1.00
	,[intTransactionId]				= ARI.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARI.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ICIT.[intLotId]
	,[intSourceTransactionId]		= ICIT.[intTransactionId]
	,[strSourceTransactionId]		= ICIT.[strTransactionId]
	,[intSourceTransactionDetailId]	= ICIT.[intTransactionDetailId]
	,[intFobPointId]				= ICIT.[intFobPointId]
	,[intInTransitSourceLocationId]	= ICIT.[intInTransitSourceLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
	,[intLinkedItem]				= ICISI.intChildItemLinkId
FROM 
	(SELECT [intInvoiceId], [intItemId], [intItemUOMId], [dblQtyShipped], [intInvoiceDetailId], [ysnBlended], [intInventoryShipmentItemId], [dblPrice], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate], [intLoadDetailId], [intLotId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN 
	(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [intCurrencyId], [strImportFormat], [intCompanyLocationId], [intDistributionHeaderId], 
		[intLoadDistributionHeaderId], [strActualCostId], [dtmPostDate], [dtmShipDate], [intPeriodsToAccrue], [ysnImpactInventory], [dblSplitPercent], [intLoadId], [intFreightTermId], [intOriginalInvoiceId], [strInvoiceOriginId]
	 FROM #ARPostInvoiceHeader INV
	 WHERE
		(INV.[strTransactionType] = 'Credit Note' OR (INV.[strTransactionType] = 'Credit Memo' AND INV.[ysnFromProvisional] = 0))
		AND INV.[intOriginalInvoiceId] IS NOT NULL 
		AND INV.[intOriginalInvoiceId] <> 0
			) ARI 
			ON ARID.[intInvoiceId] = ARI.[intOriginalInvoiceId]
INNER JOIN
    (SELECT [intLoadId], [intLoadDetailId], [intSCompanyLocationId] FROM tblLGLoadDetail WITH (NOLOCK)) LGLD
		ON ARID.[intLoadDetailId] = LGLD.[intLoadDetailId] 
INNER JOIN
    (SELECT [intLoadId], [intPurchaseSale], [strLoadNumber] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGLD.[intLoadId] = LGL.[intLoadId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId],
		[intInTransitSourceLocationId], [ysnIsUnposted]
	FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
		ON ICIT.[intTransactionId] = LGL.[intLoadId] 
		AND ICIT.[intTransactionDetailId] = LGLD.[intLoadDetailId] 
		AND ICIT.[strTransactionId] = LGL.[strLoadNumber] 			 
		AND ARID.[intItemId] = ICIT.[intItemId]
		AND ICIT.[ysnIsUnposted] = 0		 
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId], [intChildItemLinkId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]	
WHERE
	ICIT.[intFobPointId] = @FOB_DESTINATION
	AND ISNULL(LGL.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICISI.[intInventoryShipmentItemId], 0) = 0

UPDATE 
	A 
		Set [intLinkedItemId] = B.intItemId
	From 
	#ARItemsForInTransitCosting A
		join tblICInventoryShipmentItem B
			on A.intLinkedItem = B.intParentItemLinkId
	where A.intLinkedItem is not null



RETURN 1
