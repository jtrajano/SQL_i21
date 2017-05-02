CREATE PROCEDURE [dbo].[uspICValidateStockReserves]
	@ItemsToValidate AS ItemReservationTableType READONLY
	,@strInvalidItemNo AS NVARCHAR(50) OUTPUT 
	,@intInvalidItemId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @AllowNegativeInventory_NoOption AS INT = 3

DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2
		,@Ownership_Consigned AS INT = 3
		
DECLARE @dblReservedQty AS NUMERIC(38,20)
		,@dblOnHandQty AS NUMERIC(38,20)
		,@intLotId AS INT 

SET @intInvalidItemId = NULL 

--------------------------------------------------
-- Check all the non-Lot items.
-- Check the quantity from the stock UOM table. 
--------------------------------------------------
SELECT	TOP 1 
		@strInvalidItemNo = Item.strItemNo
		,@intInvalidItemId = Item.intItemId 
		,@dblReservedQty = ISNULL(Reserves.dblQuantity, 0)
		,@dblOnHandQty = ISNULL(StockUOM.dblOnHand, 0)
FROM	(
			SELECT	intItemId
					,intItemLocationId
					,intItemUOMId
					,intSubLocationId
					,intStorageLocationId
					,dblQty = SUM(dblQty)
					,intTransactionId
					,intTransactionTypeId
			FROM	@ItemsToValidate	
			WHERE	ISNULL(intLotId, 0) = 0 
					AND ISNULL(intOwnershipTypeId, @Ownership_Own) = @Ownership_Own
			GROUP BY 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,intTransactionId
				,intTransactionTypeId
		) ValidateItems INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ValidateItems.intItemId = ItemLocation.intItemId
			AND ValidateItems.intItemLocationId = ItemLocation.intItemLocationId
		INNER JOIN tblICItem Item
			ON ValidateItems.intItemId = Item.intItemId
		LEFT JOIN dbo.tblICItemStockUOM StockUOM
			ON ValidateItems.intItemUOMId = StockUOM.intItemUOMId
			AND ValidateItems.intItemId = StockUOM.intItemId
			AND ValidateItems.intItemLocationId = StockUOM.intItemLocationId
			AND ISNULL(ValidateItems.intSubLocationId, 0) = ISNULL(StockUOM.intSubLocationId, 0)
			AND ISNULL(ValidateItems.intStorageLocationId, 0) = ISNULL(StockUOM.intStorageLocationId, 0)
		LEFT JOIN (
			SELECT	tblICStockReservation.intItemId
					,tblICStockReservation.intItemLocationId
					,tblICStockReservation.intItemUOMId
					,tblICStockReservation.intSubLocationId
					,tblICStockReservation.intStorageLocationId
					,dblQuantity = SUM(tblICStockReservation.dblQty)
			FROM	dbo.tblICStockReservation INNER JOIN @ItemsToValidate ValidateItems
						ON tblICStockReservation.intItemId = ValidateItems.intItemId
						AND tblICStockReservation.intItemLocationId = ValidateItems.intItemLocationId
						AND tblICStockReservation.intItemUOMId = ValidateItems.intItemUOMId
						AND ISNULL(tblICStockReservation.intSubLocationId, 0) = ISNULL(ValidateItems.intSubLocationId, 0)
						AND ISNULL(tblICStockReservation.intStorageLocationId, 0) = ISNULL(ValidateItems.intStorageLocationId, 0)
						AND tblICStockReservation.intTransactionId <> ValidateItems.intTransactionId
						AND tblICStockReservation.strTransactionId <> ValidateItems.strTransactionId
			WHERE	ISNULL(tblICStockReservation.intLotId, 0) = 0 
					AND ISNULL(tblICStockReservation.ysnPosted, 0) = 0		
					AND ISNULL(intOwnershipTypeId, @Ownership_Own) = @Ownership_Own		
			GROUP BY 
				tblICStockReservation.intItemId
				,tblICStockReservation.intItemLocationId
				,tblICStockReservation.intItemUOMId
				,tblICStockReservation.intSubLocationId
				,tblICStockReservation.intStorageLocationId
		) Reserves 
			ON ValidateItems.intItemId = Reserves.intItemId
			AND ValidateItems.intItemLocationId = Reserves.intItemLocationId
			AND ValidateItems.intItemUOMId = Reserves.intItemUOMId
			AND ISNULL(ValidateItems.intSubLocationId, 0) = ISNULL(Reserves.intSubLocationId, 0)
			AND ISNULL(ValidateItems.intStorageLocationId, 0) = ISNULL(Reserves.intStorageLocationId, 0)
WHERE	ISNULL(StockUOM.dblOnHand, 0) - ISNULL(Reserves.dblQuantity, 0) - ValidateItems.dblQty < 0
		AND ItemLocation.intAllowNegativeInventory = @AllowNegativeInventory_NoOption -- If No is selected, it does not allow negative stock

-- If invalid, exit immediately.
IF @intInvalidItemId IS NOT NULL 
BEGIN 
	-- 'Not enough stocks for {Item}. Reserved stocks is {Reserved Stock Qty} while On Hand Qty is {On Hand Qty}.'			
	EXEC uspICRaiseError 80007, @strInvalidItemNo, @dblReservedQty, @dblOnHandQty
	RETURN -1;
END 	

--------------------------------------------------
-- Check all the lot Items.
-- Check the quantity from the Lot table
--------------------------------------------------
SELECT	@intInvalidItemId = NULL 
		,@dblReservedQty = 0
		,@dblOnHandQty = 0

SELECT	TOP 1 
		@strInvalidItemNo = Item.strItemNo
		,@intInvalidItemId = Item.intItemId 
		,@dblReservedQty = ISNULL(Reserves.dblQty, 0)
		,@dblOnHandQty = ISNULL(Lot.dblQty, 0)
		,@intLotId = Lot.intLotId
FROM	(
			SELECT	intItemId
					,intItemLocationId
					,intItemUOMId
					,intLotId
					,intSubLocationId
					,intStorageLocationId
					,dblQty = SUM(dblQty)
					,intTransactionId
					,intTransactionTypeId
			FROM	@ItemsToValidate	
			WHERE	ISNULL(intLotId, 0) <> 0 
					AND ISNULL(intOwnershipTypeId, @Ownership_Own) = @Ownership_Own
			GROUP BY 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,intTransactionId
				,intTransactionTypeId
		) ValidateItems
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ValidateItems.intItemId = ItemLocation.intItemId
			AND ValidateItems.intItemLocationId = ItemLocation.intItemLocationId
		INNER JOIN tblICItem Item
			ON ValidateItems.intItemId = Item.intItemId
		LEFT JOIN dbo.tblICLot Lot
			ON ValidateItems.intItemLocationId = Lot.intItemLocationId
			AND ValidateItems.intLotId = Lot.intLotId
		LEFT JOIN (
			SELECT	tblICStockReservation.intItemId
					,tblICStockReservation.intItemLocationId
					,tblICStockReservation.intItemUOMId
					,tblICStockReservation.intLotId
					,tblICStockReservation.intSubLocationId
					,tblICStockReservation.intStorageLocationId
					,dblQty = SUM(tblICStockReservation.dblQty)
			FROM	dbo.tblICStockReservation INNER JOIN @ItemsToValidate ValidateItems
						ON tblICStockReservation.intItemId = ValidateItems.intItemId
						AND tblICStockReservation.intItemLocationId = ValidateItems.intItemLocationId
						AND tblICStockReservation.intItemUOMId = ValidateItems.intItemUOMId
						AND tblICStockReservation.intLotId = ValidateItems.intLotId
						AND ISNULL(tblICStockReservation.intSubLocationId, 0) = ISNULL(ValidateItems.intSubLocationId, 0)
						AND ISNULL(tblICStockReservation.intStorageLocationId, 0) = ISNULL(ValidateItems.intStorageLocationId, 0)
						AND tblICStockReservation.intTransactionId <> ValidateItems.intTransactionId
						AND tblICStockReservation.strTransactionId <> ValidateItems.strTransactionId
			WHERE	ISNULL(tblICStockReservation.intLotId, 0) <> 0 
					AND ISNULL(tblICStockReservation.ysnPosted, 0) = 0
					AND NOT (
						tblICStockReservation.intTransactionId = ValidateItems.intTransactionId
						AND tblICStockReservation.intTransactionId = ValidateItems.intTransactionTypeId
					)
					AND ISNULL(intOwnershipTypeId, @Ownership_Own) = @Ownership_Own

			GROUP BY 
				tblICStockReservation.intItemId
				,tblICStockReservation.intItemLocationId
				,tblICStockReservation.intItemUOMId
				,tblICStockReservation.intLotId
				,tblICStockReservation.intSubLocationId
				,tblICStockReservation.intStorageLocationId
		) Reserves 
			ON ValidateItems.intItemId = Reserves.intItemId
			AND ValidateItems.intItemLocationId = Reserves.intItemLocationId
			AND ValidateItems.intItemUOMId = Reserves.intItemUOMId
			AND ValidateItems.intLotId = Reserves.intLotId
			AND ISNULL(ValidateItems.intSubLocationId, 0) = ISNULL(Reserves.intSubLocationId, 0)
			AND ISNULL(ValidateItems.intStorageLocationId, 0) = ISNULL(Reserves.intStorageLocationId, 0)
WHERE	ISNULL(Lot.dblQty, 0) - ISNULL(Reserves.dblQty, 0) - ValidateItems.dblQty < 0
		AND ItemLocation.intAllowNegativeInventory = @AllowNegativeInventory_NoOption -- If No is selected, it does not allow negative stock

IF @intInvalidItemId IS NOT NULL 
BEGIN 
	-- 'Not enough stocks for {Item}. Reserved stocks is {Reserved Lot Qty} while Lot Qty is {Lot Qty}.'
	EXEC uspICRaiseError 80176, @strInvalidItemNo, @dblReservedQty, @dblOnHandQty
	RETURN -1;
END 
