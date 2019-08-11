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

DECLARE @strStorageLocationsFilter NVARCHAR(1000)
DECLARE @strStorageUnitsFilter NVARCHAR(1000)
DECLARE @strCommoditiesFilter NVARCHAR(1000)
DECLARE @strCategoriesFilter NVARCHAR(1000)

DECLARE @StorageLocationIds TABLE (intStorageLocationId INT)
DECLARE @StorageUnitIds TABLE (intStorageUnitId INT)
DECLARE @CommodityIds TABLE (intCommodityId INT)
DECLARE @CategoryIds TABLE (intCategoryId INT)
DECLARE @ysnIsMultiFilter BIT = 0
DECLARE @CategoryFilterCount INT = 0
DECLARE @CommodityFilterCount INT = 0
DECLARE @StorageLocationFilterCount INT = 0
DECLARE @StorageUnitFilterCount INT = 0

SELECT 
    @strStorageLocationsFilter = c.strStorageLocationsFilter,
    @strStorageUnitsFilter = c.strStorageUnitsFilter,
    @strCommoditiesFilter = c.strCommoditiesFilter,
    @strCategoriesFilter = c.strCategoriesFilter,
	@ysnIsMultiFilter = ISNULL(c.ysnIsMultiFilter, 0)
FROM tblICInventoryCount c
WHERE c.intInventoryCountId = @intInventoryCountId

IF @ysnIsMultiFilter = 1
BEGIN
	INSERT INTO @StorageLocationIds
	SELECT DISTINCT sl.intCompanyLocationSubLocationId
	FROM dbo.fnICSplitStringToTable(@strStorageLocationsFilter, ',') ids
		INNER JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = ids.[Value]

	INSERT INTO @StorageUnitIds
	SELECT DISTINCT sl.intStorageLocationId
	FROM dbo.fnICSplitStringToTable(@strStorageUnitsFilter, ',') ids
		INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = ids.[Value]

	INSERT INTO @CommodityIds
	SELECT DISTINCT c.intCommodityId
	FROM dbo.fnICSplitStringToTable(@strCommoditiesFilter, ',') ids
		INNER JOIN tblICCommodity c ON c.intCommodityId = ids.[Value]

	INSERT INTO @CategoryIds
	SELECT DISTINCT c.intCategoryId
	FROM dbo.fnICSplitStringToTable(@strCategoriesFilter, ',') ids
		INNER JOIN tblICCategory c ON c.intCategoryId = ids.[Value]

	SELECT @CategoryFilterCount = COUNT(*) FROM @CategoryIds
	SELECT @CommodityFilterCount = COUNT(*) FROM @CommodityIds
	SELECT @StorageLocationFilterCount = COUNT(*) FROM @StorageLocationIds
	SELECT @StorageUnitFilterCount = COUNT(*) FROM @StorageUnitIds
END


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
			, Lot.intLotId
			, Lot.strLotNumber
			, Lot.strLotAlias
			, dblSystemCount = ISNULL(Transactions.dblOnHand, 0)
			, dblWeightQty = Lot.dblWeight
			, dblLastCost = ISNULL(Transactions.dblCost, 0)
			, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY Lot.intItemId ASC) AS NVARCHAR(50))
			, Lot.intItemUOMId
			, Lot.intWeightUOMId
			, ysnRecount = 0
			, ysnFetched = 1
			, intEntityUserSecurityId = @intEntityUserSecurityId
			, intConcurrencyId = 1
			, intSort = 1
			, dblPhysicalCount = NULL
	FROM tblICLot Lot
		INNER JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
		INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = Lot.intItemLocationId
		INNER JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId
			AND StockUOM.ysnStockUnit = 1
		LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId
		INNER JOIN (
			SELECT
					t.intItemId
				, t.intItemLocationId
				, t.intSubLocationId
				, t.intStorageLocationId
				, t.intItemUOMId
				, t.intLotId
				, dblCost = MAX(t.dblCost)
				, dblOnHand = SUM(t.dblQty)
			FROM tblICInventoryTransaction t
			WHERE dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @AsOfDate) = 1
			GROUP BY t.intItemId, t.intItemLocationId, t.intSubLocationId, t.intStorageLocationId, t.intItemUOMId, t.intLotId
		) Transactions ON Transactions.intItemId = Item.intItemId
			AND Transactions.intItemLocationId = ItemLocation.intItemLocationId
			AND Transactions.intSubLocationId = Lot.intSubLocationId
			AND Transactions.intStorageLocationId = Lot.intStorageLocationId
			AND Transactions.intLotId = Lot.intLotId
			AND Transactions.intItemUOMId = Lot.intItemUOMId
		LEFT OUTER JOIN @CategoryIds categoryFilter ON categoryFilter.intCategoryId = Item.intCategoryId
		LEFT OUTER JOIN @CommodityIds commodityFilter ON commodityFilter.intCommodityId = Item.intCommodityId
		LEFT OUTER JOIN @StorageLocationIds storageLocationFilter ON storageLocationFilter.intStorageLocationId = Lot.intSubLocationId
		LEFT OUTER JOIN @StorageUnitIds storageUnitFilter ON storageUnitFilter.intStorageUnitId = Lot.intStorageLocationId
	WHERE (ItemLocation.intLocationId = @intLocationId OR ISNULL(@intLocationId, 0) = 0)
		AND ((@ysnIsMultiFilter = 0 AND (Item.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND categoryFilter.intCategoryId = Item.intCategoryId OR @CategoryFilterCount = 0))
		AND ((@ysnIsMultiFilter = 0 AND (Item.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND commodityFilter.intCommodityId = Item.intCommodityId OR @CommodityFilterCount = 0))
		AND (intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND ((@ysnIsMultiFilter = 0 AND (Lot.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0)) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND storageLocationFilter.intStorageLocationId = Lot.intSubLocationId OR @StorageLocationFilterCount = 0))
		AND ((@ysnIsMultiFilter = 0 AND (Lot.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))	OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND storageUnitFilter.intStorageUnitId = Lot.intStorageLocationId OR @StorageUnitFilterCount = 0))
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
			ISNULL(CASE 
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
			END, 0)
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
		LEFT OUTER JOIN @CategoryIds categoryFilter ON categoryFilter.intCategoryId = i.intCategoryId
		LEFT OUTER JOIN @CommodityIds commodityFilter ON commodityFilter.intCommodityId = i.intCommodityId
		LEFT OUTER JOIN @StorageLocationIds storageLocationFilter ON storageLocationFilter.intStorageLocationId = stock.intSubLocationId
		LEFT OUTER JOIN @StorageUnitIds storageUnitFilter ON storageUnitFilter.intStorageUnitId = stock.intStorageLocationId
	WHERE il.intLocationId = @intLocationId
		AND ((stock.dblOnHand > 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND ((@ysnIsMultiFilter = 0 AND (i.intCategoryId = @intCategoryId OR ISNULL(@intCategoryId, 0) = 0)) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND categoryFilter.intCategoryId = i.intCategoryId OR @CategoryFilterCount = 0))
		AND ((@ysnIsMultiFilter = 0 AND (i.intCommodityId = @intCommodityId OR ISNULL(@intCommodityId, 0) = 0)) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND commodityFilter.intCommodityId = i.intCommodityId OR @CommodityFilterCount = 0))
		AND (@ysnIsMultiFilter = 0 AND (((@intSubLocationId IS NULL) OR (stock.intSubLocationId = @intSubLocationId OR ISNULL(@intSubLocationId, 0) = 0))) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND storageLocationFilter.intStorageLocationId = stock.intSubLocationId OR @StorageLocationFilterCount = 0))
		AND (@ysnIsMultiFilter = 0 AND (((@intStorageLocationId IS NULL) OR (stock.intStorageLocationId = @intStorageLocationId OR ISNULL(@intStorageLocationId, 0) = 0))) OR
			-- If multi-filter is enabled
			(@ysnIsMultiFilter = 1 AND storageUnitFilter.intStorageUnitId = stock.intStorageLocationId OR @StorageUnitFilterCount = 0))
		AND i.strLotTracking = 'No'

END