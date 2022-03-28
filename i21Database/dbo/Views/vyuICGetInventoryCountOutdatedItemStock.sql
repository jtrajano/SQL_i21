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
	, dblNewOnHand = SUM(x.dblNewOnHand)
	, x.dblWeightQty
	, x.dblNewWeightQty
	, x.dblCost
	, x.dblNewCost
	, dblOnHandDiff = SUM(x.dblNewOnHand) - x.dblCountOnHand
	, dblWeightQtyDiff = x.dblNewWeightQty - x.dblWeightQty
	, dblCostDiff = x.dblNewCost - x.dblCost
	, x.intLotId
	, x.strLotNo
FROM
(
	SELECT
		Item.intItemId
		,Item.strItemNo
		,cd.intInventoryCountDetailId
		,cd.strCountLine
		,c.strCountNo
		,c.intInventoryCountId
		,dblNewOnHand = 
			ISNULL(
				CASE 
					WHEN Item.strLotTracking = 'No' THEN 
						dbo.fnCalculateQtyBetweenUOM(nonLotted.intItemUOMId, StockUOM.intItemUOMId, nonLotted.dblOnHand) 
					ELSE 
						LotTransactions.dblOnHand 
				END
				, 0
			)
			
		,dblCountOnHand = cd.dblSystemCount
		,cd.dblWeightQty
		,dblNewWeightQty = ISNULL(CASE WHEN Item.strLotTracking = 'No' THEN 0 ELSE lotted.dblWeight END, 0)
		,dblNewCost = ISNULL(CASE WHEN c.strDataSource = 'Import CSV' THEN cd.dblLastCost ELSE CASE 
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
								WHEN Item.strLotTracking <> 'No' THEN
									ISNULL(ItemLot.dblLastCost, dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost))
								ELSE
									dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, cd.intItemUOMId, ItemPricing.dblLastCost)
							END END, 0)
		,dblCost = cd.dblLastCost
		,intLotId = cd.intLotId
		,strLotNo = cd.strLotNo
	FROM 
		tblICInventoryCountDetail cd INNER JOIN tblICInventoryCount c 
			ON cd.intInventoryCountId = c.intInventoryCountId
		INNER JOIN tblICItem Item 
			ON Item.intItemId = cd.intItemId
		INNER JOIN dbo.tblICItemLocation ItemLocation 
			ON ItemLocation.intLocationId = c.intLocationId
			AND ItemLocation.intItemId = cd.intItemId
		LEFT JOIN dbo.tblICItemPricing ItemPricing 
			ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
			AND ItemPricing.intItemId = Item.intItemId
		LEFT JOIN dbo.tblICItemUOM ItemUOM 
			ON cd.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN dbo.tblICLot ItemLot 
			ON ItemLot.intLotId = cd.intLotId AND Item.strLotTracking <> 'No'
		LEFT JOIN dbo.tblICItemUOM StockUOM 
			ON cd.intItemId = StockUOM.intItemId 
			AND StockUOM.ysnStockUnit = 1
		OUTER APPLY (
			SELECT 
				  ss.intItemId
				, ss.intItemUOMId
				, dblOnHand =  SUM(COALESCE(ss.dblOnHand, 0.00))
			FROM vyuICGetItemStockSummary ss
				INNER JOIN tblICItem i ON i.intItemId = ss.intItemId
			WHERE 
				ss.intItemId = cd.intItemId
				AND ss.intItemLocationId = cd.intItemLocationId
				--AND (ss.intSubLocationId = cd.intSubLocationId OR NULLIF(cd.intSubLocationId, 0) IS NULL) 
				--AND (ss.intStorageLocationId = cd.intStorageLocationId OR NULLIF(cd.intSubLocationId, 0) IS NULL) 
				AND (
					ss.intSubLocationId = cd.intSubLocationId 
					OR (ss.intSubLocationId IS NULL AND NULLIF(cd.intSubLocationId, 0) IS NULL)					
				)
				AND (
					ss.intStorageLocationId = cd.intStorageLocationId 
					OR (ss.intStorageLocationId IS NULL AND NULLIF(cd.intStorageLocationId, 0) IS NULL) 
				)
				AND FLOOR(CAST(ss.dtmDate AS FLOAT)) <= FLOOR(CAST(c.dtmCountDate AS FLOAT))
				AND i.strLotTracking = 'No'
			GROUP BY 
				ss.intItemId,
				intItemUOMId
		) nonLotted
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
		LEFT OUTER JOIN (
			SELECT
				Lot.strLotNumber,
				ISNULL(Lot.dblQty, 0) dblOnHand,
				ISNULL(Lot.dblWeight, 0) dblWeight,
				Lot.intItemLocationId,
				Lot.intItemId,
				Lot.intItemUOMId,
				Lot.intWeightUOMId,
				Lot.intStorageLocationId,
				Lot.intSubLocationId,
				Lot.intLotId
			FROM tblICLot Lot
				INNER JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
			WHERE Item.strLotTracking <> 'No'
		) lotted
			ON lotted.intItemId = cd.intItemId
			AND lotted.intItemLocationId = cd.intItemLocationId
			AND lotted.intItemUOMId = cd.intItemUOMId
			AND lotted.intSubLocationId = cd.intSubLocationId
			AND lotted.intStorageLocationId = cd.intStorageLocationId
			AND lotted.strLotNumber = cd.strLotNo
		OUTER APPLY (
			SELECT					
				 dblOnHand = SUM(t.dblQty)
			FROM 
				tblICInventoryTransaction t
			WHERE 
				t.intItemId = Item.intItemId
				AND t.intItemLocationId = ItemLocation.intItemLocationId
				AND t.intSubLocationId = cd.intSubLocationId
				AND t.intStorageLocationId = cd.intStorageLocationId
				AND t.intLotId = cd.intLotId
				AND t.intItemUOMId = cd.intItemUOMId						
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(c.dtmCountDate AS FLOAT))
		) LotTransactions 			
	WHERE c.ysnPosted <> 1
) x
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
	, x.intLotId
	, x.strLotNo
HAVING 
	ROUND(SUM(x.dblNewOnHand) - x.dblCountOnHand, 6) <> 0