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
)
AS

SET @dtmAsOfDate = ISNULL(@dtmAsOfDate, GETDATE())

SELECT
	  Item.intItemId
	, Item.strItemNo
	, Item.strType
	, CASE WHEN @intLotId IS NOT NULL THEN LotUOM.strUnitMeasure ELSE UOM.strUnitMeasure END strUnitMeasure
	, Lot.strLotNumber
	--, Transactions.dtmDate
	, dblOnHand = SUM(CASE WHEN @intLotId IS NOT NULL THEN Lot.dblQty ELSE dbo.fnCalculateQtyBetweenUOM(Transactions.intItemUOMId, StockUOM.intItemUOMId, Transactions.dblOnHand) END)
	, dblReserved = ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(Transactions.intItemUOMId, StockUOM.intItemUOMId, reserved.dblQty)), 0)
	, dblOnHandNoReserved = ISNULL(SUM(CASE WHEN @intLotId IS NOT NULL THEN Lot.dblQty ELSE dbo.fnCalculateQtyBetweenUOM(Transactions.intItemUOMId, StockUOM.intItemUOMId, Transactions.dblOnHand) END), 0)
		- ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(Transactions.intItemUOMId, StockUOM.intItemUOMId, reserved.dblQty)), 0)
FROM tblICItem Item
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
	INNER JOIN (
		SELECT
			  t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, t.intLotId
			, t.intItemUOMId
			, dblOnHand = SUM(t.dblQty)
		FROM tblICInventoryTransaction t
		WHERE dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @dtmAsOfDate) = 1
		GROUP BY t.intItemId, t.intItemLocationId, t.intSubLocationId, t.intStorageLocationId, t.intLotId, t.intItemUOMId
	) Transactions ON Transactions.intItemId = Item.intItemId
		AND Transactions.intItemLocationId = ItemLocation.intItemLocationId 
	INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId
	LEFT OUTER JOIN tblICLot Lot ON Lot.intLotId = @intLotId
	LEFT OUTER JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemId = Lot.intItemId
		AND LotItemUOM.intItemUOMId = Lot.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure LotUOM ON LotItemUOM.intUnitMeasureId = LotUOM.intUnitMeasureId
	OUTER APPLY (
		SELECT SUM(ReservedQty.dblQty) dblQty
		FROM (
			SELECT sr.strTransactionId, sr.dblQty dblQty
			FROM tblICStockReservation sr
				LEFT JOIN tblICInventoryTransaction xt ON xt.intTransactionId = sr.intTransactionId
			WHERE sr.intItemId = Item.intItemId
				AND sr.intItemLocationId = ItemLocation.intItemLocationId
				AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(Transactions.intStorageLocationId, 0)
				AND ISNULL(sr.intSubLocationId, 0) = ISNULL(Transactions.intSubLocationId, 0)
				AND ISNULL(sr.intLotId, 0) = ISNULL(Transactions.intLotId, 0)
				AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), xt.dtmDate,112), @dtmAsOfDate) = 1
			GROUP BY sr.strTransactionId, sr.dblQty
		) AS ReservedQty
	) reserved
WHERE 
	(Item.intItemId BETWEEN ISNULL(@intItemId, 1) AND ISNULL(@intItemId, 2147483647))
	AND (ItemLocation.intLocationId = @intLocationId OR @intLocationId IS NULL)
	AND (Transactions.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
	AND (Transactions.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
	AND (Transactions.intLotId = @intLotId OR @intLotId IS NULL)
	AND (Item.intCategoryId = @intCategoryId OR @intCategoryId IS NULL)
	AND (Item.intCommodityId = @intCommodityId OR @intCommodityId IS NULL)
	AND Item.strType = 'Inventory'
	AND (Item.strStatus = 'Active' AND @ysnActiveOnly = 1 OR NULLIF(@ysnActiveOnly, 0) IS NULL)
GROUP BY Item.intItemId, Item.strItemNo, Item.strType, UOM.strUnitMeasure, Lot.strLotNumber, LotUOM.strUnitMeasure--,  Transactions.dtmDate
ORDER BY Item.strItemNo