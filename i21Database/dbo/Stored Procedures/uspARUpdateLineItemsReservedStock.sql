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
	SELECT II.[intHeaderId] 
	FROM @InvoiceIds II 
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON II.[intHeaderId] = ARI.[intInvoiceId] 
	WHERE NOT (ISNULL(II.[ysnFromPosting], 0 ) = 1 AND ISNULL(II.[ysnPost], 0 ) = 0) 
	  AND ARI.[intTransactionId] IS NULL
		
	--AR-4146 TODO -- FOR IC - provide a version of [uspICCreateStockReservation] that can handle multiple transactions
	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsForUpdate ORDER BY intInvoiceId)
	BEGIN				
		DECLARE @InvoiceId INT;
					
		SELECT TOP 1 @InvoiceId = intInvoiceId FROM @IdsForUpdate ORDER BY intInvoiceId

		DECLARE @items ItemReservationTableType

		DELETE FROM @items

		INSERT INTO @items (							--[intId] INT IDENTITY PRIMARY KEY CLUSTERED
			  [intItemId]								--INT NOT NULL					-- The item. 
			, [intItemLocationId]						--INT NOT NULL			-- The location where the item is stored.
			, [intItemUOMId]							--INT NOT NULL				-- The UOM used for the item.
			, [intLotId]								--INT NULL						-- Place holder field for lot numbers
			, [intSubLocationId]						--INT NULL				-- Place holder field for Sub Location 
			, [intStorageLocationId]					--INT NULL			-- Place holder field for Storage Location 
			, [dblQty]									--NUMERIC(38, 20) NOT NULL DEFAULT 0 -- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
			, [intTransactionId]						--INT NOT NULL			-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
			, [strTransactionId]						--NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL			-- The string id of the source transaction. 
			, [intTransactionTypeId]					--INT NOT NULL											-- The transaction type. Source table for the types are found in tblICInventoryTransactionType	
			, [intOwnershipTypeId]						--INT NULL DEFAULT 1	-- Ownership type of the item.  
		)
		SELECT
			 [intItemId]			= ARID.[intItemId]
			,[intItemLocationId]	= IL.[intItemLocationId]
			,[intItemUOMId]			= ARID.[intItemUOMId]
			,[intLotId]				= NULL
			,[intSubLocationId]		= ARID.[intCompanyLocationSubLocationId]
			,[intStorageLocationId]	= ARID.[intStorageLocationId]
			,[dblQty]				= ARID.[dblQtyShipped] * (CASE WHEN ISNULL(II.[ysnForDelete], 0) = 1 THEN 0 ELSE 1 END)
			,[intTransactionId]		= ARI.[intInvoiceId]
			,[strTransactionId]		= ARI.[strInvoiceNumber]
			,[intTransactionTypeId]	= @TransactionTypeId
			,[intOwnershipTypeId]	= @Ownership_Own
		FROM tblARInvoiceDetail ARID WITH (NOLOCK)
		INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId] = II.[intHeaderId]
		INNER JOIN tblICItemUOM ICIUOM  WITH (NOLOCK) ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
		INNER JOIN tblICItem ITEM ON ARID.intItemId = ITEM.intItemId
		INNER JOIN tblICItemLocation IL ON ITEM.intItemId = ITEM.intItemId AND ARI.intCompanyLocationId = IL.intLocationId
		WHERE ARI.[intInvoiceId] = @InvoiceId
			AND ITEM.strType = 'Inventory'
			AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
			AND ARID.[intInventoryShipmentItemId] IS NULL
			AND ARID.[intLoadDetailId] IS NULL			
			AND ARID.[intLotId] IS NULL
			AND NOT (ISNULL(II.[ysnFromPosting], 0 ) = 1 AND ISNULL(II.[ysnPost], 0 ) = 0)

		EXEC [uspICCreateStockReservation]
			 @ItemsToReserve		= @items
			,@intTransactionId		= @InvoiceId
			,@intTransactionTypeId	= @TransactionTypeId
			
		DELETE FROM @IdsForUpdate WHERE intInvoiceId = @InvoiceId
	END
END

GO