CREATE PROCEDURE [dbo].[uspARUpdateLineItemsCommitted]
	 @InvoiceIds	InvoiceId	READONLY  
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
	--SO shipped
	SELECT
		[intItemId]					=	ARID.[intItemId]
		,[intItemLocationId]		=	IL.[intItemLocationId]
		,[intItemUOMId]				=	SOTD.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	(CASE
											WHEN dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped) + SOTD.dblQtyShipped > SOTD.dblQtyOrdered AND ISNULL(II.[ysnForDelete], 0) = 0 
												THEN  SOTD.dblQtyOrdered - SOTD.dblQtyShipped
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) <> 0
												AND ISNULL(II.[ysnForDelete], 0)  = 1 
												THEN  ABS(SOTD.dblQtyOrdered - SOTD.dblQtyShipped)
											WHEN (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) > (SOTD.dblQtyOrdered - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) 
												AND (SOTD.dblQtyShipped - dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)) = 0
												AND ISNULL(II.[ysnForDelete], 0) = 1 
												THEN  SOTD.dblQtyOrdered
											ELSE
												dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOTD.intItemUOMId, ARID.dblQtyShipped)
										END)
		,[dblUOMQty]				=	ICIUOM.[dblUnitQty]
		,[dblCost]					=	IPP.[dblLastCost]
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
	FROM tblARInvoiceDetail ARID WITH(NOLOCK)
	INNER JOIN tblARInvoice ARI WITH(NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblSOSalesOrderDetail SOTD WITH(NOLOCK) ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN tblICItemUOM ICIUOM WITH(NOLOCK) ON ICIUOM.[intItemUOMId] = SOTD.[intItemUOMId]
	INNER JOIN tblICItem ITEM WITH(NOLOCK) ON ARID.intItemId = ITEM.intItemId
	INNER JOIN tblICItemLocation IL WITH(NOLOCK) ON ITEM.intItemId = IL.intItemId AND ARI.intCompanyLocationId = IL.intLocationId
	INNER JOIN tblICItemPricing IPP WITH(NOLOCK) ON IPP.intItemId = ITEM.intItemId AND IPP.intItemLocationId = IL.intItemLocationId
	INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId]  = II.[intHeaderId] 
	WHERE ITEM.strType = 'Inventory'
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intLoadDetailId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
		AND ISNULL(ARI.[intTransactionId], 0) = 0 
		AND ISNULL(II.[ysnFromPosting],0) = 1

	UNION ALL
	--SO shipped --Component
	SELECT
		[intItemId]					=	ARIDC.[intComponentItemId]
		,[intItemLocationId]		=	IL.[intItemLocationId]
		,[intItemUOMId]				=	ARIDC.[intItemUOMId]
		,[dtmDate]					=	ARI.[dtmDate]
		,[dblQty]					=	dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], SOTD.[intItemUOMId], ARID.[dblQtyShipped]) * ARIDC.[dblQuantity] 
		,[dblUOMQty]				=	ARIDC.[dblUnitQuantity] 
		,[dblCost]					=	IPP.[dblLastCost]
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
	FROM tblARInvoiceDetailComponent ARIDC WITH (NOLOCK)
	INNER JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId] 
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblSOSalesOrderDetail SOTD WITH (NOLOCK) ON ARID.[intSalesOrderDetailId] = SOTD.[intSalesOrderDetailId] 
	INNER JOIN tblICItem ITEM WITH(NOLOCK) ON ARIDC.[intComponentItemId] = ITEM.intItemId
	INNER JOIN tblICItemLocation IL WITH(NOLOCK) ON ITEM.intItemId = IL.intItemId AND ARI.intCompanyLocationId = IL.intLocationId
	INNER JOIN tblICItemPricing IPP WITH(NOLOCK) ON IPP.intItemId = ITEM.intItemId AND IPP.intItemLocationId = IL.intItemLocationId	
	INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId]  = II.[intHeaderId]
	WHERE ITEM.strType = 'Inventory'
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0 
		AND ISNULL(ARID.[intLoadDetailId], 0) = 0 
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) <> 0
		AND ISNULL(ARI.[intTransactionId], 0) = 0 
		AND ISNULL(II.[ysnFromPosting],0) = 1
				
		
	UPDATE I
	SET I.dblQty = I.dblQty * (CASE WHEN ISNULL(II.[ysnForDelete], 0) = 1 THEN -1 ELSE 1 END)		
	FROM @items I
	INNER JOIN @InvoiceIds II ON I.[intTransactionId]  = II.[intHeaderId]

	EXEC uspICIncreaseOrderCommitted @items
	 
END

GO
