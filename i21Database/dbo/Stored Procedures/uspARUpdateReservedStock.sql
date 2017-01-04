CREATE PROCEDURE [dbo].[uspARUpdateReservedStock]
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

	DECLARE @TransactionTypeId AS INT = 33
	SELECT @TransactionTypeId = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WHERE [strName] = 'Invoice'
	DECLARE @items ItemReservationTableType

	INSERT INTO @items (
												--[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	 [intItemId]								--INT NOT NULL					-- The item. 
	,[intItemLocationId]						--INT NOT NULL			-- The location where the item is stored.
	,[intItemUOMId]								--INT NOT NULL				-- The UOM used for the item.
	,[intLotId]									--INT NULL						-- Place holder field for lot numbers
	,[intSubLocationId]							--INT NULL				-- Place holder field for Sub Location 
	,[intStorageLocationId]						--INT NULL			-- Place holder field for Storage Location 
    ,[dblQty]									--NUMERIC(38, 20) NOT NULL DEFAULT 0 -- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
    ,[intTransactionId]							--INT NOT NULL			-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	,[strTransactionId]							--NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL			-- The string id of the source transaction. 
	,[intTransactionTypeId]						--INT NOT NULL											-- The transaction type. Source table for the types are found in tblICInventoryTransactionType	
	,[intOwnershipTypeId]						--INT NULL DEFAULT 1	-- Ownership type of the item.  
	)
	----DIRECT
	----Quantity/UOM Changed
	--SELECT
	--	 [intItemId]			= ARID.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARID.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= (ARID.[dblQtyShipped] - dbo.fnCalculateQtyBetweenUOM(ARTD.[intItemUOMId], ARID.[intItemUOMId], ARTD.[dblQtyShipped])) * ARIDC.[dblQuantity]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARTD.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARTD.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARTD.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARTD.[intStorageLocationId]
	--	,[dblQty]				= ARTD.[dblQtyShipped] * -1
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARTD.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARTD.[intStorageLocationId]
	--	,[dblQty]				= (ARTD.[dblQtyShipped] * ARIDC.[dblQuantity]) * -1
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARID.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARID.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped] * ARIDC.[dblQuantity]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARID.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARID.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped] * ARIDC.[dblQuantity]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARTD.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARTD.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARTD.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARTD.[intStorageLocationId]
	--	,[dblQty]				= ARTD.[dblQtyShipped] * -1
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARTD.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARTD.[intStorageLocationId]
	--	,[dblQty]				= (ARTD.[dblQtyShipped] * ARIDC.[dblQuantity]) * -1
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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

	----Item Changed +new
	--SELECT
	--	 [intItemId]			= ARID.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARID.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped] * ARIDC.[dblQuantity]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
		
	----POSTING
	----Direct
	--SELECT
	--	 [intItemId]			= ARID.[intItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARID.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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
	--	 [intItemId]			= ARIDC.[intComponentItemId]
	--	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	--	,[intItemUOMId]			= ARIDC.[intItemUOMId]
	--	,[intLotId]				= NULL
	--	,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
	--	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	--	,[dblQty]				= ARID.[dblQtyShipped] * ARIDC.[dblQuantity]
	--	,[intTransactionId]		= @InvoiceId
	--	,[strTransactionId]		= ARI.[strInvoiceNumber]
	--	,[intTransactionTypeId]	= @TransactionTypeId
	--	,[intOwnershipTypeId]	= 1
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


	SELECT
		 [intItemId]			= ARID.[intItemId]
		,[intItemLocationId]	= ICGIS.[intItemLocationId]
		,[intItemUOMId]			= ARID.[intItemUOMId]
		,[intLotId]				= NULL
		,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
		,[intStorageLocationId]	= ARID.[intStorageLocationId]
		,[dblQty]				= ARID.[dblQtyShipped]
		,[intTransactionId]		= @InvoiceId
		,[strTransactionId]		= ARI.[strInvoiceNumber]
		,[intTransactionTypeId]	= @TransactionTypeId
		,[intOwnershipTypeId]	= 1
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
	WHERE 
		ISNULL(@FromPosting,0) = 0
		AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
							
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)			

	--EXEC [uspICIncreaseReservedQty] 
	--	 @ItemsToIncreaseReserve = @items


	EXEC [uspICCreateStockReservation] 
		 @ItemsToReserve		= @items
		 ,@intTransactionId		= @InvoiceId
		 ,@intTransactionTypeId	= @TransactionTypeId
	 
END

GO
