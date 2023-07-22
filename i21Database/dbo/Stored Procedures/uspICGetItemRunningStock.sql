CREATE PROCEDURE [dbo].[uspICGetItemRunningStock]
	@intItemId AS INT,
	@intLocationId AS INT,
	@intSubLocationId AS INT = NULL,
	@intStorageLocationId AS INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@intOwnershipType AS INT = 1
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @DefaultLotCondition NVARCHAR(50)
SELECT @DefaultLotCondition = strLotCondition
FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);
DECLARE @dblAverageCost AS NUMERIC(30, 20); 
DECLARE @intCostingMethod AS INT; 

DECLARE @tblInventoryTransaction TABLE(
	intItemId INT,
	intItemUOMId INT,
	intItemLocationId INT,
	intSubLocationId INT,
	intStorageLocationId INT,
	intLotId INT,
	intCostingMethod INT,
	dtmDate DATETIME,
	dblQty NUMERIC(38, 20),
	dblUnitStorage NUMERIC(38, 20),
	dblCost NUMERIC(38, 20),
	intOwnershipType INT
);

DECLARE @tblInventoryTransactionGrouped TABLE (
	intItemId INT,
	intItemUOMId INT,
	intItemLocationId INT,
	intSubLocationId INT,
	intStorageLocationId INT,
	intCostingMethodId INT,
	dblQty NUMERIC(38, 20),
	dblUnitStorage NUMERIC(38, 20),
	dblCost NUMERIC(38, 20)
);

DECLARE @tblInventoryTransactionsInStockUOM TABLE (
	intItemId INT,
	intItemUOMId INT,
	intItemLocationId INT,
	intSubLocationId INT,
	intStorageLocationId INT,
	intCostingMethodId INT,
	dblQty NUMERIC(38, 20),
	dblUnitStorage NUMERIC(38, 20)
);

DECLARE 
	@ysnSeparateStockForUOMs AS BIT
	,@intStockUOMId AS INT 
	,@dblLastCost AS NUMERIC(38, 20) 
	,@intLastInventoryTransactionId AS INT 

	SELECT @ysnSeparateStockForUOMs = ISNULL(i.ysnSeparateStockForUOMs,0) FROM tblICItem i WHERE i.intItemId = @intItemId 
	SELECT TOP 1 @intStockUOMId = iu.intItemUOMId FROM tblICItemUOM iu WHERE iu.intItemId = @intItemId AND iu.ysnStockUnit = 1
	SELECT 
		@intCostingMethod = dbo.fnGetCostingMethod(il.intItemId, il.intItemLocationId)
	FROM tblICItemLocation il 
	WHERE
		il.intItemId = @intItemId
		AND il.intLocationId = @intLocationId

-- Get the stock quantities from the inventory transactions. 
INSERT INTO @tblInventoryTransaction
	(
	intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId
	,intStorageLocationId
	,intLotId
	,intCostingMethod
	,dtmDate
	,dblQty
	,dblUnitStorage
	,dblCost
	,intOwnershipType
	)
-- begin: Get the company-owned stocks
SELECT
	t.intItemId
	,intItemUOMId		= t.intItemUOMId 
	,intItemLocationId	= t.intItemLocationId 
	,intSubLocationId	= 
		CASE 
			WHEN Lot.intLotId IS NULL THEN t.intSubLocationId 
			ELSE Lot.intSubLocationId 
		END
	,intStorageLocationId = 
		CASE 
			WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId 
			ELSE Lot.intStorageLocationId 
		END
	,Lot.intLotId
	,intCostingMethod	= @intCostingMethod
	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
	,dblQty				= t.dblQty
	,dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
	,dblCost
	,intOwnershipType	= 1
FROM
	tblICInventoryTransaction t INNER JOIN tblICItemLocation IL
		ON IL.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICLot Lot
		ON Lot.intLotId = t.intLotId
WHERE 
	t.intItemId = @intItemId
	--AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND t.intInTransitSourceLocationId IS NULL
	--AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND IL.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 1
	AND t.dblQty <> 0
-- end: Get the company-owned stocks

-- begin: Get the customer-owned (aka Storage) stocks
UNION ALL
SELECT
	t.intItemId
	,intItemUOMId		= t.intItemUOMId 
	,intItemLocationId	= t.intItemLocationId 
	,intSubLocationId	= 
		CASE 
			WHEN Lot.intLotId IS NULL THEN t.intSubLocationId 
			ELSE Lot.intSubLocationId 
		END
	,intStorageLocationId = 
		CASE 
			WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId 
			ELSE Lot.intStorageLocationId 
		END	, Lot.intLotId
	,intCostingMethod	= @intCostingMethod
	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
	,dblQty				= CAST(0 AS NUMERIC(38, 20))
	,dblUnitStorage		= t.dblQty
	,dblCost
	,intOwnershipType	= 2
FROM
	tblICInventoryTransactionStorage t INNER JOIN tblICItemLocation IL
		ON IL.intItemLocationId = t.intItemLocationId
		LEFT JOIN tblICLot Lot
		ON Lot.intLotId = t.intLotId
WHERE 
	t.intItemId = @intItemId
	AND IL.intLocationId = @intLocationId
	--AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	--AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 2
	AND t.dblQty <> 0
-- end: Get the customer-owned (aka Storage) stocks

-- Get the last cost
SELECT TOP 1 
	@dblLastCost = dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @intStockUOMId, t.dblCost) 
	,@intLastInventoryTransactionId = t.intInventoryTransactionId
FROM
	tblICInventoryTransaction t INNER JOIN tblICItemLocation IL
		ON IL.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICLot Lot
		ON Lot.intLotId = t.intLotId
WHERE 
	t.intItemId = @intItemId
	--AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND t.intInTransitSourceLocationId IS NULL
	AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND IL.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 1
	AND t.dblQty > 0 
ORDER BY
	t.intInventoryTransactionId DESC 

-- If transaction does not exists, add a dummy record. 
IF NOT EXISTS(SELECT TOP 1 1 FROM @tblInventoryTransaction)
BEGIN
	INSERT INTO @tblInventoryTransaction
	SELECT 
		i.intItemId
		,intItemUOMId		= ItemUOMStock.intItemUOMId
		,intItemLocationId	= DefaultLocation.intItemLocationId
		,intSubLocationId	= @intSubLocationId
		,intStorageLocationId= @intStorageLocationId
		,intLotId			= NULL
		,intCostingMethod	= DefaultLocation.intCostingMethod
		,dtmDate			= CAST(CONVERT(VARCHAR(10),@dtmDate,112) AS datetime)
		,dblQty				= CAST(0 AS NUMERIC(38, 20))
		,dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
		,dblCost			= ItemPricing.dblLastCost
		,intOwnershipType	= 1
	FROM 
		tblICItem i INNER JOIN tblICItemUOM ItemUOMStock
			ON ItemUOMStock.intItemId = i.intItemId 
			AND ItemUOMStock.ysnStockUnit = 1
		CROSS APPLY (
			SELECT 
				ItemLocation.intItemLocationId
				, ItemLocation.intCostingMethod
			FROM 
				tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location]
					ON [Location].intCompanyLocationId = ItemLocation.intLocationId
			WHERE 
				ItemLocation.intItemId = i.intItemId
				AND [Location].intCompanyLocationId = @intLocationId
		) DefaultLocation
		LEFT JOIN tblICItemPricing ItemPricing
			ON i.intItemId = ItemPricing.intItemId
				AND DefaultLocation.intItemLocationId = ItemPricing.intItemLocationId
	WHERE 
		i.intItemId = @intItemId
		AND i.strLotTracking = 'No'
END

-- Aggregrate the On-Hand and Storage Qty. 
INSERT INTO @tblInventoryTransactionGrouped
	(
	intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId
	,intStorageLocationId
	,intCostingMethodId
	,dblQty
	,dblUnitStorage
	,dblCost
	)
SELECT 
	i.intItemId
	, intItemUOMId
	, intItemLocationId
	, intSubLocationId = @intSubLocationId
	, intStorageLocationId = @intStorageLocationId
	, intCostingMethod
	, dblQty = SUM(t.dblQty) 
 	, dblUnitStorage = SUM(t.dblUnitStorage)
	, dblCost = dbo.fnCalculateCostBetweenUOM(@intStockUOMId, intItemUOMId, @dblLastCost) 
FROM
	@tblInventoryTransaction t INNER JOIN tblICItem i
		ON t.intItemId = i.intItemId
WHERE	
	(@intSubLocationId IS NULL OR t.intSubLocationId = @intSubLocationId) 
	AND (@intStorageLocationId IS NULL OR t.intStorageLocationId = @intStorageLocationId) 
GROUP BY 
	i.intItemId
	,intItemUOMId
	,intItemLocationId
	,intCostingMethod

IF @ysnSeparateStockForUOMs = 0 
BEGIN 
	-- Convert all Quantities to Stock UOM. 
	INSERT INTO @tblInventoryTransactionsInStockUOM
	(
		intItemId
		,intItemUOMId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intCostingMethodId
		,dblQty
		,dblUnitStorage
	)
	SELECT 
		intItemId
		,intItemUOMId = @intStockUOMId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intCostingMethodId
		,dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(g.intItemUOMId, @intStockUOMId, g.dblQty)) 
		,dblUnitStorage = SUM(dbo.fnCalculateQtyBetweenUOM(g.intItemUOMId, @intStockUOMId, g.dblUnitStorage)) 
	FROM 
		@tblInventoryTransactionGrouped g
	GROUP BY
		intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intCostingMethodId

	-- Replace the data on @tblInventoryTransactionGrouped
	-- and convert the quantities back to the item UOMs. 
	DELETE FROM @tblInventoryTransactionGrouped	
	INSERT INTO @tblInventoryTransactionGrouped
	(
		intItemId
		,intItemUOMId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intCostingMethodId
		,dblQty
		,dblUnitStorage
		,dblCost
	)
	SELECT 
		i.intItemId
		,iu.intItemUOMId
		,stock.intItemLocationId
		,stock.intSubLocationId
		,stock.intStorageLocationId
		,stock.intCostingMethodId
		,dblQty = dbo.fnCalculateQtyBetweenUOM(stock.intItemUOMId, iu.intItemUOMId, stock.dblQty)
		,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(stock.intItemUOMId, iu.intItemUOMId, stock.dblUnitStorage)
		,dblCost = dbo.fnCalculateCostBetweenUOM(stock.intItemUOMId, iu.intItemUOMId, @dblLastCost) --@dblLastCost
	FROM 
		tblICItem i INNER JOIN tblICItemUOM iu
			ON i.intItemId = iu.intItemId
		INNER JOIN @tblInventoryTransactionsInStockUOM stock
			ON stock.intItemId = i.intItemId
	WHERE
		i.intItemId = @intItemId 
END

-- Get the current average cost 
SELECT @dblAverageCost = 
	p.dblAverageCost
FROM 
	tblICItemLocation il INNER JOIN tblICItemPricing p
		ON il.intItemId = p.intItemId
		AND il.intItemLocationId = p.intItemLocationId
WHERE
	il.intItemId = @intItemId
	AND il.intLocationId = @intLocationId

-- If item costing is AVG and @dtmDate is not the current date, recompute the average cost. 
IF @intCostingMethod = 1 AND dbo.fnRemoveTimeOnDate(@dtmDate) <> dbo.fnRemoveTimeOnDate(GETDATE()) 
BEGIN
	SELECT @dblAverageCost = 
		dbo.[fnICGetMovingAverageCost](
			il.intItemId
			, il.intItemLocationId
			, @intLastInventoryTransactionId
		)
	FROM 
		tblICItemLocation il 
	WHERE
		il.intItemId = @intItemId
		AND il.intLocationId = @intLocationId
END 

-- Return the result back to the caller. 
SELECT
	intKey	= CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId) AS INT)
	, i.intItemId
	, i.strItemNo 
	, intItemUOMId = ItemUOM.intItemUOMId 
	, strItemUOM = iUOM.strUnitMeasure 
	, strItemUOMType = iUOM.strUnitType 
	, ysnStockUnit = ItemUOM.ysnStockUnit 
	, dblUnitQty = ItemUOM.dblUnitQty 
	, CostMethod.strCostingMethod
	, CostMethod.intCostingMethodId
	, ItemLocation.intLocationId
	, strLocationName				= CompanyLocation.strLocationName
	, t.intSubLocationId
	, SubLocation.strSubLocationName
	, t.intStorageLocationId
	, strStorageLocationName		= strgLoc.strName
	, intOwnershipType				= @intOwnershipType
	, strOwnershipType				= dbo.fnICGetOwnershipType(@intOwnershipType)
	, dblRunningAvailableQty		= ROUND(ISNULL(t.dblQty, 0), 6)
	, dblRunningReservedQty			= ROUND(ISNULL(reserved.dblQty, 0), 6)
	, dblRunningAvailableQtyNoReserved = ROUND(ISNULL(t.dblQty, 0) - ISNULL(reserved.dblQty, 0), 6) 
	, dblStorageAvailableQty		= ROUND(ISNULL(t.dblUnitStorage, 0), 6) 
	, dblCost = 
		COALESCE (
			NULLIF(
				CASE 
					-- Get the average cost. 
					WHEN CostMethod.intCostingMethodId = 1 THEN 				
						dbo.fnCalculateCostBetweenUOM(
							@intStockUOMId
							, ItemUOM.intItemUOMId
							, @dblAverageCost
						)
					-- Otherwise, get the last cost 
					ELSE 
						t.dblCost
				END, 
				0
			)
			,NULLIF(ItemPricing.dblLastCost, 0)
			,ItemPricing.dblStandardCost
		)
	, intDecimalPlaces = iUOM.intDecimalPlaces
	, ItemUOM.ysnAllowPurchase
	, ItemUOM.ysnAllowSale
FROM tblICItem i INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) 
		ON ItemUOM.intItemId = i.intItemId
	LEFT JOIN @tblInventoryTransactionGrouped t
		ON t.intItemId = i.intItemId
		AND t.intItemUOMId = ItemUOM.intItemUOMId
	OUTER APPLY (		
		SELECT 
			dblQty = SUM(sr.dblQty) 
		FROM 
			tblICItemStockDetail sr
		WHERE 
			sr.intItemId = t.intItemId
			AND sr.intItemLocationId = t.intItemLocationId
			AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(t.intStorageLocationId, 0)
			AND ISNULL(sr.intSubLocationId, 0) = ISNULL(t.intSubLocationId, 0)
			AND sr.intItemStockTypeId = 9
	) reserved
	LEFT JOIN tblICItemUOM StockUOM
		ON StockUOM.intItemId = t.intItemId
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = t.intItemLocationId
    	AND ItemPricing.intItemId = ItemLocation.intItemId
	LEFT JOIN tblSMCompanyLocation CompanyLocation
		ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation
		ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
	LEFT JOIN tblICStorageLocation strgLoc
		ON strgLoc.intStorageLocationId = t.intStorageLocationId
	LEFT JOIN tblICCostingMethod CostMethod
		ON CostMethod.intCostingMethodId = t.intCostingMethodId
WHERE
	i.intItemId = @intItemId
ORDER BY
	ItemUOM.ysnStockUnit DESC 
	,iUOM.strUnitMeasure ASC