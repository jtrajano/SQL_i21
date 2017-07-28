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
SELECT
	 [intItemId]					= ICIT.[intItemId]
	,[intItemLocationId]			= ICIT.[intItemLocationId]
	,[intItemUOMId]					= ICIT.[intItemUOMId]
	,[dtmDate]						= ARI.[dtmShipDate]
	,[dblQty]						= -ICIT.[dblQty]
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
	(SELECT [intInvoiceId], [intInvoiceDetailId], [intInventoryShipmentItemId], [dblPrice], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]
INNER JOIN (SELECT [intItemId], [intItemLocationId], [intItemUOMId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [intLotId], [strTransactionId], [intFobPointId],
		[intInTransitSourceLocationId], [ysnIsUnposted]
	FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
		ON ICIT.[intTransactionId] = ICISI.[intInventoryShipmentId] AND ICIT.[intTransactionDetailId] = ICISI.[intInventoryShipmentItemId] AND [ysnIsUnposted] = 0			 
LEFT OUTER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARI.[intLoadId]
WHERE
	ICIT.[intFobPointId] = @FOB_DESTINATION
	AND ISNULL(LGL.[intLoadId], 0) = 0


UNION ALL

SELECT
	 [intItemId]					= ARID.[intItemId]
	,[intItemLocationId]			= IST.[intItemLocationId]
	,[intItemUOMId]					= ARID.[intItemUOMId]
	,[dtmDate]						= ARI.[dtmShipDate]
	,[dblQty]						= (ARID.[dblQtyShipped] * (CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN @Post = 0 THEN -1 ELSE 1 END
	,[dblUOMQty]					= ItemUOM.dblUnitQty
	,[dblCost]						= ISNULL(dbo.fnMultiply (dbo.fnMultiply (	CASE WHEN ISNULL(IST.[strType],'') = 'Finished Good' AND ARID.[ysnBlended] = 1 
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
																		CASE	WHEN dbo.fnGetCostingMethod(ARID.[intItemId], IST.[intItemLocationId]) = @AVERAGECOST THEN 
																					dbo.fnGetItemAverageCost(ARID.[intItemId], IST.[intItemLocationId], ARID.intItemUOMId) 
																				ELSE 
																					IST.[dblLastCost]  
																		END 
																END
																,ARI.[dblSplitPercent])
															,ItemUOM.[dblUnitQty]
														),@ZeroDecimal)
	,[dblValue]						= 0
	,[dblSalesPrice]				= ARID.[dblPrice]
	,[intCurrencyId]				= ARI.[intCurrencyId]
	,[dblExchangeRate]				= ARID.[dblCurrencyExchangeRate]
	,[intTransactionId]				= ARI.[intInvoiceId]
	,[intTransactionDetailId]		= ARID.[intInvoiceDetailId]
	,[strTransactionId]				= ARI.[strInvoiceNumber]
	,[intTransactionTypeId]			= @INVENTORY_INVOICE_TYPE
	,[intLotId]						= ARID.[intLotId]
	,[intSourceTransactionId]		= LGL.[intLoadId]
	,[strSourceTransactionId]		= ARI.[intLoadId]
	,[intSourceTransactionDetailId]	= ARID.[intLoadDetailId]
	,[intFobPointId]				= @FOB_DESTINATION
	,[intInTransitSourceLocationId]	= LGLD.[intSCompanyLocationId]
	,[intForexRateTypeId]			= ARID.[intCurrencyExchangeRateTypeId]
	,[dblForexRate]					= ARID.[dblCurrencyExchangeRate]
FROM 
	(SELECT [intInvoiceId], [intItemId], [intItemUOMId], [dblQtyShipped], [intInvoiceDetailId], [ysnBlended], [intInventoryShipmentItemId], [dblPrice], [intCurrencyExchangeRateTypeId], [dblCurrencyExchangeRate], [intLoadDetailId], [intLotId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN 
	(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [intCurrencyId], [strImportFormat], [intCompanyLocationId], [intDistributionHeaderId], 
		[intLoadDistributionHeaderId], [strActualCostId], [dtmShipDate], [intPeriodsToAccrue], [ysnImpactInventory], [dblSplitPercent], [intLoadId], [intFreightTermId]
	 FROM @Invoices) ARI 
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (SELECT [intLoadId], [intPurchaseSale] FROM tblLGLoad WITH (NOLOCK)) LGL
		ON LGL.[intLoadId] = ARI.[intLoadId]
INNER JOIN
    (SELECT [intLoadId], [intLoadDetailId], [intSCompanyLocationId] FROM tblLGLoadDetail WITH (NOLOCK)) LGLD
		ON LGL.[intLoadId] = ARI.[intLoadId]
		AND LGLD.[intLoadDetailId] = ARID.[intLoadDetailId]
INNER JOIN
	(SELECT [intFreightTermId] FROM tblSMFreightTerms WITH (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ISNULL([strFobPoint],'')))) = UPPER('Destination')) SMFT
		ON ARI.[intFreightTermId] = SMFT.[intFreightTermId]
LEFT OUTER JOIN
	(SELECT [intItemId], [intLocationId], [intItemLocationId], [strType], [dblLastCost] FROM vyuICGetItemStock WITH (NOLOCK)) IST
		ON ARID.[intItemId] = IST.[intItemId]
		AND ARI.[intCompanyLocationId] = IST.[intLocationId]
INNER JOIN
	(SELECT [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH (NOLOCK) ) ItemUOM 
		ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
LEFT OUTER JOIN 
	(SELECT [intInventoryShipmentId], [intInventoryShipmentItemId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI
		ON ARID.[intInventoryShipmentItemId] = ICISI.[intInventoryShipmentItemId]	 
WHERE
	--(
	--	(ISNULL(LGL.[intPurchaseSale], 0) = 3 AND ISNULL(ARID.[intLotId],0) = 0)
	--	OR
	--	(ISNULL(LGL.[intPurchaseSale], 0) = 2)
	--)
	ISNULL(LGL.[intPurchaseSale], 0) IN (2,3)
	AND ISNULL(ICISI.[intInventoryShipmentItemId], 0) = 0
																												
	RETURN
END