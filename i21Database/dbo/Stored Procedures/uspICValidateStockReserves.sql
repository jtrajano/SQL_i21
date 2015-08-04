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
		
DECLARE @dblReservedQty AS NUMERIC(18,6)
		,@dblOnHandQty AS NUMERIC(18,6)
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
	GOTO _Exit;
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

_Exit:

IF @intInvalidItemId IS NOT NULL 
BEGIN 
		DECLARE @FormattedReservedQty AS NVARCHAR(50)
				,@FormattedOnHandQty AS NVARCHAR(50)

		SET @FormattedReservedQty =  CONVERT(NVARCHAR, CAST(@dblReservedQty AS MONEY), 1)
		SET @FormattedOnHandQty =  CONVERT(NVARCHAR, CAST(@dblOnHandQty AS MONEY), 1)

		IF @intLotId IS NOT NULL 
		BEGIN 
			-- = 'There is not enough stocks for {Item}. Reserved stocks is {Reserved Lot Qty} while Lot Qty is {Lot Qty}.'
			RAISERROR(51175, 11, 1, @strInvalidItemNo, @FormattedReservedQty, @FormattedOnHandQty) 
		END 
		ELSE 
		BEGIN 
			-- 'There is not enough stocks for {Item}. Reserved stocks is {Reserved Stock Qty} while On Hand Qty is {On Hand Qty}.'
			RAISERROR(51040, 11, 1, @strInvalidItemNo, @FormattedReservedQty, @FormattedOnHandQty) 
		END 

		RETURN -1;
END 
