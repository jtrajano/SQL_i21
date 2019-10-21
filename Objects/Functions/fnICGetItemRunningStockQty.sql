CREATE FUNCTION dbo.fnICGetItemRunningStockQty (
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
RETURNS NUMERIC(38, 20)
AS
BEGIN

SET @dtmAsOfDate = ISNULL(@dtmAsOfDate, GETDATE())
DECLARE @dblOnHand NUMERIC(38, 20)

SELECT @dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(Transactions.intItemUOMId, StockUOM.intItemUOMId, Transactions.dblOnHand))
FROM tblICItem Item
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
	INNER JOIN (
		SELECT
			  t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, t.intItemUOMId
			, dtmDate = CAST(CONVERT(VARCHAR(10), t.dtmDate,112) AS DATETIME)
			, dblOnHand = SUM(t.dblQty)
		FROM tblICInventoryTransaction t
		GROUP BY t.intItemId, t.intItemLocationId, t.intSubLocationId, t.intStorageLocationId, t.intItemUOMId, CONVERT(VARCHAR(10), t.dtmDate,112)
	) Transactions ON Transactions.intItemId = Item.intItemId
		AND Transactions.intItemLocationId = ItemLocation.intItemLocationId 
	INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
		AND StockUOM.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = StockUOM.intUnitMeasureId
	LEFT OUTER JOIN tblICLot Lot ON Lot.intLotId = @intLotId
WHERE 
	(Item.intItemId BETWEEN ISNULL(@intItemId, 1) AND ISNULL(@intItemId, 2147483647))
	AND dbo.fnDateLessThanEquals(Transactions.dtmDate, @dtmAsOfDate) = 1
	AND (ItemLocation.intLocationId = @intLocationId OR @intLocationId IS NULL)
	AND (Transactions.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
	AND (Transactions.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
	AND (Item.intCategoryId = @intCategoryId OR @intCategoryId IS NULL)
	AND (Item.intCommodityId = @intCommodityId OR @intCommodityId IS NULL)
	AND Item.strType IN ('Inventory', 'Raw Material', 'Finished Good')
	AND (Item.strStatus = 'Active' AND @ysnActiveOnly = 1 OR NULLIF(@ysnActiveOnly, 0) IS NULL)
GROUP BY Item.intItemId, Item.strItemNo, Item.strType, UOM.strUnitMeasure, Lot.strLotNumber
ORDER BY Item.strItemNo

RETURN @dblOnHand

END