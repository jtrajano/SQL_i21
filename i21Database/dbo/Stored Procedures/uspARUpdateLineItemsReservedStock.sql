CREATE PROCEDURE [dbo].[uspARUpdateLineItemsReservedStock]
	 @InvoiceIds	InvoiceId	READONLY
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @TransactionTypeId AS INT = 33
			,@Ownership_Own AS INT = 1
	SELECT @TransactionTypeId = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WHERE [strName] = 'Invoice'

	
	DECLARE @IdsForUpdate TABLE (intInvoiceId INT);
	INSERT INTO @IdsForUpdate
	SELECT II.[intHeaderId] FROM @InvoiceIds II INNER JOIN (SELECT intInvoiceId, intTransactionId FROM tblARInvoice) ARI ON II.[intHeaderId] = ARI.[intInvoiceId] WHERE NOT (ISNULL(II.[ysnFromPosting], 0 ) = 1 AND ISNULL(II.[ysnPost], 0 ) = 0) AND ARI.[intTransactionId] IS NULL
		
	--AR-4146 TODO -- FOR IC - provide a version of [uspICCreateStockReservation] that can handle multiple transactions
	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsForUpdate ORDER BY intInvoiceId)
	BEGIN				
		DECLARE @InvoiceId INT;
					
		SELECT TOP 1 @InvoiceId = intInvoiceId FROM @IdsForUpdate ORDER BY intInvoiceId

		DECLARE @items ItemReservationTableType
		DELETE FROM @items
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
			,[dblQty]				= ARID.[dblQtyShipped] * (CASE WHEN ISNULL(II.[ysnForDelete], 0) = 1 THEN 0 ELSE 1 END)
			,[intTransactionId]		= ARI.[intInvoiceId]
			,[strTransactionId]		= ARI.[strInvoiceNumber]
			,[intTransactionTypeId]	= @TransactionTypeId
			,[intOwnershipTypeId]	= @Ownership_Own
		FROM 
			(SELECT [intInvoiceId], [intItemId], [intInventoryShipmentItemId], [intItemUOMId], [intCompanyLocationSubLocationId], [intStorageLocationId], [dblQtyShipped], [intLotId]
			 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		INNER JOIN
			(SELECT [intInvoiceId], [strInvoiceNumber], [intCompanyLocationId], [strTransactionType] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN
			@InvoiceIds II
				ON ARI.[intInvoiceId] = II.[intHeaderId]
		INNER JOIN
			(SELECT [intItemUOMId] FROM tblICItemUOM WITH (NOLOCK)) ICIUOM 
				ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intItemLocationId] FROM vyuICGetItemStock WITH (NOLOCK)) ICGIS
				ON ARID.[intItemId] = ICGIS.[intItemId] 
				AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
		WHERE
			ARI.[intInvoiceId] = @InvoiceId
			AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
			AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
			AND ARID.[intInventoryShipmentItemId] IS NULL
			AND ARID.[intLotId] IS NULL
			AND NOT (ISNULL(II.[ysnFromPosting], 0 ) = 1 AND ISNULL(II.[ysnPost], 0 ) = 0)

		EXEC [uspICCreateStockReservation]
			 @ItemsToReserve		= @items
			,@intTransactionId		= @InvoiceId
			,@intTransactionTypeId	= @TransactionTypeId
			
		DELETE FROM @IdsForUpdate WHERE intInvoiceId = @InvoiceId
	END

	
	DECLARE @IdsForPosting TABLE (intInvoiceId INT, [ysnPost] BIT);
	INSERT INTO @IdsForPosting
	SELECT [intHeaderId], [ysnPost] FROM @InvoiceIds WHERE ISNULL([ysnFromPosting], 0 ) = 1

	--AR-4146 TODO -- FOR IC - provide a version of [uspICPostStockReservation] that can handle multiple transactions
	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsForPosting ORDER BY intInvoiceId)
	BEGIN				
		DECLARE @InvoiceId1 INT, @Post BIT;
					
		SELECT TOP 1 @InvoiceId1 = intInvoiceId, @Post = ISNULL([ysnPost], 0) FROM @IdsForPosting ORDER BY intInvoiceId

		EXEC [dbo].[uspICPostStockReservation]
			 @intTransactionId		= @InvoiceId1
			,@intTransactionTypeId	= @TransactionTypeId
			,@ysnPosted				= @Post
			
		DELETE FROM @IdsForPosting WHERE intInvoiceId = @InvoiceId1
	END		 
END

GO

