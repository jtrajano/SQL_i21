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
WHERE 
	(Item.intItemId BETWEEN ISNULL(@intItemId, 1) AND ISNULL(@intItemId, 2147483647))
	AND (ItemLocation.intLocationId = @intLocationId OR @intLocationId IS NULL)
	AND (Transactions.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
	AND (Transactions.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
	AND (Transactions.intLotId = @intLotId OR @intLotId IS NULL)
	AND (Item.intCategoryId = @intCategoryId OR @intCategoryId IS NULL)
	AND (Item.intCommodityId = @intCommodityId OR @intCommodityId IS NULL)
	AND Item.strType IN ('Inventory', 'Raw Material', 'Finished Good')
	AND (Item.strStatus = 'Active' AND @ysnActiveOnly = 1 OR NULLIF(@ysnActiveOnly, 0) IS NULL)
GROUP BY Item.intItemId, Item.strItemNo, Item.strType, UOM.strUnitMeasure, Lot.strLotNumber, LotUOM.strUnitMeasure--,  Transactions.dtmDate
ORDER BY Item.strItemNo