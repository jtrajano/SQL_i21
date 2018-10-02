CREATE PROCEDURE [dbo].[uspICUpdateInventoryCountDetails]
	  @intInventoryCountId INT
	, @intEntityUserSecurityId INT
	, @strHeaderNo NVARCHAR(50)
	, @intLocationId INT = 0
	, @intCategoryId INT = 0
	, @intCommodityId INT = 0
	, @intCountGroupId INT = 0
	, @intSubLocationId INT = 0
	, @intStorageLocationId INT = 0
	, @ysnIncludeZeroOnHand BIT = 0
	, @ysnCountByLots BIT = 0
	, @AsOfDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE FROM tblICInventoryCountDetail
WHERE intInventoryCountId = @intInventoryCountId

IF @ysnCountByLots = 1
BEGIN
	INSERT INTO tblICInventoryCountDetail(
		  intInventoryCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intParentLotId
		, strParentLotNo
		, strParentLotAlias
		, intLotId
		, strLotNo
		, strLotAlias
		, dblSystemCount
		, dblWeightQty
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, intWeightUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort
		, dblPhysicalCount
	)
	SELECT 	intInventoryCountId = @intInventoryCountId
			, Item.intItemId
			, ItemLocation.intItemLocationId
			, Lot.intSubLocationId
			, Lot.intStorageLocationId
			, Lot.intParentLotId
			, ParentLot.strParentLotNumber
			, ParentLot.strParentLotAlias
			, intLotId
			, strLotNumber
			, strLotAlias
			, dblSystemCount = ISNULL(dblQty, 0)
			, dblWeightQty = Lot.dblWeight
			, dblLastCost = 
				-- Convert the last cost from Stock UOM to Lot's Pack UOM. 
				dbo.fnCalculateCostBetweenUOM(
					StockUOM.intItemUOMId
					, Lot.intItemUOMId
					, Lot.dblLastCost
				) 
			, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY Lot.intItemId ASC) AS NVARCHAR(50))
			, Lot.intItemUOMId
			, Lot.intWeightUOMId
			, ysnRecount = 0
			, ysnFetched = 1
			, intEntityUserSecurityId = @intEntityUserSecurityId
			, intConcurrencyId = 1
			, intSort = 1
			, dblPhysicalCount = NULL
	FROM	tblICLot Lot INNER JOIN tblICItem Item 
				ON Item.intItemId = Lot.intItemId
			INNER JOIN tblICItemLocation ItemLocation 
				ON ItemLocation.intItemLocationId = Lot.intItemLocationId
			INNER JOIN tblICItemUOM StockUOM
				ON StockUOM.intItemId = Item.intItemId
				AND StockUOM.ysnStockUnit = 1
			LEFT JOIN tblICParentLot ParentLot 
				ON ParentLot.intParentLotId = Lot.intParentLotId
	WHERE (ItemLocation.intLocationId = @intLocationId OR ISNULL(@intLocationId, 0) = 0)
		AND (intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND (intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (Lot.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0)
		AND (Lot.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0)			
		AND Item.strLotTracking <> 'No'
		AND ((dblQty > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
END
ELSE
BEGIN
	INSERT INTO tblICInventoryCountDetail(
		  intInventoryCountId
		, intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intLotId
		, dblSystemCount
		, dblLastCost
		, strCountLine
		, intItemUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort
		, dblPhysicalCount)
	SELECT
		intInventoryCountId = @intInventoryCountId
		, intItemId = stock.intItemId
		, intItemLocationId = stock.intItemLocationId
		, intSubLocationId = stock.intSubLocationId
		, intStorageLocationId = stock.intStorageLocationId
		, intLotId = NULL
		, dblSystemCount = ISNULL(stock.dblUnitOnHand, 0)
		, dblLastCost = stock.dblLastCost
		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY stock.intKey ASC) AS NVARCHAR(50))
		, intItemUOMId = stock.intStockUOMId
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
		, NULL	
	FROM vyuICStockDetail stock
		LEFT JOIN vyuICGetItemStockSummary summary ON summary.intItemId=  stock.intItemId
			AND summary.intItemLocationId = stock.intItemLocationId
			AND summary.intItemUOMId = stock.intStockUOMId
	WHERE stock.intLocationId = @intLocationId
		AND ((stock.dblUnitOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (stock.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (stock.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND (stock.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0)
		AND (stock.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0)
		AND stock.strLotTracking = 'No'
END