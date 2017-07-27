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
	AND ISNULL(LGL.[intPurchaseSale], 0) NOT IN (2, 3)
																												
	RETURN
END