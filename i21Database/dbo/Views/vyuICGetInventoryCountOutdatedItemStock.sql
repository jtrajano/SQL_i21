CREATE VIEW [dbo].[vyuICGetInventoryCountOutdatedItemStock]
AS

SELECT
	  x.intInventoryCountId
	, x.intInventoryCountDetailId
	, x.strCountNo
	, x.strCountLine
	, x.intItemId
	, x.strItemNo
	, x.dblCountOnHand
	, dblNewOnHand = (SUM(x.dblNewOnHand) - CASE WHEN x.ysnExcludeReserved = 1 THEN x.dblReservedQty ELSE 0 END)
	, x.dblWeightQty
	, x.dblNewWeightQty
	, x.dblCost
	, x.dblNewCost
	, dblOnHandDiff = (SUM(x.dblNewOnHand) - CASE WHEN x.ysnExcludeReserved = 1 THEN x.dblReservedQty ELSE 0 END) - x.dblCountOnHand
	, dblWeightQtyDiff = x.dblNewWeightQty - x.dblWeightQty
	, dblCostDiff = x.dblNewCost - x.dblCost
	, x.intLotId
	, x.strLotNo
FROM
(
	SELECT
		Item.intItemId,
		Item.strItemNo,
		cd.intInventoryCountDetailId,
		cd.strCountLine,
		c.strCountNo,
		c.intInventoryCountId,
		c.ysnExcludeReserved,
		ISNULL(reserved.dblQty, 0) dblReservedQty,
		dblNewOnHand = 
			ISNULL(
				CASE 
					WHEN Item.strLotTracking = 'No' THEN dbo.fnCalculateQtyBetweenUOM(nonLotted.intItemUOMId, StockUOM.intItemUOMId, nonLotted.dblOnHand) 
					ELSE LotTransactions.dblQty 
				END
				, 0
			),
		dblCountOnHand = cd.dblSystemCount,
		cd.dblWeightQty,
		dblNewWeightQty = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE LotTransactions.dblWeight END, 0),
		dblNewCost = ISNULL(CASE WHEN c.strDataSource = 'Import CSV' THEN cd.dblLastCost ELSE CASE 
								WHEN ItemLocation.intCostingMethod = 1 AND Item.strLotTracking = 'No'  THEN -- AVG
									dbo.fnGetItemAverageCost(
										cd.intItemId
										, ItemLocation.intItemLocationId
										, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
									)
								WHEN ItemLocation.intCostingMethod = 2 AND Item.strLotTracking = 'No' THEN -- FIFO
									dbo.fnCalculateCostBetweenUOM(
										COALESCE(FIFO.intItemUOMId, StockUOM.intItemUOMId)
										,COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
										,COALESCE(FIFO.dblCost, ItemPricing.dblLastCost)
									)
								WHEN ItemLocation.intCostingMethod = 3 AND Item.strLotTracking = 'No' THEN -- LIFO
									dbo.fnCalculateCostBetweenUOM(
										StockUOM.intItemUOMId
										, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
										, ItemPricing.dblLastCost
									)
								WHEN Item.strLotTracking != 'No' THEN
									ISNULL(ItemLot.dblLastCost, dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost))
								ELSE
									dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost)
							END END, 0),
		dblCost = cd.dblLastCost,
		intLotId = cd.intLotId,
		strLotNo = cd.strLotNo
	FROM tblICInventoryCountDetail cd
		INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
		INNER JOIN tblICItem Item ON Item.intItemId = cd.intItemId
		INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = c.intLocationId
			AND ItemLocation.intItemId = cd.intItemId
		LEFT JOIN dbo.tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		LEFT JOIN dbo.tblICItemUOM ItemUOM ON cd.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN dbo.tblICLot ItemLot ON ItemLot.intLotId = cd.intLotId AND Item.strLotTracking <> 'No'
		LEFT JOIN dbo.tblICItemUOM StockUOM ON cd.intItemId = StockUOM.intItemId AND StockUOM.ysnStockUnit = 1
		LEFT JOIN (
			SELECT 
				ss.intItemId
				, ss.intItemUOMId
				, ss.intItemLocationId
				, ss.intSubLocationId
				, ss.intStorageLocationId
				, dblOnHand =  SUM(COALESCE(ss.dblOnHand, 0.00))
				, dblLastCost = MAX(ISNULL(ss.dblLastCost, 0))
				, dtmDate
			FROM vyuICGetItemStockSummary ss
			GROUP BY 
				ss.intItemId,
				intItemUOMId,
				intItemLocationId,
				intSubLocationId,
				intStorageLocationId,
				dtmDate
		) nonLotted ON nonLotted.intItemId = cd.intItemId
			AND nonLotted.intItemLocationId = cd.intItemLocationId
			--AND ss.intItemUOMId = cd.intItemUOMId
			AND (
				((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId = nonLotted.intSubLocationId AND cd.intStorageLocationId = nonLotted.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = nonLotted.intSubLocationId THEN 0 ELSE 1 END) = 0)
			)
			AND (
				(c.strCountBy = 'Item' AND dbo.fnDateLessThanEquals(nonLotted.dtmDate, c.dtmCountDate) = 1)
				OR (c.strCountBy = 'Retail Count' AND dbo.fnDateLessThan(nonLotted.dtmDate, c.dtmCountDate) = 1) 
			)
			AND Item.strLotTracking = 'No'
		OUTER APPLY(
			SELECT TOP 1
			dblCost
					, intItemUOMId
			FROM tblICInventoryFIFO FIFO
			WHERE	Item.intItemId = FIFO.intItemId
				AND ItemLocation.intItemLocationId = FIFO.intItemLocationId
				AND dblStockIn - dblStockOut > 0
				AND dbo.fnDateLessThanEquals(dtmDate, c.dtmCountDate) = 1
			ORDER BY dtmDate ASC
		) FIFO 
		OUTER APPLY (
			SELECT 
				dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, l.intItemUOMId, t.dblQty)) 
				, dblWeight = 
					SUM(
						CASE 
							WHEN l.intWeightUOMId IS NOT NULL THEN 
								CASE 
									WHEN t.intItemUOMId = l.intWeightUOMId THEN t.dblQty 
									WHEN t.intItemUOMId = t.intItemUOMId THEN dbo.fnMultiply(t.dblQty, ISNULL(l.dblWeightPerQty, 0)) 
									ELSE 0
								END 
							ELSE 
								0
						END 
					)
			FROM tblICInventoryTransaction t INNER JOIN tblICLot l
					ON t.intLotId = l.intLotId
			WHERE
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				AND t.intSubLocationId = cd.intSubLocationId
				AND t.intStorageLocationId = cd.intStorageLocationId
				AND t.intLotId = cd.intLotId
				AND dbo.fnDateLessThanEquals(t.dtmDate, c.dtmCountDate) = 1
		) LotTransactions 
		OUTER APPLY (
			SELECT SUM(ReservedQty.dblQty) dblQty
			FROM (
				SELECT sr.strTransactionId, sr.dblQty dblQty
				FROM tblICStockReservation sr
					LEFT JOIN tblICInventoryTransaction xt ON xt.intTransactionId = sr.intTransactionId
				WHERE sr.intItemId = cd.intItemId
					AND sr.intItemLocationId = cd.intItemLocationId
					AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(cd.intStorageLocationId, 0)
					AND ISNULL(sr.intSubLocationId, 0) = ISNULL(cd.intSubLocationId, 0)
					AND ISNULL(sr.intLotId, 0) = ISNULL(cd.intLotId, 0)
					AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), xt.dtmDate,112), c.dtmCountDate) = 1
				GROUP BY sr.strTransactionId, sr.dblQty
			) AS ReservedQty
		) reserved
	WHERE c.ysnPosted != 1
) x
--WHERE ((ROUND(x.dblNewOnHand - x.dblCountOnHand, 6) != 0) OR (ROUND(x.dblNewCost - x.dblCost, 6) != 0))
GROUP BY x.intInventoryCountId
	, x.intInventoryCountDetailId
	, x.strCountNo
	, x.strCountLine
	, x.intItemId
	, x.strItemNo
	, x.dblCountOnHand
	--, x.dblNewOnHand
	, x.dblWeightQty
	, x.dblNewWeightQty
	, x.dblCost
	, x.dblNewCost
	, x.dblReservedQty
	, x.ysnExcludeReserved
	, x.intLotId
	, x.strLotNo
-- HAVING ((ROUND(SUM(x.dblNewOnHand) - x.dblCountOnHand, 6) != 0) OR (ROUND(x.dblNewCost - x.dblCost, 6) != 0))
HAVING ((ROUND((SUM(x.dblNewOnHand) - CASE WHEN x.ysnExcludeReserved = 1 THEN x.dblReservedQty ELSE 0 END) - x.dblCountOnHand, 6) != 0))