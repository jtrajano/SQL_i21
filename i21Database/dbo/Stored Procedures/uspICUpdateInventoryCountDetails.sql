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
	, @ysnExcludeReserved BIT = 0
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
DECLARE @ysnUseRange BIT = 1
DECLARE @CategoryFilterCount INT = 0
DECLARE @CommodityFilterCount INT = 0
DECLARE @StorageLocationFilterCount INT = 0
DECLARE @StorageUnitFilterCount INT = 0

DECLARE @strCountBy AS NVARCHAR(50) 
/*
Ranges: 
	Ranges allow you to select a range of filter. For example, the following list of commodities are the available filter that can be selected in range.
		
	Soybeans
	Corn
	Yeast
	Soya
	LPG
	Rice

	Example 1:
		Range Lower Value = Corn
		Range Upper Value = Soya

	So the selected range will be [Corn, Yeast, Soya]

	Example 2:
		Range Lower Value = Rice
		Range Upper value = Corn
	
	So the selected range will be [Corn, Yeast, Soya, LPG, Rice]
	
	If neither of the upper or lower ranges are specified, all items in the list will selected

*/
IF @ysnUseRange = 1
BEGIN
	DECLARE @Values JointDelimitedValues
	
	-- Convert Storage Location Ranges to multi-filter
	INSERT INTO @Values
	SELECT DISTINCT 
		sb.intCompanyLocationSubLocationId
	FROM 
		tblICInventoryCount c INNER JOIN tblSMCompanyLocationSubLocation sb
			ON sb.intCompanyLocationSubLocationId >= ISNULL(dbo.fnMinNumeric(c.intSubLocationId, c.intSubLocationToId), ISNULL(c.intSubLocationId, c.intSubLocationToId))
			AND sb.intCompanyLocationSubLocationId <= ISNULL(dbo.fnMaxNumeric(c.intSubLocationToId, c.intSubLocationId), ISNULL(c.intSubLocationToId, c.intSubLocationId))
	WHERE 
		c.intLocationId = sb.intCompanyLocationId
		AND c.intInventoryCountId = @intInventoryCountId

	-- Update multi-filter and clean up
	UPDATE tblICInventoryCount 
	SET 
		strStorageLocationsFilter = NULLIF(dbo.fnJoinDelimitedValues(@Values, ','), '') 
	WHERE 
		intInventoryCountId = @intInventoryCountId

	DELETE FROM @Values

	-- Convert Storage Unit Ranges to multi-filter
	INSERT INTO @Values
	SELECT DISTINCT 
		sb.intStorageLocationId
	FROM 
		tblICInventoryCount c
		INNER JOIN tblICStorageLocation sb
			ON sb.intStorageLocationId >= ISNULL(dbo.fnMinNumeric(c.intStorageLocationId, c.intStorageLocationToId), ISNULL(c.intStorageLocationId, c.intStorageLocationToId))
			AND sb.intStorageLocationId <= ISNULL(dbo.fnMaxNumeric(c.intStorageLocationToId, c.intStorageLocationId), ISNULL(c.intStorageLocationToId, c.intStorageLocationId))
	WHERE 
		c.intLocationId = sb.intLocationId
		AND c.intInventoryCountId = @intInventoryCountId

	-- Update multi-filter and clean up
	UPDATE tblICInventoryCount 
	SET 
		strStorageUnitsFilter = NULLIF(dbo.fnJoinDelimitedValues(@Values, ','), '') 
	WHERE 
		intInventoryCountId = @intInventoryCountId

	DELETE FROM @Values

	-- Convert Commodity Ranges to multi-filter
	INSERT INTO @Values
	SELECT DISTINCT 
		sb.intCommodityId
	FROM 
		tblICInventoryCount c INNER JOIN tblICCommodity sb
			ON sb.intCommodityId >= ISNULL(dbo.fnMinNumeric(c.intCommodityId, c.intCommodityToId), ISNULL(c.intCommodityId, c.intCommodityToId))
			AND sb.intCommodityId <= ISNULL(dbo.fnMaxNumeric(c.intCommodityToId, c.intCommodityId), ISNULL(c.intCommodityToId, c.intCommodityId))
	WHERE 
		c.intInventoryCountId = @intInventoryCountId

	-- Update multi-filter and clean up
	UPDATE tblICInventoryCount 
	SET strCommoditiesFilter = NULLIF(dbo.fnJoinDelimitedValues(@Values, ','), '') 
	WHERE 
		intInventoryCountId = @intInventoryCountId

	DELETE FROM @Values

	-- Convert Category Ranges to multi-filter
	INSERT INTO @Values
	SELECT DISTINCT 
		sb.intCategoryId
	FROM 
		tblICInventoryCount c INNER JOIN tblICCategory sb
			ON sb.intCategoryId >= ISNULL(dbo.fnMinNumeric(c.intCategoryId, c.intCategoryToId), ISNULL(c.intCategoryId, c.intCategoryToId))
			AND sb.intCategoryId <= ISNULL(dbo.fnMaxNumeric(c.intCategoryToId, c.intCategoryId), ISNULL(c.intCategoryToId, c.intCategoryId))
	WHERE 
		c.intInventoryCountId = @intInventoryCountId

	-- Update multi-filter and clean up
	UPDATE tblICInventoryCount 
	SET 
		strCategoriesFilter = NULLIF(dbo.fnJoinDelimitedValues(@Values, ','), '') 
	WHERE 
		intInventoryCountId = @intInventoryCountId
	DELETE FROM @Values
END

-- Update variables
SELECT 
    @strStorageLocationsFilter = c.strStorageLocationsFilter,
    @strStorageUnitsFilter = c.strStorageUnitsFilter,
    @strCommoditiesFilter = c.strCommoditiesFilter,
    @strCategoriesFilter = c.strCategoriesFilter,
	@strCountBy = c.strCountBy 
FROM 
	tblICInventoryCount c
WHERE 
	c.intInventoryCountId = @intInventoryCountId

BEGIN
	INSERT INTO @StorageLocationIds
	SELECT DISTINCT sl.intCompanyLocationSubLocationId
	FROM 
		dbo.fnICSplitStringToTable(@strStorageLocationsFilter, ',') ids
		INNER JOIN tblSMCompanyLocationSubLocation sl 
			ON sl.intCompanyLocationSubLocationId = ids.[Value]

	INSERT INTO @StorageUnitIds
	SELECT DISTINCT sl.intStorageLocationId
	FROM 
		dbo.fnICSplitStringToTable(@strStorageUnitsFilter, ',') ids
		INNER JOIN tblICStorageLocation sl 
			ON sl.intStorageLocationId = ids.[Value]

	INSERT INTO @CommodityIds
	SELECT DISTINCT c.intCommodityId
	FROM 
		dbo.fnICSplitStringToTable(@strCommoditiesFilter, ',') ids
		INNER JOIN tblICCommodity c 
			ON c.intCommodityId = ids.[Value]

	INSERT INTO @CategoryIds
	SELECT DISTINCT c.intCategoryId
	FROM 
		dbo.fnICSplitStringToTable(@strCategoriesFilter, ',') ids
		INNER JOIN tblICCategory c 
			ON c.intCategoryId = ids.[Value]

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
		, intStockUOMId
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
			, il.intItemLocationId
			, Lot.intSubLocationId
			, Lot.intStorageLocationId
			, Lot.intParentLotId
			, ParentLot.strParentLotNumber
			, ParentLot.strParentLotAlias
			, Lot.intLotId
			, Lot.strLotNumber
			, Lot.strLotAlias
			, dblSystemCount = 
				ISNULL(LotTransactions.dblQty, 0) 
				- CASE WHEN @ysnExcludeReserved = 1 THEN ISNULL(reserved.dblQty, 0) ELSE 0 END
			, dblWeightQty = 
				ISNULL(LotTransactions.dblWeight, 0) 
			, dblLastCost = 
				CASE 
					WHEN Lot.intWeightUOMId IS NOT NULL THEN 
						ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, Lot.intWeightUOMId, LastLotTransaction.dblCost), 0)
					ELSE 
						ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, Lot.intItemUOMId, LastLotTransaction.dblCost), 0)
				END 
			, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY Lot.intItemId ASC) AS NVARCHAR(50))
			, Lot.intItemUOMId
			, StockUOM.intItemUOMId
			, Lot.intWeightUOMId
			, ysnRecount = 0
			, ysnFetched = 1
			, intEntityUserSecurityId = @intEntityUserSecurityId
			, intConcurrencyId = 1
			, intSort = 1
			, dblPhysicalCount = NULL
	FROM tblICLot Lot
		INNER JOIN tblICItem Item 
			ON Item.intItemId = Lot.intItemId
		INNER JOIN tblICItemLocation il 
			ON il.intItemLocationId = Lot.intItemLocationId
		INNER JOIN tblICItemUOM StockUOM 
			ON StockUOM.intItemId = Item.intItemId
			AND StockUOM.ysnStockUnit = 1
		LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId
		CROSS APPLY (
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
				AND t.intItemLocationId = il.intItemLocationId
				AND t.intSubLocationId = Lot.intSubLocationId
				AND t.intStorageLocationId = Lot.intStorageLocationId
				AND t.intLotId = Lot.intLotId
				AND dbo.fnDateLessThanEquals(t.dtmDate, @AsOfDate) = 1		
		) LotTransactions 

		-- last transaction
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
				AND t.intItemLocationId = il.intItemLocationId
				AND t.intSubLocationId = Lot.intSubLocationId
				AND t.intStorageLocationId = Lot.intStorageLocationId
				AND t.intLotId = Lot.intLotId
				AND t.dblQty > 0 
				AND ISNULL(t.ysnIsUnposted, 0) = 0 
				AND dbo.fnDateLessThanEquals(t.dtmDate, @AsOfDate) = 1	
			ORDER BY
				t.intInventoryTransactionId DESC 		
		) LastLotTransaction 
		OUTER APPLY (
			SELECT dblQty = SUM(sr.dblQty) 
			FROM 
				tblICStockReservation sr
				LEFT JOIN tblICInventoryTransaction xt 
					ON xt.intTransactionId = sr.intTransactionId
			WHERE 
				sr.intItemId = Lot.intItemId
				AND sr.intItemLocationId = Lot.intItemLocationId
				AND ISNULL(sr.intLotId, 0) = ISNULL(Lot.intLotId, 0)
				AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(Lot.intStorageLocationId, 0)
				AND ISNULL(sr.intSubLocationId, 0) = ISNULL(Lot.intSubLocationId, 0)				
				AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), xt.dtmDate,112), @AsOfDate) = 1
		) reserved
		LEFT JOIN @CategoryIds categoryFilter ON categoryFilter.intCategoryId = Item.intCategoryId
		LEFT JOIN @CommodityIds commodityFilter ON commodityFilter.intCommodityId = Item.intCommodityId
		LEFT JOIN @StorageLocationIds storageLocationFilter ON storageLocationFilter.intStorageLocationId = Lot.intSubLocationId
		LEFT JOIN @StorageUnitIds storageUnitFilter ON storageUnitFilter.intStorageUnitId = Lot.intStorageLocationId

	WHERE 
		il.intLocationId = @intLocationId
		AND ((LotTransactions.dblQty <> 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))
		AND (categoryFilter.intCategoryId = Item.intCategoryId OR ISNULL(@CategoryFilterCount, 0) = 0)
		AND (commodityFilter.intCommodityId = Item.intCommodityId OR ISNULL(@CommodityFilterCount, 0) = 0)
		AND (storageLocationFilter.intStorageLocationId = Lot.intSubLocationId OR ISNULL(@StorageLocationFilterCount, 0) = 0)
		AND (storageUnitFilter.intStorageUnitId = Lot.intStorageLocationId OR ISNULL(@StorageUnitFilterCount, 0) = 0)
		AND Item.strLotTracking <> 'No'
		AND Item.strType = 'Inventory'
		AND (il.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND Item.strStatus NOT IN ('Discontinued')
END

ELSE IF @strCountBy = 'Pack'
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
		, dblPhysicalCount
	)
	SELECT DISTINCT
		intInventoryCountId = @intInventoryCountId
		, intItemId = il.intItemId
		, intItemLocationId = COALESCE(stock.intItemLocationId, il.intItemLocationId)
		, intSubLocationId = CASE WHEN lastTransaction.intItemId IS NULL THEN il.intSubLocationId ELSE stock.intSubLocationId END 
		, intStorageLocationId = CASE WHEN lastTransaction.intItemId IS NULL THEN il.intStorageLocationId ELSE stock.intStorageLocationId END
		, intLotId = NULL
		, dblSystemCount =
			COALESCE(
				dbo.fnCalculateQtyBetweenUOM(stock.intItemUOMId, itemUOM.intItemUOMId, stock.dblOnHand) 
				, 0
			)
			
		, dblLastCost =  
			-- Convert the last cost from Stock UOM to stock.intItemUOMId
			ISNULL(
				CASE 
					WHEN il.intCostingMethod = 1 THEN 
						dbo.fnCalculateCostBetweenUOM (
							stockUOM.intItemUOMId
							,itemUOM.intItemUOMId
							,dbo.fnICGetMovingAverageCost(
								il.intItemId
								,il.intItemLocationId
								,lastTransaction.intInventoryTransactionId
							)
						)
					ELSE 
						ISNULL(
							-- last cost from transaction
							dbo.fnCalculateCostBetweenUOM(
								lastCost.intItemUOMId 
								, itemUOM.intItemUOMId
								, lastCost.dblCost 
							)
							-- last cost from item pricing
							,dbo.fnCalculateCostBetweenUOM(
								stockUOM.intItemUOMId
								, itemUOM.intItemUOMId
								, p.dblLastCost
							)
						)
				END

				, 0
			)			

		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY il.intItemId ASC, il.intItemLocationId ASC, itemUOM.intItemUOMId ASC) AS NVARCHAR(50))
		, intItemUOMId = itemUOM.intItemUOMId
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
		, NULL
	FROM tblICItemLocation il
		INNER JOIN tblICItemUOM stockUOM 
			ON stockUOM.intItemId = il.intItemId
			AND stockUOM.ysnStockUnit = 1
		INNER JOIN tblICItem i 
			ON i.intItemId = il.intItemId
		INNER JOIN tblICItemPricing p
			ON p.intItemId = i.intItemId
			AND p.intItemLocationId = il.intItemLocationId
		--INNER JOIN (
		--	tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure u
		--		ON itemUOM.intUnitMeasureId = u.intUnitMeasureId
		--)
		--	ON itemUOM.intItemId = i.intItemId
		--	AND u.strUnitType IN ('Quantity')
		--	AND itemUOM.ysnStockUnit <> 1 

		OUTER APPLY (
			SELECT [count] = COUNT(1) 
			FROM 
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u 
					ON iu.intUnitMeasureId = u.intUnitMeasureId
			WHERE
				iu.intItemId = i.intItemId
				AND u.strUnitType IN ('Quantity')		
				AND iu.ysnStockUnit <> 1 
		) numberOfPackUOMs

		CROSS APPLY (
			SELECT 
				iu.intItemUOMId
				,u.strUnitMeasure
			FROM 
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u 
					ON iu.intUnitMeasureId = u.intUnitMeasureId
			WHERE
				iu.intItemId = i.intItemId
				AND (
					(u.strUnitType IN ('Quantity') AND iu.ysnStockUnit <> 1)
					OR (ISNULL(numberOfPackUOMs.[count], 0) = 0 AND iu.ysnStockUnit = 1)
				)			
		) itemUOM
			
		OUTER APPLY (
			SELECT TOP 1 
				dblCost = t.dblCost
				,t.intItemUOMId
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.intItemId = i.intItemId
				AND t.intItemLocationId = il.intItemLocationId
				AND dbo.fnDateLessThanEquals(t.dtmDate, @AsOfDate) = 1
				AND t.dblQty > 0 
				AND t.ysnIsUnposted = 0 
			ORDER BY
				t.intInventoryTransactionId DESC 
		) lastCost

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
					v.intItemId = i.intItemId
					AND v.intItemLocationId = il.intItemLocationId
					AND dbo.fnDateLessThanEquals(v.dtmDate, @AsOfDate) = 1
			GROUP BY 
					v.intItemId
					,u.intItemUOMId
					,v.intItemLocationId
					,v.intSubLocationId
					,v.intStorageLocationId
		) stock 

		OUTER APPLY (
			SELECT TOP 1 
				t.intInventoryTransactionId
				,t.intItemId
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.intItemId = i.intItemId
				AND t.intItemLocationId = il.intItemLocationId
				AND dbo.fnDateLessThanEquals(t.dtmDate, @AsOfDate) = 1
				AND t.dblQty <> 0 				
			ORDER BY
				t.intInventoryTransactionId DESC 		
		) lastTransaction

		LEFT JOIN @CategoryIds categoryFilter ON 1 = 1
		LEFT JOIN @CommodityIds commodityFilter ON 1 = 1 
		LEFT JOIN @StorageLocationIds storageLocationFilter ON 1 = 1 
		LEFT JOIN @StorageUnitIds storageUnitFilter ON 1 = 1		 
	WHERE il.intLocationId = @intLocationId
		AND ((stock.dblOnHand <> 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))		
		AND i.strLotTracking = 'No'
		AND i.strStatus NOT IN ('Discontinued')
		AND i.strType IN ('Inventory', 'Raw Material', 'Finished Good')
		AND (il.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (i.intCategoryId = categoryFilter.intCategoryId OR ISNULL(@CategoryFilterCount, 0) = 0)
		AND (i.intCommodityId = commodityFilter.intCommodityId OR ISNULL(@CommodityFilterCount, 0) = 0)
		AND (
			(stock.intSubLocationId = storageLocationFilter.intStorageLocationId OR ISNULL(@StorageLocationFilterCount, 0) = 0)
			OR (lastTransaction.intItemId IS NULL AND il.intSubLocationId = storageLocationFilter.intStorageLocationId)				
		)
		AND (
			(stock.intStorageLocationId = storageUnitFilter.intStorageUnitId OR ISNULL(@StorageUnitFilterCount, 0) = 0)
			OR (lastTransaction.intItemId IS NULL AND il.intStorageLocationId = storageUnitFilter.intStorageUnitId)		
		)
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
		, intStockUOMId
		, ysnRecount
		, ysnFetched
		, intEntityUserSecurityId
		, intConcurrencyId
		, intSort
		, dblPhysicalCount
	)
	SELECT DISTINCT
		intInventoryCountId = @intInventoryCountId
		, intItemId = il.intItemId
		, intItemLocationId = COALESCE(stock.intItemLocationId, il.intItemLocationId)
		, intSubLocationId = 
			CASE 
				WHEN hasExistingStock.intItemId IS NULL THEN il.intSubLocationId 
				ELSE 
					CASE 
						WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 1 THEN stock.intSubLocationId  
						ELSE stockUnit.intSubLocationId
					END 
			END 
		, intStorageLocationId = 
			CASE 
				WHEN hasExistingStock.intItemId IS NULL THEN il.intStorageLocationId 
				ELSE 
					CASE 
						WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 1 THEN stock.intStorageLocationId  
						ELSE stockUnit.intStorageLocationId
					END 
			END
		, intLotId = NULL
		, dblSystemCount = 		
			CASE
				WHEN i.ysnSeparateStockForUOMs = 1 THEN 
					CASE 
						WHEN @ysnExcludeReserved = 1 THEN 
							ISNULL(stock.dblOnHand, 0) - ISNULL(reserved.dblQty, 0) 
						ELSE 
							ISNULL(stock.dblOnHand, 0) 
					END 
				ELSE
					CASE 
						WHEN @ysnExcludeReserved = 1 THEN 
							ISNULL(stockUnit.dblOnHand, 0) - ISNULL(reserved.dblQtyInStockUOM, 0) 
						ELSE 
							ISNULL(stockUnit.dblOnHand, 0) 
					END 
			END 
		, dblLastCost =  
			CASE 
				-- Get the average cost. 
				WHEN il.intCostingMethod = 1 THEN 				
					dbo.fnCalculateCostBetweenUOM (
						stockUOM.intItemUOMId
						,COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						,ISNULL(
							dbo.fnICGetMovingAverageCost(
								i.intItemId
								,il.intItemLocationId
								,lastTransaction.intInventoryTransactionId
							
							)
							,p.dblLastCost
						)					
					)
					
				-- Or else, get the last cost. 
				ELSE 				
					dbo.fnCalculateQtyBetweenUOM (
						lastTransaction.intItemUOMId
						, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
						, lastTransaction.dblCost
					)
			END 			

		, strCountLine = @strHeaderNo + '-' + CAST(ROW_NUMBER() OVER(ORDER BY il.intItemId ASC, il.intItemLocationId ASC, stockUOM.intItemUOMId ASC) AS NVARCHAR(50))
		, intItemUOMId = COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
		, intItemUOMId = 
			CASE 
				WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 1 THEN stock.intItemUOMId
				ELSE stockUOM.intItemUOMId
			END 
		, ysnRecount = 0
		, ysnFetched = 1
		, intEntityUserSecurityId = @intEntityUserSecurityId
		, intConcurrencyId = 1
		, intSort = 1
		, NULL
	FROM tblICItemLocation il
		INNER JOIN tblICItemPricing p 
			ON p.intItemLocationId = il.intItemLocationId
			AND p.intItemId = il.intItemId
		INNER JOIN tblICItemUOM stockUOM 
			ON stockUOM.intItemId = il.intItemId
			AND stockUOM.ysnStockUnit = 1
		INNER JOIN tblICItem i 
			ON i.intItemId = il.intItemId
		-- Get the stocks using its own UOM 
		LEFT JOIN (
			SELECT	intItemId
					,intItemUOMId
					,intItemLocationId
					,intSubLocationId
					,intStorageLocationId
					,dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
			FROM	vyuICGetItemStockSummary
			WHERE	dbo.fnDateLessThanEquals(dtmDate, @AsOfDate) = 1
			GROUP BY 
					intItemId,
					intItemUOMId,
					intItemLocationId,
					intSubLocationId,
					intStorageLocationId
		) stock 
			ON stock.intItemId = i.intItemId
			AND stock.intItemLocationId = il.intItemLocationId
			AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 1
		-- Get the stocks as 'Stock Unit'. 
		LEFT JOIN (
			SELECT	 
				st.intItemId
				,st.intItemLocationId
				,st.intSubLocationId
				,st.intStorageLocationId
				,st.intLocationId
				,dblOnHand = SUM (
						dbo.fnCalculateQtyBetweenUOM (
							st.intItemUOMId
							, suom.intItemUOMId
							, ISNULL(st.dblOnHand, 0.00)
						)
					)
			FROM	
				vyuICGetItemStockSummary st
				INNER JOIN tblICItemUOM suom 
					ON suom.intItemId = st.intItemId
					AND suom.ysnStockUnit = 1
			WHERE	
				dbo.fnDateLessThanEquals(dtmDate, @AsOfDate) = 1
			GROUP BY 
				st.intItemId
				,st.intItemLocationId
				,st.intSubLocationId
				,st.intStorageLocationId
				,st.intLocationId
		) stockUnit 
		ON 
			stockUnit.intItemId = i.intItemId			
			AND stockUnit.intItemLocationId = il.intItemLocationId
			AND stockUnit.intLocationId = il.intLocationId
			AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0
		-- Get the stock reservation. 
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
				sr.intItemId = i.intItemId
				AND sr.intItemLocationId = il.intItemLocationId
				AND (dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), sr.dtmDate,112), @AsOfDate) = 1 OR sr.dtmDate IS NULL) 
				AND ISNULL(sr.intStorageLocationId, 0) = COALESCE(stock.intStorageLocationId, stockUnit.intStorageLocationId, 0)
				AND ISNULL(sr.intSubLocationId, 0) = COALESCE(stock.intSubLocationId, stockUnit.intSubLocationId, 0)
				AND sr.intItemUOMId = COALESCE(stock.intItemUOMId, sr.intItemUOMId) 
		) reserved
		-- last transaction
		OUTER APPLY (
			SELECT
				TOP 1 
				t.intItemUOMId
				,t.dblCost
				,t.intInventoryTransactionId
			FROM 
				tblICInventoryTransaction t
			WHERE 
				t.intItemId = i.intItemId
				AND t.intItemLocationId = il.intItemLocationId 
				AND t.dblQty > 0 
				AND ISNULL(t.ysnIsUnposted, 0) = 0 
				AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @AsOfDate) = 1
			ORDER BY
				t.intInventoryTransactionId DESC 		
		) lastTransaction 
		OUTER APPLY (
			SELECT TOP 1 
				v.intItemId
			FROM 
				vyuICGetItemStockSummary v
			WHERE 
				dbo.fnDateLessThanEquals(v.dtmDate, @AsOfDate) = 1
				AND v.intItemId = i.intItemId
				AND v.intItemLocationId = il.intItemLocationId
				AND (v.intSubLocationId = il.intSubLocationId OR il.intSubLocationId IS NULL)
				AND (v.intStorageLocationId = il.intStorageLocationId OR il.intStorageLocationId IS NULL)    
		) hasExistingStock 
		LEFT JOIN @CategoryIds categoryFilter ON 1 = 1
		LEFT JOIN @CommodityIds commodityFilter ON 1 = 1 
		LEFT JOIN @StorageLocationIds storageLocationFilter ON 1 = 1 
		LEFT JOIN @StorageUnitIds storageUnitFilter ON 1 = 1	
	WHERE 
		il.intLocationId = @intLocationId
		AND ((COALESCE(stock.dblOnHand, stockUnit.dblOnHand) <> 0 AND @ysnIncludeZeroOnHand = 0) OR (@ysnIncludeZeroOnHand = 1))		
		AND i.strLotTracking = 'No'
		AND i.strType = 'Inventory'
		AND i.strStatus NOT IN ('Discontinued')
		AND (il.intCountGroupId = @intCountGroupId OR ISNULL(@intCountGroupId, 0) = 0)
		AND (i.intCategoryId = categoryFilter.intCategoryId OR ISNULL(@CategoryFilterCount, 0) = 0)
		AND (i.intCommodityId = commodityFilter.intCommodityId OR ISNULL(@CommodityFilterCount, 0) = 0)
		AND (
			(stock.intSubLocationId = storageLocationFilter.intStorageLocationId OR ISNULL(@StorageLocationFilterCount, 0) = 0)
			OR (hasExistingStock.intItemId IS NULL AND il.intSubLocationId = storageLocationFilter.intStorageLocationId)				
		)
		AND (
			(stock.intStorageLocationId = storageUnitFilter.intStorageUnitId OR ISNULL(@StorageUnitFilterCount, 0) = 0)
			OR (hasExistingStock.intItemId IS NULL AND il.intStorageLocationId = storageUnitFilter.intStorageUnitId)		
		)
END
