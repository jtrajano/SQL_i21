CREATE PROCEDURE [dbo].[uspARUpdateCommitted]
	@InvoiceId		INT
	,@Negate		BIT	= 0
	,@UserId		INT = NULL
	,@FromPosting	BIT = 0     
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
		,[intSubLocationId]		
		,[intStorageLocationId]		
	)
	SELECT
		[intItemId]					=	ARID.[intItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	ARID.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	ARID.[dblQtyShipped]										
		,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
		,[dblCost]					=	ICGIS.[dblLastCost]
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARID.[dblPrice]
		,[intCurrencyId]			=	ARI.[intCurrencyId]
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.[intInvoiceId]
		,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
		,[strTransactionId]			=	ARI.[strInvoiceNumber]
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	ARID.[intSubLocationId]
		,[intStorageLocationId]		=	ARID.[intStorageLocationId]
	FROM 
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]	
	INNER JOIN
		tblICItemUOM ICIUOM 
			ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]	
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARID.[intItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0

	UNION ALL

	SELECT
		[intItemId]					=	ARID.[intItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	SOTD.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	SOTD.[dblQtyOrdered]										
		,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
		,[dblCost]					=	ICGIS.[dblLastCost]
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARID.[dblPrice]
		,[intCurrencyId]			=	ARI.[intCurrencyId]
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.[intInvoiceId]
		,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
		,[strTransactionId]			=	ARI.[strInvoiceNumber]
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	SOTD.[intSubLocationId]
		,[intStorageLocationId]		=	SOTD.[intStorageLocationId]
	FROM 
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		tblSOSalesOrderDetail SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN
		tblICItemUOM ICIUOM 
			ON ICIUOM.[intItemUOMId] = SOTD.[intItemUOMId]	
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON SOTD.[intItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0

	UNION ALL
	--SO shipped > ordered		--Component
	SELECT
		[intItemId]					=	ARIDC.[intComponentItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	ARIDC.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	SOTD.[dblQtyOrdered] * ARIDC.[dblQuantity] 
		,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
		,[dblCost]					=	ICGIS.[dblLastCost]
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARID.[dblPrice]
		,[intCurrencyId]			=	ARI.[intCurrencyId]
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.[intInvoiceId]
		,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
		,[strTransactionId]			=	ARI.[strInvoiceNumber]
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	SOTD.[intSubLocationId]
		,[intStorageLocationId]		=	SOTD.[intStorageLocationId]
	FROM 
		tblARInvoiceDetailComponent ARIDC
	INNER JOIN 
		tblARInvoiceDetail ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		tblSOSalesOrderDetail SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
				
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)		

	EXEC uspICIncreaseOrderCommitted @items
	 
END

GO