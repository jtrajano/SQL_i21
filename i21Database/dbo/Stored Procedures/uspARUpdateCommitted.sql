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

	IF (@InvoiceId IS NULL)
		BEGIN
			SET @Negate = 0
		END
	ELSE
		BEGIN
			SET @Negate = 1
		END

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
	----DIRECT
	----Quantity/UOM Changed
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType] 
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND (ARID.[intItemUOMId] <> ARTD.[intItemUOMId] OR ARID.[dblQtyShipped] <> dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped]))
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0


	--UNION ALL

	----Quantity/UOM Changed -- Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])) * ARIDC.[dblQuantity]
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType] 
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND (ARID.[intItemUOMId] <> ARTD.[intItemUOMId] OR (ARID.[dblQtyShipped] * ARIDC.[dblQuantity]) <> (dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped]) * ARIDC.[dblQuantity]))
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0
				
	--UNION ALL

	----Item Changed -old
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARTD.[dblQtyShipped] * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARTD.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARTD.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0		


	--UNION ALL

	----Item Changed -old -- Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARTD.[dblQtyShipped] * ARIDC.[dblQuantity]) * -1
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0		
	
	--UNION ALL

	----Item Changed +new
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped]
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0

	--UNION ALL

	----Item Changed +new  --Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] * ARIDC.[dblQuantity] 
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0

	--UNION ALL

	----Added Item
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped]
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intInvoiceDetailId] NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = ARI.[strTransactionType])	
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0	


	--UNION ALL

	----Added Item --Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] * ARIDC.[dblQuantity] 
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity]  
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intInvoiceDetailId] NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = ARI.[strTransactionType])	
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0	

	--UNION ALL

	----Deleted Item
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARTD.[dblQtyShipped] * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARTransactionDetail ARTD
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARTD.[intTransactionId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARTD.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARTD.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARTD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)	
	--	AND ISNULL(ARTD.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARTD.[intSalesOrderDetailId], 0) = 0


	--UNION ALL

	----Deleted Item	--Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARTD.[dblQtyShipped] * ARIDC.[dblQuantity]) * -1
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARTransactionDetail ARTD
	--		ON ARIDC.[intInvoiceDetailId] = ARTD.intTransactionDetailId
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARTD.[intTransactionId] = ARI.[intInvoiceId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARTD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)	
	--	AND ISNULL(ARTD.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARTD.[intSalesOrderDetailId], 0) = 0
		
	--UNION ALL
	
	--SO/IS
	--Quantity & UOM Changed ++
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped]) - (ARTD.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered]))
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = 'Invoice'
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND ARID.[intItemUOMId] <> ARTD.[intItemUOMId] 
	--	AND ARID.[dblQtyShipped] <> dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])
	--	AND ARID.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARID.[intItemUOMId], SOTD.[dblQtyOrdered]) 
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)
		
	--UNION ALL
	
	--Quantity++
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARID.[intItemUOMId], SOTD.[dblQtyOrdered])
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = 'Invoice'
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND ARID.[intItemUOMId] = ARTD.[intItemUOMId] 
	--	AND ARID.[dblQtyShipped] <> ARTD.[dblQtyShipped]
	--	AND ARID.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARID.[intItemUOMId], SOTD.[dblQtyOrdered]) 
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)
		
	--UNION ALL
	
	--Quantity/UOM Changed --
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARTD.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered])) * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = 'Invoice'
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND ARID.[intItemUOMId] <> ARTD.[intItemUOMId] 
	--	AND ARID.[dblQtyShipped] <> dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])
	--	AND ARTD.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered]) 
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)
		
	--UNION ALL
	
	--Quantity --
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARTD.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered])) * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId] 
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = 'Invoice'
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARID.[intItemId] = ARTD.[intItemId]		
	--	AND ARID.[intItemUOMId] = ARTD.[intItemUOMId] 
	--	AND ARID.[dblQtyShipped] <> ARTD.[dblQtyShipped]
	--	AND ARTD.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered]) 
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)
		
	--UNION ALL

	--Item Changed -old
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(ARTD.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered])) * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = 'Invoice'
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARTD.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 			
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARTD.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARID.[intItemId] <> ARTD.[intItemId]	
	--	AND ARTD.[dblQtyShipped] > dbo.fnCalculateQtyBetweenUOM(SOTD.[intItemUOMId], ARTD.[intItemUOMId], SOTD.[dblQtyOrdered])
	--	AND (ISNULL(ARTD.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARTD.[intSalesOrderDetailId], 0) <> 0)		
	
	--UNION ALL

	----Item Changed +new
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped]
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)							

	--UNION ALL

	----Item Changed +new		--Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] * ARIDC.[dblQuantity] 
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblARTransactionDetail ARTD
	--		ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
	--		AND ARID.[intInvoiceId] = ARTD.[intTransactionId] 
	--		AND ARTD.[strTransactionType] = ARI.[strTransactionType]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ARID.[intItemId] <> ARTD.[intItemId]		
	--	AND (ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0)							

	--UNION ALL

	----Deleted Item
	--SELECT
	--	[intItemId]					=	ARTD.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARTD.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	(dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], SOTD.[intItemUOMId], ARTD.[dblQtyShipped]) - SOTD.[dblQtyOrdered]) * -1
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARTD.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARTD.intTransactionDetailId
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARTransactionDetail ARTD
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARTD.[intTransactionId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblSOSalesOrderDetail SOTD
	--		ON ARTD.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 			
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARTD.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARTD.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 0
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] = 'Invoice'
	--	AND ARTD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)	
	--	AND dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], SOTD.[intItemUOMId], ARTD.[dblQtyShipped]) > SOTD.[dblQtyOrdered] 	
	--	AND (ISNULL(ARTD.[intInventoryShipmentItemId], 0) <> 0 OR ISNULL(ARTD.[intSalesOrderDetailId], 0) <> 0)		
	
	--UNION ALL

	--POSTING
	----Direct
	--SELECT
	--	[intItemId]					=	ARID.[intItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARID.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped]
	--	,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetail ARID
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--INNER JOIN
	--	tblICItemUOM ICIUOM 
	--		ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARID.[intItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 1
	--	AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0	
		
	--UNION ALL

	----Direct	--Component
	--SELECT
	--	[intItemId]					=	ARIDC.[intComponentItemId]
	--	,[intItemLocationId]		=	ICGIS.[intItemLocationId]
	--	,[intItemUOMId]				=	ARIDC.[intItemUOMId]
	--	,[dtmDate]					=	ARI.[dtmDate]
	--	,[dblQty]					=	ARID.[dblQtyShipped] * ARIDC.[dblQuantity] 
	--	,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
	--	,[dblCost]					=	ICGIS.[dblLastCost]
	--	,[dblValue]					=	0
	--	,[dblSalesPrice]			=	ARID.[dblPrice]
	--	,[intCurrencyId]			=	ARI.[intCurrencyId]
	--	,[dblExchangeRate]			=	0
	--	,[intTransactionId]			=	ARI.[intInvoiceId]
	--	,[intTransactionDetailId]	=	ARID.[intInvoiceDetailId]
	--	,[strTransactionId]			=	ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]		=	7
	--	,[intLotId]					=	NULL
	--	,[intSubLocationId]			=	NULL
	--	,[intStorageLocationId]		=	NULL
	--FROM 
	--	tblARInvoiceDetailComponent ARIDC
	--INNER JOIN 
	--	tblARInvoiceDetail ARID
	--		ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	--INNER JOIN
	--	tblARInvoice ARI
	--		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	--LEFT OUTER JOIN
	--	vyuICGetItemStock ICGIS
	--		ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
	--		AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	--WHERE 
	--	ISNULL(@FromPosting,0) = 1
	--	AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
	--	AND ARI.[intInvoiceId] = @InvoiceId
	--	AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
	--	AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	--	AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0	
		
	
	--UNION ALL
	
	--SO shipped
	SELECT
		[intItemId]					=	ARID.[intItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	SOTD.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	
										--(CASE
										--	WHEN dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) > SOTD.[dblQtyOrdered] AND @Negate = 0 
										--		THEN  
													SOTD.[dblQtyOrdered]
										--	ELSE
										--		dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped])
										--END)
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
	WHERE 
		ISNULL(@FromPosting,0) = 1
		AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
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
		,[dblQty]					=	
										--(CASE
										--	WHEN dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) > SOTD.[dblQtyOrdered] AND @Negate = 0 
										--		THEN  
													SOTD.[dblQtyOrdered]
										--	ELSE
										--		dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped])
										--END) 
											* ARIDC.[dblQuantity] 
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
	WHERE 
		ISNULL(@FromPosting,0) = 1
		AND [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
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