CREATE PROCEDURE [dbo].[uspARUpdateCommitted]
	@InvoiceId		INT
	,@Negate		BIT	= 0
	,@UserId		INT = NULL     
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
	--Quantity/UOM Changed
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	(CASE WHEN @Negate = 1 THEN (Detail.dblQtyShipped * -1) ELSE (Detail.dblQtyShipped - TD.dblQtyShipped) END)
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	Detail.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intInvoiceId
		,[intTransactionDetailId]	=	Detail.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblARInvoiceDetail Detail
	INNER JOIN
		tblARInvoice Header
			ON Detail.intInvoiceId = Header.intInvoiceId
	INNER JOIN
		tblARTransactionDetail TD
			ON Detail.intInvoiceDetailId = TD.intTransactionDetailId 
			AND Detail.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = Detail.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON Detail.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		Header.intInvoiceId = @InvoiceId
		AND Header.strTransactionType = 'Invoice'
		AND Detail.intItemId = TD.intItemId		
		AND (Detail.intItemUOMId <> TD.intItemUOMId OR Detail.dblQtyShipped <> TD.dblQtyShipped)
		AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)

	UNION ALL

	--Item Changed
	SELECT
		[intItemId]					=	TD.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	TD.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	TD.dblQtyShipped * -1
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	TD.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intInvoiceId
		,[intTransactionDetailId]	=	TD.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblARInvoiceDetail Detail
	INNER JOIN
		tblARInvoice Header
			ON Detail.intInvoiceId = Header.intInvoiceId
	INNER JOIN
		tblARTransactionDetail TD
			ON Detail.intInvoiceDetailId = TD.intTransactionDetailId 
			AND Detail.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = TD.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON TD.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		Header.intInvoiceId = @InvoiceId
		AND Header.strTransactionType = 'Invoice'
		AND Detail.intItemId <> TD.intItemId				
		AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)

	UNION ALL

	--Deleted Item
	SELECT
		[intItemId]					=	TD.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	TD.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	TD.dblQtyShipped * -1
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	TD.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intInvoiceId
		,[intTransactionDetailId]	=	TD.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblARTransactionDetail TD
	INNER JOIN
		tblARInvoice Header
			ON TD.intTransactionId = Header.intInvoiceId							
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = TD.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON TD.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		TD.intTransactionId = @InvoiceId
		AND Header.strTransactionType = 'Invoice'
		AND (TD.intInventoryShipmentItemId IS NULL OR TD.intInventoryShipmentItemId = 0)
		AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
		
	UNION ALL	
		
	--Added Item
	SELECT
		[intItemId]					=	Detail.intItemId
		,[intItemLocationId]		=	IST.intItemLocationId
		,[intItemUOMId]				=	Detail.intItemUOMId
		,[dtmDate]					=	Header.dtmDate
		,[dblQty]					=	Detail.dblQtyShipped
		,[dblUOMQty]				=	ItemUOM.dblUnitQty
		,[dblCost]					=	IST.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	Detail.dblPrice
		,[intCurrencyId]			=	Header.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	Header.intInvoiceId
		,[intTransactionDetailId]	=	Detail.intSalesOrderDetailId
		,[strTransactionId]			=	Header.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		tblARInvoiceDetail Detail
	INNER JOIN
		tblARInvoice Header
			ON Detail.intInvoiceId = Header.intInvoiceId							
	INNER JOIN
		tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = Detail.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock IST
			ON Detail.intItemId = IST.intItemId 
			AND Header.intCompanyLocationId = IST.intLocationId 
	WHERE 
		Detail.intInvoiceId = @InvoiceId
		AND Header.strTransactionType = 'Invoice'
		AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
		AND Detail.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = 'Invoice')	
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)		

	EXEC uspICIncreaseOrderCommitted @items

END

GO