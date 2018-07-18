CREATE FUNCTION [dbo].[fnARGetItemsForInTransitCosting]
(
	 @Invoices	[dbo].[InvoicePostingTable] READONLY
	,@Post		BIT	= 0
)
RETURNS @returntable TABLE
(
	 [intItemId]							INT					NOT NULL
	,[intItemLocationId]					INT					NULL
	,[intItemUOMId]							INT					NOT NULL
	,[dtmDate]								DATETIME			NOT NULL
	,[dblQty]								NUMERIC(38, 20)		NOT NULL	DEFAULT 0
	,[dblUOMQty]							NUMERIC(38, 20)		NOT NULL	DEFAULT 1
	,[dblCost]								NUMERIC(38, 20)		NOT NULL	DEFAULT 0
	,[dblValue]								NUMERIC(38, 20)		NOT NULL	DEFAULT 0 
	,[dblSalesPrice]						NUMERIC(18, 6)		NOT NULL	DEFAULT 0
	,[intCurrencyId]						INT					NULL
	,[dblExchangeRate]						NUMERIC(38, 20)		NOT NULL	DEFAULT 1
	,[intTransactionId]						INT					NOT NULL
	,[intTransactionDetailId]				INT					NULL
	,[strTransactionId]						NVARCHAR(40)		COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionTypeId]					INT					NOT NULL
	,[intLotId]								INT					NULL
	,[intSourceTransactionId]				INT					NULL
	,[strSourceTransactionId]				NVARCHAR(40)		COLLATE Latin1_General_CI_AS	NULL
	,[intSourceTransactionDetailId]			INT					NULL
	,[intFobPointId]						TINYINT				NULL 
	,[intInTransitSourceLocationId]			INT					NULL 
	,[intForexRateTypeId]					INT					NULL
	,[dblForexRate]							NUMERIC(38, 20)		NULL		DEFAULT 1 
)
AS
BEGIN

DECLARE @FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
DECLARE	@AVERAGECOST AS INT	= 1

SELECT	@INVENTORY_INVOICE_TYPE = [intTransactionTypeId] 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	[strName] = 'Invoice'

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
	,[dblForexRate])
-- FOR Provisional and Standard Invoices From Inventory Shipment
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ARI.[dtmShipDate]
	,[dblQty]						= - ICIT.[dblQty] --ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ARID.[dblQtyShipped]), @ZeroDecimal)  --ICIT.[dblQty]
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
FROM 
	@Invoices ARI 
INNER JOIN 
	(SELECT [intInvoiceId], [intInvoiceDetailId], [intInventoryShipmentItemId], [dblPrice], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate], [intLoadDetailId], [dblQtyShipped], [intItemUOMId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId],
		[intInTransitSourceLocationId], [ysnIsUnposted]
	FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
		ON ICIT.[intTransactionId] = ICISI.[intInventoryShipmentId] AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId] AND [ysnIsUnposted] = 0			 
WHERE
	ICIT.[intFobPointId] IS NOT NULL 
	AND ISNULL(ARID.[intLoadDetailId], 0) = 0
	AND (
			(ARI.[strType] <> 'Provisional' AND (ARI.[intOriginalInvoiceId] IS NULL OR ARI.[intSourceId] <> 2))
		OR
			(ARI.[strType] = 'Provisional' AND ARI.[ysnImpactForProvisional] = 1)
		)
	AND NOT (ARI.[strTransactionType] = 'Credit Note' AND ARI.[intOriginalInvoiceId] IS NOT NULL AND ARID.[intLoadDetailId] IS NOT NULL)

UNION ALL

SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ARI.[dtmShipDate]
	,[dblQty]						= -ICIT.[dblQty] --ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIT.[intItemUOMId], ARID.[dblQtyShipped]), @ZeroDecimal) --
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
FROM 
	(SELECT [intInvoiceId], [intItemId], [intItemUOMId], [dblQtyShipped], [intInvoiceDetailId], [ysnBlended], [intInventoryShipmentItemId], [dblPrice], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate], [intLoadDetailId], [intLotId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN 
	(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [intCurrencyId], [strImportFormat], [intCompanyLocationId], [intDistributionHeaderId], [intOriginalInvoiceId], [intSourceId],
		[intLoadDistributionHeaderId], [strActualCostId], [dtmShipDate], [intPeriodsToAccrue], [ysnImpactInventory], [dblSplitPercent], [intLoadId], [intFreightTermId]
	 FROM @Invoices INV
	 WHERE
		((INV.[strType] <> 'Provisional' AND (INV.[intOriginalInvoiceId] IS NULL OR INV.[intSourceId] <> 2))
			OR
		(INV.[strType] = 'Provisional' AND INV.[ysnImpactForProvisional] = 1)
		)		
			) ARI 
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (SELECT [intLoadId], [intLoadDetailId], [intSCompanyLocationId] FROM tblLGLoadDetail WITH (NOLOCK)) LGLD
		ON ARID.[intLoadDetailId] = LGLD.[intLoadDetailId] 
INNER JOIN
    (SELECT [intLoadId], [intPurchaseSale], [strLoadNumber] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGLD.[intLoadId] = LGL.[intLoadId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId],
		[intInTransitSourceLocationId], [ysnIsUnposted]
	FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
		ON ICIT.[intTransactionId] = LGL.[intLoadId] AND ICIT.[intTransactionDetailId] = LGLD.[intLoadDetailId] AND ICIT.[ysnIsUnposted] = 0
		AND ICIT.[strTransactionId] = LGL.[strLoadNumber] 			 
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]	
WHERE
	ICIT.[intFobPointId] IS NOT NULL 
	AND ISNULL(LGL.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICISI.[intInventoryShipmentItemId], 0) = 0
	AND NOT (ARI.[strTransactionType] = 'Credit Note' AND ARI.[intOriginalInvoiceId] IS NOT NULL AND ARID.[intLoadDetailId] IS NOT NULL)

										
	RETURN
END