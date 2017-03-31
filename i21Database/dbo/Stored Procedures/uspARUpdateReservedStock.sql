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
	WHERE [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
		AND ARI.[intInvoiceId] = @InvoiceId
		AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
		
	UPDATE
		@items
	SET
		dblQty = dblQty * (CASE WHEN @Negate = 1 THEN -1 ELSE 1 END)			

	EXEC [uspICIncreaseReservedQty] 
		 @ItemsToIncreaseReserve		= @items		 
	 
END

GO
