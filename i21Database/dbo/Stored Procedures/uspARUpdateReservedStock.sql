CREATE PROCEDURE [dbo].[uspARUpdateReservedStock]
	 @InvoiceId		INT
	,@Negate		BIT	= 0
	,@UserId		INT = NULL
	,@FromPosting	BIT = 0     
	,@Post			BIT = 0     
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @TransactionTypeId AS INT = 33
	  , @Ownership_Own AS INT = 1

SELECT @TransactionTypeId = [intTransactionTypeId] 
FROM dbo.tblICInventoryTransactionType 
WHERE [strName] = 'Invoice'

DECLARE @items ItemReservationTableType

INSERT INTO @items (												
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
SELECT [intItemId]			= ARID.[intItemId]
	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	,[intItemUOMId]			= ARID.[intItemUOMId]
	,[intLotId]				= ARIDL.intLotId
	,[intSubLocationId]		= ISNULL(ARID.[intCompanyLocationSubLocationId], ARID.[intSubLocationId])
	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	,[dblQty]				= ISNULL(ARID.[dblQtyShipped],0) * (CASE WHEN ISNULL(@Negate, 0) = 1 THEN 0 ELSE 1 END)
	,[intTransactionId]		= @InvoiceId
	,[strTransactionId]		= ARI.[strInvoiceNumber]
	,[intTransactionTypeId]	= @TransactionTypeId
	,[intOwnershipTypeId]	= @Ownership_Own
FROM (
	SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [intInventoryShipmentItemId], [intItemUOMId], [intCompanyLocationSubLocationId], [intSubLocationId], [intStorageLocationId], [dblQtyShipped], [intLotId], [intLoadDetailId], [intTicketId]
	FROM tblARInvoiceDetail WITH (NOLOCK)
) ARID
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId
INNER JOIN (
	SELECT [intInvoiceId], [strInvoiceNumber], [intCompanyLocationId], [strTransactionType], [strType] 
	FROM tblARInvoice WITH (NOLOCK)
) ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN (
	SELECT [intItemId], [strType], [strManufactureType], [ysnAutoBlend] 
	FROM tblICItem WITH (NOLOCK)
) ICI ON ARID.[intItemId] = ICI.[intItemId]
INNER JOIN (
	SELECT [intItemUOMId] 
	FROM tblICItemUOM WITH (NOLOCK)
) ICIUOM ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
LEFT OUTER JOIN (
	SELECT [intItemId], [intLocationId], [intItemLocationId], [dblUnitOnHand] 
	FROM vyuICGetItemStock WITH (NOLOCK)
) ICGIS ON ARID.[intItemId] = ICGIS.[intItemId] AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId]
LEFT OUTER JOIN vyuSCTicketScreenView SC ON ARID.[intTicketId] = SC.[intTicketId]
WHERE ISNULL(@FromPosting, 0 ) = 0
  AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 1
  AND ARI.[intInvoiceId] = @InvoiceId
  AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
  AND ARI.strType NOT IN ('Transport Delivery')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[intLoadDetailId] IS NULL		
  AND (SC.[intTicketId] IS NULL OR (SC.[intTicketId] IS NOT NULL AND ISNULL(SC.[strTicketType],'') <> 'Direct Out'))
  AND (
		(
			ICI.[strManufactureType] <> 'Finished Good'
			OR
			(ICI.[strManufactureType] = 'Finished Good' AND (ICI.[ysnAutoBlend] = 0  OR ISNULL(@Negate, 0) = 1))
		)
	OR 
		NOT(ICI.[strManufactureType] = 'Finished Good' AND ICI.[ysnAutoBlend] = 1 AND ICGIS.[dblUnitOnHand] < [dbo].[fnICConvertUOMtoStockUnit](ARID.[intItemId], ARID.[intItemUOMId], ARID.[dblQtyShipped]))			
				
	)
	
UNION ALL

SELECT [intItemId]			= ICGIS.[intComponentItemId]
	,[intItemLocationId]	= ICGIS.[intItemLocationId]
	,[intItemUOMId]			= ICGIS.[intComponentUOMId]
	,[intLotId]				= ARIDL.intLotId
	,[intSubLocationId]		= ISNULL(ARID.[intCompanyLocationSubLocationId], ARID.[intSubLocationId])
	,[intStorageLocationId]	= ARID.[intStorageLocationId]
	,[dblQty]				= ISNULL(ARID.[dblQtyShipped],0) * isnull(ICGIS.dblComponentQuantity,0)  *  (CASE WHEN ISNULL(@Negate, 0) = 1 THEN 0 ELSE 1 END)
	,[intTransactionId]		= @InvoiceId
	,[strTransactionId]		= ARI.[strInvoiceNumber]
	,[intTransactionTypeId]	= @TransactionTypeId
	,[intOwnershipTypeId]	= @Ownership_Own
FROM (
	SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [intInventoryShipmentItemId], [intItemUOMId], [intCompanyLocationSubLocationId], [intSubLocationId], [intStorageLocationId], [dblQtyShipped], [intLotId], [intLoadDetailId], [intTicketId]
	FROM tblARInvoiceDetail WITH (NOLOCK)
) ARID
LEFT JOIN tblARInvoiceDetailLot ARIDL ON ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId
INNER JOIN (
	SELECT [intInvoiceId], [strInvoiceNumber], [intCompanyLocationId], [strTransactionType], [strType] 
	FROM tblARInvoice WITH (NOLOCK)
) ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN (
	SELECT [intItemId], [strType], [strManufactureType], [ysnAutoBlend] 
	FROM tblICItem WITH (NOLOCK)
) ICI ON ARID.[intItemId] = ICI.[intItemId]
INNER JOIN (
	SELECT [intItemUOMId] 
	FROM tblICItemUOM WITH (NOLOCK)
) ICIUOM ON ICIUOM.[intItemUOMId] = ARID.[intItemUOMId]
LEFT OUTER JOIN (
	SELECT [intBundleItemId], [intComponentItemId], [intLocationId], [intItemLocationId], [dblUnitOnHand] = dblStockUnitQty, intComponentUOMId, dblComponentQuantity, dblComponentConvFactor, intStockUOMId 
	FROM vyuICGetBundleItemStock WITH (NOLOCK)
) ICGIS ON ARID.[intItemId] = ICGIS.[intBundleItemId] AND ARI.[intCompanyLocationId] = ICGIS.[intLocationId] 
LEFT OUTER JOIN vyuSCTicketScreenView SC ON ARID.[intTicketId] = SC.[intTicketId]
WHERE ISNULL(@FromPosting, 0 ) = 0
  AND [dbo].[fnIsStockTrackingItem](ARID.[intItemId]) = 0
  AND ARI.[intInvoiceId] = @InvoiceId
  AND ARI.[strTransactionType] IN ('Invoice', 'Cash')
  AND ARI.strType NOT IN ('Transport Delivery')
  AND ARID.[intInventoryShipmentItemId] IS NULL
  AND ARID.[intLoadDetailId] IS NULL  
  AND (SC.[intTicketId] IS NULL OR (SC.[intTicketId] IS NOT NULL AND ISNULL(SC.[strTicketType],'') <> 'Direct Out'))
  AND ICGIS.[intComponentItemId] IS NOT NULL
  AND (
			(
				ICI.[strManufactureType] <> 'Finished Good'
				OR
				(ICI.[strManufactureType] = 'Finished Good' AND (ICI.[ysnAutoBlend] = 0  OR ISNULL(@Negate, 0) = 1))
			)
		OR 
			NOT(ICI.[strManufactureType] = 'Finished Good' AND ICI.[ysnAutoBlend] = 1 AND ICGIS.[dblUnitOnHand] < [dbo].[fnICConvertUOMtoStockUnit](ARID.[intItemId], ARID.[intItemUOMId], ARID.[dblQtyShipped]))			
				
		)
			
IF (ISNULL(@FromPosting, 0 ) = 0)
	BEGIN		
		DECLARE @strInvalidItemNo AS NVARCHAR(50) 		
		DECLARE @intInvalidItemId AS INT
		DECLARE @intReturn AS INT
		SET  @intReturn = 0 
		
		-- Validate the reservation 
		EXEC @intReturn = dbo.uspICValidateStockReserves @items
														,@strInvalidItemNo OUTPUT 
														,@intInvalidItemId OUTPUT 

		IF @intReturn <> 0 
			RETURN @intReturn

		-- If there are enough stocks, let the system create the reservations
		IF (@intInvalidItemId IS NULL)	
			BEGIN 
				EXEC [uspICCreateStockReservation] @ItemsToReserve			= @items
												 , @intTransactionId		= @InvoiceId
												 , @intTransactionTypeId	= @TransactionTypeId
			END 
	END

IF ISNULL(@FromPosting, 0 ) = 1
		AND (
				EXISTS	(
					SELECT NULL 
					FROM tblARInvoice ARI
					INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
					INNER JOIN tblICStockReservation ICSR ON ARI.[intInvoiceId] = ICSR.[intTransactionId] 
														 AND ARI.[strInvoiceNumber] = ICSR.[strTransactionId]
														 AND ARID.[intItemId] = ICSR.[intItemId]
					WHERE ARI.[intInvoiceId] = @InvoiceId
					  AND ICSR.[ysnPosted] = 0
					)
				OR
				EXISTS(
					SELECT NULL 
					FROM tblARInvoice ARI
					INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
					JOIN tblICItemBundle BDL ON BDL.intItemId = ARID.intItemId
					INNER JOIN tblICStockReservation ICSR ON ARI.[intInvoiceId] = ICSR.[intTransactionId] 
														 AND ARI.[strInvoiceNumber] = ICSR.[strTransactionId]
														 AND BDL.[intBundleItemId] = ICSR.[intItemId]
					WHERE ARI.[intInvoiceId] = @InvoiceId
					  AND ICSR.[ysnPosted] = 0
				)
			)
		EXEC [dbo].[uspICPostStockReservation] @intTransactionId		= @InvoiceId
										     , @intTransactionTypeId	= @TransactionTypeId
										     , @ysnPosted				= @Post
	 
END

GO
