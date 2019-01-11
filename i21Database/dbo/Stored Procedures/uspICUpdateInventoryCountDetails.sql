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
		AND (ItemLocation.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
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
		, intItemId = il.intItemId
		, intItemLocationId = COALESCE(stock.intItemLocationId, il.intItemLocationId)
		, intSubLocationId = stock.intSubLocationId
		, intStorageLocationId = stock.intStorageLocationId
		, intLotId = NULL
		, dblSystemCount = ISNULL(stockUnit.dblOnHand, 0)-- SUM(COALESCE(stock.dblOnHand, 0.00))
		, dblLastCost =  
			---- Convert the last cost from Stock UOM to stock.intItemUOMId
			CASE 
				WHEN il.intCostingMethod = 1 THEN 
					AVERAGE.dblCost
				WHEN il.intCostingMethod = 2 THEN 
					dbo.fnCalculateCostBetweenUOM(
						COALESCE(FIFO.intItemUOMId, stockUOM.intItemUOMId)
						,COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						,COALESCE(FIFO.dblCost, p.dblLastCost)
					)
				ELSE 
					dbo.fnCalculateCostBetweenUOM(
						stockUOM.intItemUOMId
						, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						, COALESCE(stock.dblLastCost, p.dblLastCost)
					)
			END
			--dbo.fnCalculateCostBetweenUOM(
			--	stockUOM.intItemUOMId
			--	, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
			--	, COALESCE(stock.dblLastCost, p.dblLastCost)
			--)
		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY il.intItemId ASC, il.intItemLocationId ASC, stockUOM.intItemUOMId ASC) AS NVARCHAR(50))
		, intItemUOMId = COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
		, NULL
	FROM tblICItemLocation il
		INNER JOIN tblICItemPricing p ON p.intItemLocationId = il.intItemLocationId
			AND p.intItemId = il.intItemId
		INNER JOIN tblICItemUOM stockUOM 
			ON stockUOM.intItemId = il.intItemId
			AND stockUOM.ysnStockUnit = 1
		INNER JOIN tblICItem i ON i.intItemId = il.intItemId
		LEFT JOIN (
			SELECT	intItemId
					,intItemUOMId
					,intItemLocationId
					,intSubLocationId
					,intStorageLocationId
					,dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
					,dblLastCost = MAX(dblLastCost)
			FROM	vyuICGetItemStockSummary
			WHERE	dbo.fnDateLessThanEquals(dtmDate, @AsOfDate) = 1
			GROUP BY 
					intItemId,
					intItemUOMId,
					intItemLocationId,
					intSubLocationId,
					intStorageLocationId
		) stock ON stock.intItemId = i.intItemId
			AND stockUOM.intItemUOMId = stock.intItemUOMId
			AND stock.intItemLocationId = il.intItemLocationId
		LEFT JOIN (
			SELECT	 st.intItemId
					,st.intItemLocationId
					,st.intSubLocationId
					,st.intStorageLocationId
					,st.intLocationId
					--,st.ysnStockUnit
					,dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(st.intItemUOMId, suom.intItemUOMId, ISNULL(st.dblOnHand, 0.00)))
					,dblLastCost = MAX(dblLastCost)
			FROM	vyuICGetItemStockSummary st
				LEFT OUTER JOIN tblICItemUOM suom ON suom.intItemId = st.intItemId
					AND suom.ysnStockUnit = 1
			WHERE	dbo.fnDateLessThanEquals(dtmDate, @AsOfDate) = 1
			GROUP BY 
					st.intItemId,
					st.intItemLocationId,
					st.intSubLocationId,
					st.intStorageLocationId,
					--st.ysnStockUnit,
					st.intLocationId
		) stockUnit ON stockUnit.intItemId = i.intItemId
			--AND ISNULL(stockUnit.ysnStockUnit, 0) = 0
			AND stockUnit.intItemLocationId = il.intItemLocationId
			AND stockUnit.intLocationId = il.intLocationId
			AND (stockUnit.intSubLocationId = stock.intSubLocationId OR (stockUnit.intSubLocationId IS NULL AND stock.intSubLocationId IS NULL))
			AND (stockUnit.intStorageLocationId = stock.intStorageLocationId OR (stockUnit.intStorageLocationId IS NULL AND stock.intStorageLocationId IS NULL))
		OUTER APPLY(
			SELECT TOP 1
					dblCost
					,intItemUOMId
			FROM	tblICInventoryFIFO FIFO 
			WHERE	i.intItemId = FIFO.intItemId 
					AND il.intItemLocationId = FIFO.intItemLocationId 
					AND dblStockIn - dblStockOut > 0
					AND dbo.fnDateLessThanEquals(dtmDate, @AsOfDate) = 1 
			ORDER BY dtmDate ASC
		) FIFO 
		OUTER APPLY(
			SELECT MAX(dblAverageCost) dblCost
			FROM [dbo].[fnGetItemAverageCostTable](i.intItemId, @AsOfDate)
		) AVERAGE
	WHERE il.intLocationId = @intLocationId
		AND ((stock.dblOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (i.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)
		AND (i.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)
		AND ((@intSubLocationId IS NULL) OR (stock.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0))
		AND ((@intStorageLocationId IS NULL) OR (stock.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))
		AND (il.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND i.strLotTracking = 'No'

END