CREATE PROCEDURE [dbo].[uspICValidateStockReserves]
	@ItemsToValidate AS ItemReservationTableType READONLY
	,@strItemNo AS NVARCHAR(50) OUTPUT 
	,@intItemId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @AllowNegativeInventory_NoOption AS INT = 3
SET @intItemId = NULL 

--------------------------------------------------
-- Check all the non-Lot items.
-- Check the quantity from the stock UOM table. 
--------------------------------------------------
SELECT	TOP 1 
		@strItemNo = Item.strItemNo
		,@intItemId = Item.intItemId 
FROM	(
			SELECT	intItemId
					,intItemLocationId
					,intItemUOMId
					,dblQty = SUM(dblQty)
			FROM	@ItemsToValidate	
			WHERE	ISNULL(intLotId, 0) = 0 
			GROUP BY intItemId, intItemLocationId, intItemUOMId
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
					,dblQuantity = SUM(tblICStockReservation.dblQuantity)
			FROM	dbo.tblICStockReservation INNER JOIN @ItemsToValidate ValidateItems
						ON tblICStockReservation.intItemId = ValidateItems.intItemId
						AND tblICStockReservation.intItemLocationId = ValidateItems.intItemLocationId
						AND tblICStockReservation.intItemUOMId = ValidateItems.intItemUOMId
			WHERE	ISNULL(tblICStockReservation.intLotId, 0) = 0 
			GROUP BY tblICStockReservation.intItemId, tblICStockReservation.intItemLocationId, tblICStockReservation.intItemUOMId
		) Reserves 
			ON ValidateItems.intItemId = Reserves.intItemId
			AND ValidateItems.intItemLocationId = Reserves.intItemLocationId
			AND ValidateItems.intItemUOMId = Reserves.intItemUOMId
WHERE	ISNULL(StockUOM.dblOnHand, 0) - ISNULL(Reserves.dblQuantity, 0) - ValidateItems.dblQty < 0
		AND ItemLocation.intAllowNegativeInventory = @AllowNegativeInventory_NoOption -- If No is selected, it does not allow negative stock

-- If invalid, exit immediately.
IF @intItemId IS NOT NULL 
	RETURN;

--------------------------------------------------
-- Check all the lot Items.
-- Check the quantity from the Lot table
--------------------------------------------------
SELECT	TOP 1 
		@strItemNo = Item.strItemNo
		,@intItemId = Item.intItemId 
FROM	(
			SELECT	intItemId
					,intItemLocationId
					,intItemUOMId
					,intLotId
					,dblQty = SUM(dblQty)
			FROM	@ItemsToValidate	
			WHERE	ISNULL(intLotId, 0) <> 0 
			GROUP BY intItemId, intItemLocationId, intItemUOMId, intLotId
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
					,dblQuantity = SUM(tblICStockReservation.dblQuantity)
			FROM	dbo.tblICStockReservation INNER JOIN @ItemsToValidate ValidateItems
						ON tblICStockReservation.intItemId = ValidateItems.intItemId
						AND tblICStockReservation.intItemLocationId = ValidateItems.intItemLocationId
						AND tblICStockReservation.intItemUOMId = ValidateItems.intItemUOMId
			WHERE	ISNULL(tblICStockReservation.intLotId, 0) <> 0 
			GROUP BY tblICStockReservation.intItemId, tblICStockReservation.intItemLocationId, tblICStockReservation.intItemUOMId, tblICStockReservation.intLotId
		) Reserves 
			ON ValidateItems.intItemId = Reserves.intItemId
			AND ValidateItems.intItemLocationId = Reserves.intItemLocationId
			AND ValidateItems.intItemUOMId = Reserves.intItemUOMId
WHERE	ISNULL(Lot.dblOnHand, 0) - ISNULL(Reserves.dblQuantity, 0) - ValidateItems.dblQty < 0
		AND ItemLocation.intAllowNegativeInventory = @AllowNegativeInventory_NoOption -- If No is selected, it does not allow negative stock
