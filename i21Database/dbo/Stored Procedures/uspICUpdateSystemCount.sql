CREATE PROCEDURE [dbo].[uspICUpdateSystemCount]
AS

UPDATE cd
SET cd.dblSystemCount = s.dblOnHand
FROM tblICInventoryCountDetail cd
	INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
	INNER JOIN (
		SELECT
			StockUOM.intItemStockUOMId,
			StockUOM.intItemId,
			intLocationId = ItemLoc.intLocationId,
			StockUOM.intItemLocationId,
			StockUOM.intItemUOMId,
			dblOnHand = (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END),	
			dblUnitQty = ItemUOM.dblUnitQty,
			ysnStockUnit = ItemUOM.ysnStockUnit
		FROM tblICItemStockUOM StockUOM
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
			LEFT JOIN tblICLot Lot ON Lot.intItemId = StockUOM.intItemId
				AND Lot.intItemLocationId = StockUOM.intItemLocationId
				AND Lot.intItemUOMId = StockUOM.intItemUOMId
				AND Lot.intSubLocationId = StockUOM.intSubLocationId
				AND Lot.intStorageLocationId = StockUOM.intStorageLocationId
		WHERE ItemUOM.ysnStockUnit = 1
	) s ON s.intItemId = cd.intItemId
		AND s.intLocationId = c.intLocationId
WHERE c.intImportFlagInternal = 1

UPDATE ic
SET ic.intImportFlagInternal = NULL
FROM tblICInventoryCount ic
WHERE ic.intImportFlagInternal = 1