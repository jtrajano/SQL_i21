CREATE PROCEDURE [dbo].[uspARUpdateCommitted]
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @items ItemCostingTableType

	INSERT INTO @items (
		[intItemId]				
		, [intItemLocationId]	
		, [intItemUOMId]			
		, [dtmDate]				
		, [dblQty]				
		, [dblUOMQty]			
		, [dblCost]				
		, [dblValue]				
		, [dblSalesPrice]		
		, [intCurrencyId]		
		, [dblExchangeRate]		
		, [intTransactionId]	
		, [intTransactionDetailId]	
		, [strTransactionId]		
		, [intTransactionTypeId]	
		, [intLotId]				
		, [intSubLocationId]		
		, [intStorageLocationId]		
	)
	--SO shipped
	SELECT [intItemId]				= ARID.[intItemId]
		, [intItemLocationId]		= ARID.[intItemLocationId]
		, [intItemUOMId]			= SOTD.[intItemUOMId]
		, [dtmDate]					= ARID.[dtmDate]
		, [dblQty]					= (CASE WHEN dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) > SOTD.[dblQtyOrdered]
											THEN SOTD.[dblQtyOrdered]
											ELSE dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped])
									END) * CASE WHEN ARID.ysnPost = 1 THEN -1 ELSE 0 END
		, [dblUOMQty]				= ICIUOM.[dblUnitQty]
		, [dblCost]					= ARID.[dblLastCost]
		, [dblValue]				= 0
		, [dblSalesPrice]			= ARID.[dblPrice]
		, [intCurrencyId]			= ARID.[intCurrencyId]
		, [dblExchangeRate]			= 0
		, [intTransactionId]		= ARID.[intInvoiceId]
		, [intTransactionDetailId]	= ARID.[intInvoiceDetailId] 
		, [strTransactionId]		= ARID.[strInvoiceNumber]
		, [intTransactionTypeId]	= 7
		, [intLotId]				= NULL
		, [intSubLocationId]		= SOTD.[intSubLocationId]
		, [intStorageLocationId]	= SOTD.[intStorageLocationId]
	FROM ##ARPostInvoiceDetail ARID
	INNER JOIN tblSOSalesOrderDetail SOTD ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN tblICItemUOM ICIUOM ON ICIUOM.[intItemUOMId] = SOTD.[intItemUOMId]	
	WHERE ARID.strItemType = 'Inventory'
	  AND ARID.[strTransactionType] IN ('Invoice', 'Cash')
	  AND ARID.[intInventoryShipmentItemId] IS NULL
	  AND ARID.[intSalesOrderDetailId] IS NOT NULL
	  AND ARID.[intLoadDetailId] IS NULL

	UNION ALL
	--SO shipped > ordered		--Component
	SELECT [intItemId]				= ARIDC.[intComponentItemId]
		, [intItemLocationId]		= ARID.[intItemLocationId]
		, [intItemUOMId]			= ARIDC.[intItemUOMId]
		, [dtmDate]					= ARID.[dtmDate]
		, [dblQty]					= ((CASE WHEN dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) > SOTD.[dblQtyOrdered]
											THEN SOTD.[dblQtyOrdered]
											ELSE dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped])
									END) * ARIDC.[dblQuantity]) * CASE WHEN ARID.ysnPost = 1 THEN -1 ELSE 0 END
		, [dblUOMQty]				= ARIDC.[dblUnitQuantity] 
		, [dblCost]					= ARID.[dblLastCost]
		, [dblValue]				= 0
		, [dblSalesPrice]			= ARID.[dblPrice]
		, [intCurrencyId]			= ARID.[intCurrencyId]
		, [dblExchangeRate]			= 0
		, [intTransactionId]		= ARID.[intInvoiceId]
		, [intTransactionDetailId]	= ARID.[intInvoiceDetailId] 
		, [strTransactionId]		= ARID.[strInvoiceNumber]
		, [intTransactionTypeId]	= 7
		, [intLotId]				= NULL
		, [intSubLocationId]		= SOTD.[intSubLocationId]
		, [intStorageLocationId]	= SOTD.[intStorageLocationId]
	FROM ##ARPostInvoiceDetail ARID
	INNER JOIN tblARInvoiceDetailComponent ARIDC ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	INNER JOIN tblSOSalesOrderDetail SOTD ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN tblICItem ITEM ON ARIDC.[intComponentItemId] = ITEM.intItemId
	WHERE ITEM.strItemType = 'Inventory'
	  AND ARID.[strTransactionType] IN ('Invoice', 'Cash')
	  AND ARID.[intInventoryShipmentItemId] IS NULL
	  AND ARID.[intSalesOrderDetailId] IS NOT NULL
	  AND ARID.[intLoadDetailId] IS NULL

	IF EXISTS(SELECT TOP 1 NULL FROM @items)
		EXEC uspICIncreaseOrderCommitted @items
	 
END