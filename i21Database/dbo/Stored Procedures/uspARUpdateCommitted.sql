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
	DECLARE @intItemId INT
	DECLARE @dblQuantityOrdered NUMERIC(18,6)
	DECLARE @dblQuantityShipped NUMERIC(18,6)
	DECLARE @dblOrderCommitted NUMERIC(18,6)
	DECLARE @dblUnitReserved NUMERIC(18,6)

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
	--SO shipped
	SELECT
		[intItemId]					=	ARID.[intItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	SOTD.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	(CASE
											WHEN dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped) + SOTD.dblQtyShipped > SOTD.dblQtyOrdered AND @Negate = 0 
												THEN  SOTD.dblQtyOrdered - SOTD.dblQtyShipped
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) <> 0
												AND @Negate = 1 
												THEN  ABS(SOTD.dblQtyOrdered - SOTD.dblQtyShipped)
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) = 0
												AND @Negate = 1 
												THEN  SOTD.dblQtyOrdered
											ELSE
												dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)
										END)
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
		,[intLotId]					=	ARID.[intLotId]
		,[intSubLocationId]			=	SOTD.[intSubLocationId]
		,[intStorageLocationId]		=	SOTD.[intStorageLocationId]
	FROM 
		(SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [intSalesOrderDetailId], [dblPrice], [intInventoryShipmentItemId], [dblQtyOrdered], [dblQtyShipped], [intLotId], [intItemUOMId] FROM tblARInvoiceDetail WITH(NOLOCK)) ARID
	INNER JOIN
		(SELECT [intInvoiceId], [strInvoiceNumber], [intCurrencyId], [dtmDate], [intCompanyLocationId], [strTransactionType] FROM tblARInvoice  WITH(NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intSalesOrderDetailId], [intItemId], [intSubLocationId], [intItemUOMId], [intStorageLocationId], [dblQtyOrdered], [dblQtyShipped] FROM tblSOSalesOrderDetail WITH(NOLOCK)) SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN
		(SELECT [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NOLOCK)) ICIUOM 
			ON ICIUOM.[intItemUOMId] = SOTD.[intItemUOMId]	
	LEFT OUTER JOIN
		(SELECT [intLocationId], [intItemId], [dblLastCost], [intItemLocationId] FROM vyuICGetItemStock WITH(NOLOCK)) ICGIS
			ON SOTD.[intItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0

	UNION ALL
	--SO shipped --Component
	SELECT
		[intItemId]					=	ARIDC.[intComponentItemId]
		,[intItemLocationId]		=	ICGIS.[intItemLocationId]
		,[intItemUOMId]				=	ARIDC.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) * ARIDC.[dblQuantity] 
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
		,[intLotId]					=	ARID.[intLotId]
		,[intSubLocationId]			=	SOTD.[intSubLocationId]
		,[intStorageLocationId]		=	SOTD.[intStorageLocationId]
	FROM 
		(SELECT [intComponentItemId], [intItemUOMId], [dblQuantity], [dblUnitQuantity], [intInvoiceDetailId] FROM tblARInvoiceDetailComponent WITH (NOLOCK)) ARIDC
	INNER JOIN 
		(SELECT [intInvoiceId], [intInvoiceDetailId], [intSalesOrderDetailId], [dblPrice], [intInventoryShipmentItemId], [dblQtyShipped], [intItemUOMId], [intLotId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	INNER JOIN
		(SELECT [intInvoiceId], [dtmDate], [intCurrencyId], [strInvoiceNumber], [intCompanyLocationId], [strTransactionType] FROM tblARInvoice WITH (NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intSalesOrderDetailId], [intSubLocationId], [intStorageLocationId], [dblQtyOrdered], [intItemUOMId] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	LEFT OUTER JOIN
		(SELECT [intItemId], [intLocationId], [intItemLocationId], [dblLastCost] FROM vyuICGetItemStock WITH (NOLOCK)) ICGIS
			ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
				
				
SELECT 	  		@intItemId						= ABC.[intItemId],
				@dblQuantityOrdered				= ABC.[dblQtyOrdered],
				@dblQuantityShipped				= ABC.[dblQuantityShipped],					
				@dblOrderCommitted				= ICIS.[dblOrderCommitted],
				@dblUnitReserved				= ICIS.[dblUnitReserved]		
FROM
(			
	--SO shipped
	SELECT
		[dblQtyOrdered]				=	SOTD.dblQtyOrdered,
		[dblQuantityShipped]		=  (CASE
											WHEN dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped) + SOTD.dblQtyShipped > SOTD.dblQtyOrdered AND 1 = 0 
												THEN  SOTD.dblQtyOrdered - SOTD.dblQtyShipped
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) <> 0
												AND 1 = 1 
												THEN  ABS(SOTD.dblQtyOrdered - SOTD.dblQtyShipped)
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) = 0
												AND 1 = 1 
												THEN  SOTD.dblQtyOrdered
											ELSE
												dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)
										END),
		[intItemId]					=	ARID.[intItemId]
	FROM 
		(SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [intSalesOrderDetailId], [dblPrice], [intInventoryShipmentItemId], [dblQtyOrdered], [dblQtyShipped], [intLotId], [intItemUOMId] FROM tblARInvoiceDetail WITH(NOLOCK)) ARID
	INNER JOIN
		(SELECT [intInvoiceId], [strInvoiceNumber], [intCurrencyId], [dtmDate], [intCompanyLocationId], [strTransactionType] FROM tblARInvoice  WITH(NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intSalesOrderDetailId], [intItemId], [intSubLocationId], [intItemUOMId], [intStorageLocationId], [dblQtyOrdered], [dblQtyShipped] FROM tblSOSalesOrderDetail WITH(NOLOCK)) SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN
		(SELECT [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NOLOCK)) ICIUOM 
			ON ICIUOM.[intItemUOMId] = SOTD.[intItemUOMId]	
	LEFT OUTER JOIN
		(SELECT [intLocationId], [intItemId], [dblLastCost], [intItemLocationId] FROM vyuICGetItemStock WITH(NOLOCK)) ICGIS
			ON SOTD.[intItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
		 
	UNION ALL
	--SO shipped --Component
	SELECT
		[dblQtyOrdered]				=	dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyOrdered]) * ARIDC.[dblQuantity],
		[dblQuantityShipped]		=	dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) * ARIDC.[dblQuantity],
		[intItemId]					=	ARIDC.[intComponentItemId]
	FROM 
		(SELECT [intComponentItemId], [intItemUOMId], [dblQuantity], [dblUnitQuantity], [intInvoiceDetailId] FROM tblARInvoiceDetailComponent WITH (NOLOCK)) ARIDC
	INNER JOIN 
		(SELECT [intInvoiceId], [intInvoiceDetailId], [intSalesOrderDetailId], [dblPrice], [intInventoryShipmentItemId], [dblQtyOrdered], [dblQtyShipped], [intItemUOMId], [intLotId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	INNER JOIN
		(SELECT [intInvoiceId], [dtmDate], [intCurrencyId], [strInvoiceNumber], [intCompanyLocationId], [strTransactionType] FROM tblARInvoice WITH (NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intSalesOrderDetailId], [intSubLocationId], [intStorageLocationId], [dblQtyOrdered], [intItemUOMId] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOTD
			ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	LEFT OUTER JOIN
		(SELECT [intItemId], [intLocationId], [intItemLocationId], [dblLastCost] FROM vyuICGetItemStock WITH (NOLOCK)) ICGIS
			ON ARIDC.[intComponentItemId] = ICGIS.[intItemId] 
			AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
	WHERE [dbo].[fnIsStockTrackingItem](ARIDC.[intComponentItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
) ABC
INNER JOIN (SELECT intItemId , dblOrderCommitted, dblUnitReserved FROM tblICItemStock) ICIS ON ABC.intItemId = ICIS.intItemId

--- Unposted	
IF (ISNULL(@FromPosting, 0 ) = 0)
	BEGIN
		--- Fully Invoiced
		IF (@dblQuantityOrdered = @dblQuantityShipped)
			BEGIN
				UPDATE
					@items
				SET 
					dblQty = @dblQuantityShipped * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)												
			END	
		ELSE 
		--- Partial
		BEGIN
			IF ((@dblQuantityOrdered = @dblQuantityShipped) AND (@dblQuantityOrdered = (@dblOrderCommitted + @dblUnitReserved)))	
				BEGIN
 					UPDATE
						@items
					SET
						dblQty = 0						
				END
			ELSE IF ((@dblQuantityOrdered > @dblQuantityShipped) AND (@dblQuantityOrdered > (@dblOrderCommitted + @dblUnitReserved)))
				BEGIN
 					UPDATE
						@items
					SET
						dblQty = @dblQuantityOrdered - @dblUnitReserved						 						
				END
			ELSE IF ((@dblQuantityOrdered > @dblQuantityShipped) AND @dblUnitReserved = 0 AND (@dblQuantityShipped < (@dblOrderCommitted + @dblUnitReserved)) )
				BEGIN
 					UPDATE
						@items
					SET
						dblQty = 0		 
				END
			ELSE 
				BEGIN
 					UPDATE
						@items
					SET
						dblQty = 0
				END
		END
	END
--- Posted
ELSE
	BEGIN
		IF ((@dblQuantityOrdered = @dblQuantityShipped) AND (@dblQuantityOrdered = (@dblOrderCommitted + @dblUnitReserved)))	
			BEGIN
 				UPDATE
					@items
				SET
					dblQty = 0					
			END
		ELSE IF ((@dblQuantityOrdered > @dblQuantityShipped) AND (@dblQuantityOrdered > (@dblOrderCommitted + @dblUnitReserved)))
			BEGIN
 				UPDATE
					@items
				SET
					--dblQty = @dblQuantityOrdered - @dblQuantityShipped					
					dblQty = 0
			END
		ELSE IF ((@dblQuantityOrdered > @dblQuantityShipped) AND (@dblQuantityOrdered = (@dblOrderCommitted + @dblUnitReserved)))
			BEGIN
 				UPDATE
					@items
				SET
					dblQty =  0					
			END
		ELSE 
			BEGIN
 				UPDATE
					@items
				SET
					dblQty = 0					
			END
	END
	 
	EXEC uspICIncreaseOrderCommitted @items
	 
END

GO

 