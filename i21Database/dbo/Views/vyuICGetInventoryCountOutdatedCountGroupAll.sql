CREATE VIEW [dbo].[vyuICGetInventoryCountOutdatedCountGroupAll]
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
		ysnExcludeReserved = 0,--c.ysnExcludeReserved, -- Default to zero because ysnExcludeReserved is not yet added in 19.2. It is included in 20.1
		ISNULL(reserved.dblQty, 0) dblReservedQty,
		dblNewOnHand = 
			ISNULL(
				CASE 
					WHEN Item.strLotTracking = 'No' THEN 
						CASE 
							WHEN c.strCountBy = 'Pack' THEN 
								dbo.fnCalculateQtyBetweenUOM(stockByPackUOM.intItemUOMId, cd.intItemUOMId, stockByPackUOM.dblOnHand)
							WHEN Item.ysnSeparateStockForUOMs = 1 THEN 
								separateUOM.dblOnHand
							WHEN ISNULL(Item.ysnSeparateStockForUOMs, 0) = 0 THEN 
								byStockUOM.dblOnHand								
							ELSE 
								dbo.fnCalculateQtyBetweenUOM(byStockUOM.intItemUOMId, StockUOM.intItemUOMId, byStockUOM.dblOnHand)
						END
					ELSE 
						LotTransactions.dblQty 
				END
				, 0
			),
		dblCountOnHand = cd.dblSystemCount,
		cd.dblWeightQty,
		dblNewWeightQty = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE LotTransactions.dblWeight END, 0),
		dblNewCost = 
			ISNULL(
				CASE 
					WHEN c.strDataSource = 'Import CSV' THEN 
						cd.dblLastCost 
					ELSE 
						CASE 
							WHEN ItemLocation.intCostingMethod = 1 AND Item.strLotTracking = 'No'  THEN -- AVG
								dbo.fnGetItemAverageCost(
									cd.intItemId
									, ItemLocation.intItemLocationId
									, COALESCE(cd.intItemUOMId, StockUOM.intItemUOMId)
								)
							ELSE 
								dbo.fnCalculateCostBetweenUOM(lastCost.intItemUOMId, cd.intItemUOMId, lastCost.dblLastCost) 
						END 
					END
					, 0
				),
		dblCost = cd.dblLastCost,
		intLotId = cd.intLotId,
		strLotNo = cd.strLotNo
	FROM tblICInventoryCountDetail cd
		INNER JOIN tblICInventoryCount c ON cd.intInventoryCountId = c.intInventoryCountId
		-- INNER JOIN tblICItemCache cache ON cache.intItemId = cd.intItemId
		INNER JOIN tblICItem Item ON Item.intItemId = cd.intItemId
		INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = c.intLocationId
			AND ItemLocation.intItemId = cd.intItemId
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
				, dtmDate
			FROM vyuICGetRunningStockQtyByUOM ss
			GROUP BY 
				ss.intItemId,
				intItemUOMId,
				intItemLocationId,
				intSubLocationId,
				intStorageLocationId,
				dtmDate
		) separateUOM 
			ON separateUOM.intItemId = cd.intItemId
			AND separateUOM.intItemLocationId = cd.intItemLocationId
			AND separateUOM.intItemUOMId = cd.intItemUOMId
			AND (
				((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId = separateUOM.intSubLocationId AND cd.intStorageLocationId = separateUOM.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = separateUOM.intSubLocationId THEN 0 ELSE 1 END) = 0)
			)
			AND (
				(c.strCountBy = 'Item' AND dbo.fnDateLessThanEquals(separateUOM.dtmDate, c.dtmCountDate) = 1)
				OR (c.strCountBy = 'Retail Count' AND dbo.fnDateLessThan(separateUOM.dtmDate, c.dtmCountDate) = 1) 
			)
			AND Item.strLotTracking = 'No'
			AND Item.ysnSeparateStockForUOMs = 1
		LEFT JOIN (
			SELECT 
				ss.intItemId
				, ss.intItemUOMId
				, ss.intItemLocationId
				, ss.intSubLocationId
				, ss.intStorageLocationId
				, dblOnHand = SUM(COALESCE(ss.dblOnHand, 0.00))
				, dtmDate
			FROM vyuICGetRunningStockQtyByStockUOM ss
			GROUP BY 
				ss.intItemId,
				intItemUOMId,
				intItemLocationId,
				intSubLocationId,
				intStorageLocationId,
				dtmDate
		) byStockUOM 
			ON byStockUOM.intItemId = cd.intItemId
			AND byStockUOM.intItemLocationId = cd.intItemLocationId
			AND byStockUOM.intItemUOMId = cd.intItemUOMId
			AND (
				((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId = byStockUOM.intSubLocationId AND cd.intStorageLocationId = byStockUOM.intStorageLocationId THEN 0 ELSE 1 END) = 0) OR
				((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = byStockUOM.intSubLocationId THEN 0 ELSE 1 END) = 0)
			)
			AND (
				(c.strCountBy = 'Item' AND dbo.fnDateLessThanEquals(byStockUOM.dtmDate, c.dtmCountDate) = 1)
				OR (c.strCountBy = 'Retail Count' AND dbo.fnDateLessThan(byStockUOM.dtmDate, c.dtmCountDate) = 1) 
			)
			AND Item.strLotTracking = 'No'
			AND ISNULL(Item.ysnSeparateStockForUOMs, 0) = 0
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
				CROSS APPLY dbo.udfDateLessThanEquals(t.dtmDate, c.dtmCountDate) 
			WHERE
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				AND t.intSubLocationId = cd.intSubLocationId
				AND t.intStorageLocationId = cd.intStorageLocationId
				AND t.intLotId = cd.intLotId
				AND dbo.fnDateLessThanEquals(t.dtmDate, c.dtmCountDate) = 1
		) LotTransactions
		OUTER APPLY (
			SELECT	v.intItemId
					,u.intItemUOMId
					,v.intItemLocationId
					,v.intSubLocationId
					,v.intStorageLocationId
					,dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(v.intItemUOMId, u.intItemUOMId, v.dblQty))
			FROM	tblICInventoryTransaction v
					INNER JOIN tblICItemUOM u
						ON v.intItemId = u.intItemId
						AND u.ysnStockUnit = 1
			WHERE	
					v.intItemId = Item.intItemId
					AND v.intItemLocationId = ItemLocation.intItemLocationId
					AND dbo.fnDateLessThanEquals(v.dtmDate, c.dtmCountDate) = 1
			GROUP BY 
					v.intItemId
					,u.intItemUOMId
					,v.intItemLocationId
					,v.intSubLocationId
					,v.intStorageLocationId		
		) stockByPackUOM

		OUTER APPLY (
			SELECT 
				dblQty = SUM(ReservedQty.dblQty) 
			FROM (
				SELECT sr.strTransactionId, sr.dblQty dblQty
				FROM 
					tblICStockReservation sr
					LEFT JOIN tblICInventoryTransaction xt 
						ON xt.intTransactionId = sr.intTransactionId
					CROSS APPLY dbo.udfDateLessThanEquals(CONVERT(VARCHAR(10), xt.dtmDate,112), c.dtmCountDate) 
				WHERE sr.intItemId = cd.intItemId
					AND sr.intItemLocationId = cd.intItemLocationId
					AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(cd.intStorageLocationId, 0)
					AND ISNULL(sr.intSubLocationId, 0) = ISNULL(cd.intSubLocationId, 0)
					AND ISNULL(sr.intLotId, 0) = ISNULL(cd.intLotId, 0)
					
				GROUP BY sr.strTransactionId, sr.dblQty
			) AS ReservedQty
		) reserved

		OUTER APPLY (
			SELECT TOP 1
				dblLastCost = t.dblCost 
				,t.intItemUOMId 
			FROM 
				tblICInventoryTransaction t 
				CROSS APPLY dbo.udfDateLessThanEquals(t.dtmDate, c.dtmCountDate)
			WHERE
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				
				AND (
					((CASE WHEN cd.intSubLocationId IS NULL AND cd.intStorageLocationId IS NULL THEN 1 ELSE 0 END) = 1) OR
					((CASE WHEN cd.intSubLocationId = t.intSubLocationId AND cd.intStorageLocationId = t.intStorageLocationId THEN 1 ELSE 0 END) = 1) OR
					((CASE WHEN cd.intSubLocationId IS NOT NULL AND cd.intStorageLocationId IS NULL AND cd.intSubLocationId = t.intSubLocationId THEN 1 ELSE 0 END) = 1)
				)
				AND ISNULL(t.intLotId, 0) = ISNULL(cd.intLotId, 0) 
				AND t.ysnIsUnposted = 0 
			ORDER BY
				t.dtmDate DESC 
				,t.intInventoryTransactionId DESC 
		) lastCost  
	WHERE 
		c.ysnPosted <> 1
		AND c.strCountBy = 'Retail Count'
		-- AND cache.dtmDateLastUpdated > COALESCE(c.dtmDateModified, c.dtmDateCreated, c.dtmCountDate)
) x

GROUP BY x.intInventoryCountId
	, x.intInventoryCountDetailId
	, x.strCountNo
	, x.strCountLine
	, x.intItemId
	, x.strItemNo
	, x.dblCountOnHand
	, x.dblWeightQty
	, x.dblNewWeightQty
	, x.dblCost
	, x.dblNewCost
	, x.dblReservedQty
	, x.ysnExcludeReserved
	, x.intLotId
	, x.strLotNo
HAVING ((ROUND((SUM(x.dblNewOnHand) - CASE WHEN x.ysnExcludeReserved = 1 THEN x.dblReservedQty ELSE 0 END) - x.dblCountOnHand, 6) != 0))
