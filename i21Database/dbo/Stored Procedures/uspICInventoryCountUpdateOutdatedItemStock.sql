﻿CREATE PROCEDURE dbo.uspICInventoryCountUpdateOutdatedItemStock (@intInventoryCountId INT)
AS

UPDATE cd
SET cd.dblSystemCount = os.dblNewOnHand,
	-- cd.dblLastCost = os.dblNewCost,
	cd.dblWeightQty = os.dblNewWeightQty,
	cd.dblNetQty = os.dblNewWeightQty
FROM tblICInventoryCountDetail cd
	INNER JOIN vyuICGetInventoryCountOutdatedItemStock os ON os.intInventoryCountDetailId = cd.intInventoryCountDetailId
WHERE cd.intInventoryCountId = @intInventoryCountId

-- UPDATE cd
-- SET dblSystemCount = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN nonLotted.dblOnHand ELSE lotted.dblOnHand END, 0),
-- 	dblWeightQty = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE lotted.dblWeight END, 0),
-- 	dblLastCost = ISNULL(CASE 
-- 			WHEN ItemLocation.intCostingMethod = 1 AND Item.strLotTracking = 'No'  THEN -- AVG
-- 				dbo.fnGetItemAverageCost(
-- 					cd.intItemId
-- 					, ItemLocation.intItemLocationId
-- 					, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
-- 				)
-- 			WHEN ItemLocation.intCostingMethod = 2 AND Item.strLotTracking = 'No' THEN -- FIFO
-- 				dbo.fnCalculateCostBetweenUOM(
-- 					COALESCE(FIFO.intItemUOMId, StockUOM.intItemUOMId)
-- 					,COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
-- 					,COALESCE(FIFO.dblCost, ItemPricing.dblLastCost)
-- 				)
-- 			WHEN ItemLocation.intCostingMethod = 3 AND Item.strLotTracking = 'No' THEN -- LIFO
-- 				dbo.fnCalculateCostBetweenUOM(
-- 					StockUOM.intItemUOMId
-- 					, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
-- 					, ItemPricing.dblLastCost
-- 				)
-- 			WHEN Item.strLotTracking != 'No' THEN
-- 				dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ISNULL(ItemLot.dblLastCost, ItemPricing.dblLastCost))
-- 			ELSE
-- 				dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost)
-- 		END, 0)
-- FROM tblICInventoryCountDetail cd
-- 	INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
-- 	INNER JOIN tblICItem Item ON Item.intItemId = cd.intItemId
-- 	INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = c.intLocationId
-- 		AND ItemLocation.intItemId = cd.intItemId
-- 	LEFT JOIN dbo.tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
-- 	LEFT JOIN dbo.tblICItemUOM ItemUOM ON cd.intItemUOMId = ItemUOM.intItemUOMId
-- 	LEFT JOIN dbo.tblICLot ItemLot ON ItemLot.intLotId = cd.intLotId AND Item.strLotTracking <> 'No'
-- 	LEFT JOIN dbo.tblICItemUOM StockUOM ON cd.intItemId = StockUOM.intItemId AND StockUOM.ysnStockUnit = 1
-- 	OUTER APPLY (
-- 				SELECT 
-- 					  ss.intItemId
-- 					, ss.intItemUOMId
-- 					, ss.intItemLocationId
-- 					, ss.intSubLocationId
-- 					, ss.intStorageLocationId
-- 					, dblOnHand =  SUM(COALESCE(ss.dblOnHand, 0.00))
-- 					, dblLastCost = MAX(ISNULL(ss.dblLastCost, 0))
-- 		FROM vyuICGetItemStockSummary ss
-- 		WHERE ss.intItemId = cd.intItemId
-- 			AND ss.intItemLocationId = cd.intItemLocationId
-- 			AND ss.intItemUOMId = cd.intItemUOMId
-- 			AND (
-- 				((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
-- 				((CASE WHEN cd.intSubLocationId = ss.intSubLocationId AND cd.intStorageLocationId = ss.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
-- 				((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = ss.intSubLocationId THEN 0 ELSE 1 END) = 0)
-- 			)
-- 		AND dbo.fnDateLessThanEquals(dtmDate, c.dtmCountDate) = 1
-- 	GROUP BY 
-- 					intItemId,
-- 					intItemUOMId,
-- 					intItemLocationId,
-- 					intSubLocationId,
-- 					intStorageLocationId
-- 	) nonLotted
-- 	OUTER APPLY(
-- 		SELECT TOP 1
-- 		dblCost
-- 				, intItemUOMId
-- 		FROM tblICInventoryFIFO FIFO
-- 		WHERE	Item.intItemId = FIFO.intItemId
-- 			AND ItemLocation.intItemLocationId = FIFO.intItemLocationId
-- 			AND dblStockIn - dblStockOut > 0
-- 			AND dbo.fnDateLessThanEquals(dtmDate, c.dtmCountDate) = 1
-- 		ORDER BY dtmDate ASC
-- 	) FIFO 
-- 	LEFT OUTER JOIN (
-- 		SELECT
-- 		Lot.strLotNumber,
-- 		ISNULL(Lot.dblQty, 0) dblOnHand,
-- 		ISNULL(Lot.dblWeight, 0) dblWeight,
-- 		Lot.intItemLocationId,
-- 		Lot.intItemId,
-- 		Lot.intItemUOMId,
-- 		Lot.intWeightUOMId,
-- 		Lot.intStorageLocationId,
-- 		Lot.intSubLocationId,
-- 		Lot.intLotId
-- 	FROM tblICLot Lot
-- 		INNER JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
-- 	WHERE Item.strLotTracking <> 'No'
-- 	) lotted ON lotted.intItemId = cd.intItemId
-- 		AND lotted.intItemLocationId = cd.intItemLocationId
-- 		AND lotted.intItemUOMId = cd.intItemUOMId
-- 		AND lotted.intSubLocationId = cd.intSubLocationId
-- 		AND lotted.intStorageLocationId = cd.intStorageLocationId
-- 		AND lotted.strLotNumber = cd.strLotNo
-- WHERE c.intInventoryCountId = @intInventoryCountId
-- 	AND c.ysnPosted != 1