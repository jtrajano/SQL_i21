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
		AND Header.strType <> 'Debit Memo'
		AND Detail.intItemId = TD.intItemId		
		AND (Detail.intItemUOMId <> TD.intItemUOMId OR Detail.dblQtyShipped <> TD.dblQtyShipped)
		AND ISNULL(Detail.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) = 0)))
		AND IST.strType <> 'Bundle'

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
		AND Header.strType <> 'Debit Memo'
		AND Detail.intItemId <> TD.intItemId				
		AND ISNULL(Detail.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) = 0)))
		AND IST.strType <> 'Bundle'

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
		AND Header.strType <> 'Debit Memo'
		AND ISNULL(TD.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(TD.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(TD.intSalesOrderDetailId, 0) = 0)))
		AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
		AND IST.strType <> 'Bundle'
		
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
		AND Header.strType <> 'Debit Memo'
		AND ISNULL(Detail.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(Detail.intSalesOrderDetailId, 0) = 0)))
		AND Detail.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = 'Invoice')	
		AND IST.strType <> 'Bundle'

	-- BUNDLE Item
	UNION ALL

	--Quantity/UOM Changed
	SELECT
		 [intItemId]				=	ARGIC.intComponentItemId
		,[intItemLocationId]		=	ICGIS.intItemLocationId
		,[intItemUOMId]				=	ARGIC.intItemUnitMeasureId
		,[dtmDate]					=	ARI.dtmDate
		,[dblQty]					=	(CASE WHEN @Negate = 1 THEN ((ARID.dblQtyShipped * ARGIC.dblQuantity) * -1) ELSE (((ARID.dblQtyShipped * ARGIC.dblQuantity) - (ARTD.dblQtyShipped * ARGIC.dblQuantity))) END)
		,[dblUOMQty]				=	ICIU.dblUnitQty
		,[dblCost]					=	ICGIS.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARGIC.dblPrice
		,[intCurrencyId]			=	ARI.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.intInvoiceId
		,[intTransactionDetailId]	=	ARID.intSalesOrderDetailId
		,[strTransactionId]			=	ARI.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM
		vyuARGetItemComponents ARGIC
	INNER JOIN 
		tblARInvoiceDetail ARID
			ON ARGIC.intItemId = ARID.intItemId 
	INNER JOIN
		tblARInvoice ARI
			ON ARID.intInvoiceId = ARI.intInvoiceId
			AND ARGIC.intCompanyLocationId = ARI.intCompanyLocationId
	INNER JOIN
		tblARTransactionDetail ARTD
			ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
			AND ARID.intInvoiceId = ARTD.intTransactionId 
			AND ARTD.strTransactionType = 'Invoice'
	INNER JOIN
		tblICItemUOM ICIU 
			ON ARGIC.intItemUnitMeasureId = ICIU.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARGIC.intComponentItemId = ICGIS.intItemId 
			AND ARI.intCompanyLocationId = ICGIS.intLocationId 
	LEFT OUTER JOIN
		tblICItem ICI
			ON ARID.intItemId = ICI.intItemId 
	WHERE 
		ARI.intInvoiceId = @InvoiceId
		AND ARI.strTransactionType = 'Invoice'
		AND ARI.strType <> 'Debit Memo'
		AND ARID.intItemId = ARTD.intItemId		
		AND (ARID.intItemUOMId <> ARTD.intItemUOMId OR ARID.dblQtyShipped <> ARTD.dblQtyShipped)
		AND ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) = 0)))
		AND ICI.strType = 'Bundle'

	UNION ALL

	--Item Changed
	SELECT
		 [intItemId]				=	ARGIC.intComponentItemId
		,[intItemLocationId]		=	ICGIS.intItemLocationId
		,[intItemUOMId]				=	ARGIC.intItemUnitMeasureId
		,[dtmDate]					=	ARI.dtmDate
		,[dblQty]					=	(ARTD.dblQtyShipped * -1) * ARGIC.[dblQuantity]
		,[dblUOMQty]				=	ICIU.dblUnitQty
		,[dblCost]					=	ICGIS.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARGIC.dblPrice
		,[intCurrencyId]			=	ARI.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.intInvoiceId
		,[intTransactionDetailId]	=	ARTD.intSalesOrderDetailId
		,[strTransactionId]			=	ARI.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM
		vyuARGetItemComponents ARGIC
	INNER JOIN 
		tblARInvoiceDetail ARID
			ON ARGIC.intItemId = ARID.intItemId
	INNER JOIN
		tblARInvoice ARI
			ON ARID.intInvoiceId = ARI.intInvoiceId
			AND ARGIC.intCompanyLocationId = ARI.intCompanyLocationId
	INNER JOIN
		tblARTransactionDetail ARTD
			ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
			AND ARID.intInvoiceId = ARTD.intTransactionId 
			AND ARTD.strTransactionType = 'Invoice'
	INNER JOIN
		tblICItemUOM ICIU 
			ON ARGIC.intItemUnitMeasureId = ICIU.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARGIC.intComponentItemId = ICGIS.intItemId 
			AND ARI.intCompanyLocationId = ICGIS.intLocationId
	LEFT OUTER JOIN
		tblICItem ICI
			ON ARID.intItemId = ICI.intItemId 
	WHERE 
		ARI.intInvoiceId = @InvoiceId
		AND ARI.strTransactionType = 'Invoice'
		AND ARI.strType <> 'Debit Memo'
		AND ARID.intItemId <> ARTD.intItemId				
		AND ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) = 0)))
		AND ICI.strType = 'Bundle'

	UNION ALL

	--Deleted Item
	SELECT
		[intItemId]					=	ARGIC.intComponentItemId
		,[intItemLocationId]		=	ICGIS.intItemLocationId
		,[intItemUOMId]				=	ARGIC.intItemUnitMeasureId
		,[dtmDate]					=	ARI.dtmDate
		,[dblQty]					=	(ARTD.dblQtyShipped * -1) * ARGIC.[dblQuantity]
		,[dblUOMQty]				=	ICIU.dblUnitQty
		,[dblCost]					=	ICGIS.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARGIC.dblPrice 
		,[intCurrencyId]			=	ARI.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.intInvoiceId
		,[intTransactionDetailId]	=	ARTD.intSalesOrderDetailId
		,[strTransactionId]			=	ARI.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM 
		vyuARGetItemComponents ARGIC
	INNER JOIN
		tblARTransactionDetail ARTD
			ON ARGIC.intItemId = ARTD.intItemId 
	INNER JOIN
		tblARInvoice ARI
			ON ARTD.intTransactionId = ARI.intInvoiceId		
			AND ARGIC.intCompanyLocationId = ARI.intCompanyLocationId					
	INNER JOIN
		tblICItemUOM ICIU 
			ON ARGIC.intItemUnitMeasureId = ICIU.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARGIC.intComponentItemId = ICGIS.intItemId 
			AND ARI.intCompanyLocationId = ICGIS.intLocationId 
	LEFT OUTER JOIN
		tblICItem ICI
			ON ARTD.intItemId = ICI.intItemId 			
	WHERE 
		ARTD.intTransactionId = @InvoiceId
		AND ARI.strTransactionType = 'Invoice'
		AND ARI.strType <> 'Debit Memo'
		AND ISNULL(ARTD.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(ARTD.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(ARTD.intSalesOrderDetailId, 0) = 0)))
		AND ARTD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
		AND ICI.strType = 'Bundle'
		
	UNION ALL	
		
	--Added Item
	SELECT
		[intItemId]					=	ARGIC.intComponentItemId
		,[intItemLocationId]		=	ICGIS.intItemLocationId
		,[intItemUOMId]				=	ARGIC.intItemUnitMeasureId
		,[dtmDate]					=	ARI.dtmDate
		,[dblQty]					=	(ARID.dblQtyShipped * ARGIC.[dblQuantity])
		,[dblUOMQty]				=	ICIU.dblUnitQty
		,[dblCost]					=	ICGIS.dblLastCost
		,[dblValue]					=	0
		,[dblSalesPrice]			=	ARGIC.dblPrice 
		,[intCurrencyId]			=	ARI.intCurrencyId
		,[dblExchangeRate]			=	0
		,[intTransactionId]			=	ARI.intInvoiceId
		,[intTransactionDetailId]	=	ARID.intSalesOrderDetailId
		,[strTransactionId]			=	ARI.strInvoiceNumber
		,[intTransactionTypeId]		=	7
		,[intLotId]					=	NULL
		,[intSubLocationId]			=	NULL
		,[intStorageLocationId]		=	NULL
	FROM
		vyuARGetItemComponents ARGIC
	INNER JOIN 
		tblARInvoiceDetail ARID
			ON ARGIC.intItemId = ARID.intItemId
	INNER JOIN
		tblARInvoice ARI
			ON ARID.intInvoiceId = ARI.intInvoiceId
			AND ARGIC.intCompanyLocationId = ARI.intCompanyLocationId
	INNER JOIN
		tblICItemUOM ICIU 
			ON ARGIC.intItemUnitMeasureId = ICIU.intItemUOMId
	LEFT OUTER JOIN
		vyuICGetItemStock ICGIS
			ON ARGIC.intComponentItemId = ICGIS.intItemId 
			AND ARI.intCompanyLocationId = ICGIS.intLocationId 
	LEFT OUTER JOIN
		tblICItem ICI
			ON ARID.intItemId = ICI.intItemId 
	WHERE 
		ARID.intInvoiceId = @InvoiceId
		AND ARI.strTransactionType = 'Invoice'
		AND ARI.strType <> 'Debit Memo'
		AND ISNULL(ARID.intInventoryShipmentItemId, 0) = 0
		AND ((@FromPosting = 1) OR ((@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) > 0) OR (@FromPosting = 0 AND ISNULL(ARID.intSalesOrderDetailId, 0) = 0)))
		AND ARID.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @InvoiceId AND strTransactionType = 'Invoice')	
		AND ICI.strType = 'Bundle'
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)		

	EXEC uspICIncreaseOrderCommitted @items

END

GO