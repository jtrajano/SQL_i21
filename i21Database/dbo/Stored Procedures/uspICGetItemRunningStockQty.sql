CREATE PROCEDURE dbo.uspICGetItemRunningStockQty (
	  @intItemId INT = NULL
	, @intLocationId INT = NULL
	, @intLotId INT = NULL
	, @intStorageLocationId INT = NULL
	, @intStorageUnitId INT = NULL
	, @intCommodityId INT = NULL
	, @intCategoryId INT = NULL
	, @dtmAsOfDate DATETIME = NULL
	, @ysnActiveOnly BIT = 1
	, @intItemUOMId INT = NULL
)
AS

SET @dtmAsOfDate = ISNULL(@dtmAsOfDate, GETDATE())

SELECT
	  Item.intItemId
	, Item.strItemNo
	, Item.strType
	, strUnitMeasure = uom.strUnitMeasure
	, lot.strLotNumber
	, dblOnHand = 
			CASE 
				WHEN @intLotId IS NOT NULL THEN ISNULL(lot.dblQty, 0)
				WHEN @intItemUOMId IS NULL THEN ISNULL(transactions.dblOnHandInStockUOM, 0)
				WHEN @intItemUOMId IS NOT NULL THEN ISNULL(transactions.dblOnHand, 0)
			END		

	, dblReserved = 
			CASE 
				WHEN @intItemUOMId IS NULL THEN ISNULL(reserved.dblQtyInStockUOM, 0)
				WHEN @intItemUOMId IS NOT NULL THEN ISNULL(reserved.dblQty, 0)
			END			

	, dblOnHandNoReserved = 			
			CASE 
				WHEN @intLotId IS NOT NULL THEN ISNULL(lot.dblQty, 0)
				WHEN @intItemUOMId IS NULL THEN ISNULL(transactions.dblOnHandInStockUOM, 0)
				WHEN @intItemUOMId IS NOT NULL THEN ISNULL(transactions.dblOnHand, 0)
			END
			- CASE 
				WHEN @intItemUOMId IS NULL THEN ISNULL(reserved.dblQtyInStockUOM, 0)
				WHEN @intItemUOMId IS NOT NULL THEN ISNULL(reserved.dblQty, 0)
			END

	, dblCost = 
			CASE 
				-- Get the average cost. 
				WHEN ItemLocation.intCostingMethod = 1 THEN 
					dbo.fnCalculateCostBetweenUOM (
						StockUOM.intItemUOMId
						,COALESCE(@intItemUOMId, StockUOM.intItemUOMId)
						,dbo.fnICGetMovingAverageCost(
							Item.intItemId
							,ItemLocation.intItemLocationId
							,lastTransaction.intInventoryTransactionId
						)					
					)
					
				-- Or else, get the last cost. 
				ELSE 
					dbo.fnCalculateQtyBetweenUOM (
						lastTransaction.intItemUOMId
						, COALESCE(lot.intItemUOMId, @intItemUOMId, StockUOM.intItemUOMId)
						, lastTransaction.dblCost
					)
			END 

FROM 
	tblICItem Item
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Item.intItemId	
	INNER JOIN tblICItemUOM StockUOM 
		ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure UOM 
		ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId

	CROSS APPLY (
		SELECT
			  t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, t.intLotId
			, dblOnHand = SUM(t.dblQty)
			, dblOnHandInStockUOM = 
				SUM (
					dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, StockUOM.intItemUOMId, t.dblQty) 
				)
		FROM 
			tblICInventoryTransaction t
			INNER JOIN tblICItemUOM StockUOM 
				ON StockUOM.intItemId = Item.intItemId
				AND StockUOM.ysnStockUnit = 1
			INNER JOIN tblICUnitMeasure UOM 
				ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId

		WHERE 
			dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @dtmAsOfDate) = 1
			AND t.intItemId = Item.intItemId
			AND t.intItemLocationId = ItemLocation.intItemLocationId 
			AND (t.intItemUOMId = @intItemUOMId OR @intItemUOMId IS NULL) 
			AND (t.intLotId = @intLotId OR @intLotId IS NULL) 
		GROUP BY 
			t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, t.intLotId
	) transactions 

	OUTER APPLY (
		SELECT 
			dblQty = SUM(ISNULL(l.dblQty, 0))
			,dblWeight = SUM(ISNULL(l.dblWeight, 0)) 
			,l.strLotNumber			
			,l.intItemUOMId
			,LotUOM.strUnitMeasure
			,l.intSubLocationId
			,l.intStorageLocationId
		FROM 
			tblICLot l
			LEFT OUTER JOIN tblICItemUOM LotItemUOM 
				ON LotItemUOM.intItemId = l.intItemId
				AND LotItemUOM.intItemUOMId = l.intItemUOMId
			LEFT OUTER JOIN tblICUnitMeasure LotUOM 
				ON LotItemUOM.intUnitMeasureId = LotUOM.intUnitMeasureId

		WHERE
			l.intLotId = @intLotId
			AND l.intItemId = @intItemId
			AND l.intItemLocationId = ItemLocation.intItemLocationId	
		GROUP BY
			l.strLotNumber
			,l.intItemUOMId
			,LotUOM.strUnitMeasure
			,l.intSubLocationId
			,l.intStorageLocationId
	) lot

	OUTER APPLY (
		SELECT 
			dblQty = sum(sr.dblQty)
			,dblQtyInStockUOM = sum(dbo.fnCalculateQtyBetweenUOM(sr.intItemUOMId, StockUOM.intItemUOMId, sr.dblQty)) 
		FROM 
			tblICStockReservation sr
			INNER JOIN tblICItemUOM StockUOM 
				ON StockUOM.intItemId = sr.intItemId
				AND StockUOM.ysnStockUnit = 1
		WHERE 
			sr.intItemId = Item.intItemId
			AND sr.intItemLocationId = ItemLocation.intItemLocationId
			AND (dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), sr.dtmDate,112), @dtmAsOfDate) = 1 OR sr.dtmDate IS NULL) 
			AND ISNULL(sr.intStorageLocationId, 0) = COALESCE(lot.intStorageLocationId, transactions.intStorageLocationId, 0)
			AND ISNULL(sr.intSubLocationId, 0) = COALESCE(lot.intSubLocationId, transactions.intSubLocationId, 0)
			AND ISNULL(sr.intLotId, 0) = COALESCE(@intLotId, transactions.intLotId, 0)			
			AND sr.intItemUOMId = COALESCE(lot.intItemUOMId, @intItemUOMId, sr.intItemUOMId) 
	) reserved

	OUTER APPLY (
		SELECT 
			ItemUOM.intItemUOMId
			,UOM.strUnitMeasure
		FROM 
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure UOM 
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE
			ItemUOM.intItemUOMId = 
				CASE 
					WHEN @intLotId IS NOT NULL THEN lot.intItemUOMId
					WHEN @intItemUOMId IS NOT NULL THEN @intItemUOMId	
					ELSE StockUOM.intItemUOMId
				END 
	) uom

	OUTER APPLY (
		SELECT
			TOP 1 
			t.intItemUOMId
			,t.dblCost
			,t.intInventoryTransactionId
		FROM 
			tblICInventoryTransaction t
		WHERE 
			t.intItemId = Item.intItemId
			AND t.intItemLocationId = ItemLocation.intItemLocationId 
			AND (t.intLotId = @intLotId OR @intLotId IS NULL) 
			AND t.dblQty > 0 
			AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @dtmAsOfDate) = 1
		ORDER BY
			t.intInventoryTransactionId DESC 		
	) lastTransaction 

WHERE 
	(Item.intItemId = @intItemId OR @intItemId IS NULL) 
	AND (ItemLocation.intLocationId = @intLocationId OR @intLocationId IS NULL)
	AND (transactions.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
	AND (transactions.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
	AND (transactions.intLotId = @intLotId OR @intLotId IS NULL)
	AND (Item.intCategoryId = @intCategoryId OR @intCategoryId IS NULL)
	AND (Item.intCommodityId = @intCommodityId OR @intCommodityId IS NULL)
	AND Item.strType = 'Inventory'
	AND (Item.strStatus = 'Active' AND @ysnActiveOnly = 1 OR NULLIF(@ysnActiveOnly, 0) IS NULL)
	
