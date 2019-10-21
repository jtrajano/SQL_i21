﻿CREATE PROCEDURE uspICInventoryAdjustmentUpdateOutdatedStockOnHand
	@strTransactionId NVARCHAR(50) = NULL
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Update the quantities. 
UPDATE	Detail
SET		dblQuantity = 
			CASE	WHEN Detail.intLotId IS NOT NULL THEN Lot.dblQty
					WHEN Detail.intLotId IS NULL THEN ItemStockUOM.dblOnHand
					ELSE 0
			END
		,dblNewQuantity = 
			CASE	WHEN Detail.intLotId IS NOT NULL THEN Lot.dblQty
					WHEN Detail.intLotId IS NULL THEN ItemStockUOM.dblOnHand
					ELSE 0
			END
			+ Detail.dblAdjustByQuantity
FROM	dbo.tblICItem Item INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
			ON Item.intItemId = Detail.intItemId
		INNER JOIN dbo.tblICInventoryAdjustment Header
			ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ItemLocation.intItemId = Item.intItemId
			AND ItemLocation.intLocationId = Header.intLocationId
		LEFT JOIN dbo.tblICItemStockUOM ItemStockUOM
			ON ItemStockUOM.intItemId = Item.intItemId
			AND ItemStockUOM.intItemLocationId = ItemLocation.intItemLocationId
			AND ItemStockUOM.intItemUOMId = Detail.intItemUOMId
			AND ItemStockUOM.intStorageLocationId = Detail.intStorageLocationId
			AND ItemStockUOM.intSubLocationId = Detail.intSubLocationId
			AND ItemStockUOM.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN dbo.tblICLot Lot
			ON Detail.intLotId = Lot.intLotId
WHERE	Header.strAdjustmentNo = @strTransactionId	
		AND 1 = 
			CASE	WHEN Detail.intLotId IS NOT NULL AND (Detail.dblQuantity <> Lot.dblQty) THEN 1
					WHEN Detail.intLotId IS NULL AND (Detail.dblQuantity <> ItemStockUOM.dblOnHand) THEN 1
					ELSE 0
			END 