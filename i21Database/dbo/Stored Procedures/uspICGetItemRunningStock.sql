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
SET ANSI_WARNINGS OFF

DECLARE @DefaultLotCondition NVARCHAR(50)
SELECT @DefaultLotCondition = strLotCondition
FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);

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
	,intCostingMethod	= dbo.fnGetCostingMethod(t.intItemId, t.intItemLocationId)
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
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
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
	,intCostingMethod	= dbo.fnGetCostingMethod(t.intItemId, t.intItemLocationId)
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
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
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
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
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

-- Return the result back to the caller. 
SELECT
	intKey							= CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId) AS INT)
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
	, dblRunningAvailableQty		= ROUND(t.dblQty, 6)
	, dblRunningReservedQty			= ROUND(ISNULL(reserved.dblQty, 0), 6)
	, dblRunningAvailableQtyNoReserved = ROUND(ISNULL(t.dblQty, 0) - ISNULL(reserved.dblQty, 0), 6) 
	, dblStorageAvailableQty		= ROUND(t.dblUnitStorage, 6) 
	, dblCost = 
			CASE 
				-- Get the average cost. 
				WHEN CostMethod.intCostingMethodId = 1 THEN 				
					dbo.fnCalculateCostBetweenUOM(
						@intStockUOMId
						, ItemUOM.intItemUOMId
						, dbo.[fnICGetMovingAverageCost](
							t.intItemId
							, t.intItemLocationId
							, @intLastInventoryTransactionId
						)
					)
				-- Otherwise, get the last cost 
				ELSE 
					t.dblCost
			END
	, intDecimalPlaces = iUOM.intDecimalPlaces
	, ItemUOM.ysnAllowPurchase
	, ItemUOM.ysnAllowSale
FROM @tblInventoryTransactionGrouped t INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) 
		ON ItemUOM.intItemUOMId = t.intItemUOMId
	OUTER APPLY (
		SELECT SUM(ReservedQty.dblQty) dblQty
		FROM (
			SELECT sr.strTransactionId, sr.dblQty dblQty
			FROM tblICStockReservation sr
				LEFT JOIN tblICInventoryTransaction xt ON xt.intTransactionId = sr.intTransactionId
			WHERE sr.intItemId = t.intItemId
				AND sr.intItemLocationId = t.intItemLocationId
				AND ISNULL(sr.intStorageLocationId, 0) = ISNULL(t.intStorageLocationId, 0)
				AND ISNULL(sr.intSubLocationId, 0) = ISNULL(t.intSubLocationId, 0)
				--AND ISNULL(sr.intLotId, 0) = ISNULL(t.intLotId, 0)
				AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), xt.dtmDate,112), @dtmDate) = 1
			GROUP BY sr.strTransactionId, sr.dblQty
		) AS ReservedQty
	) reserved
	CROSS APPLY (
		SELECT
			SUM(s.dblOnHand) dblOnHand
			, SUM(s.dblUnitStorage) dblUnitStorage
			, s.intItemId
			, s.intItemLocationId
			, u.strUnitMeasure
			, i.intItemUOMId
			, u.strUnitType
			, i.dblUnitQty
			, i.ysnStockUnit
		FROM	
			tblICItemStockUOM s	INNER JOIN tblICItemUOM i 
				ON i.intItemUOMId = s.intItemUOMId
				AND s.intItemId = i.intItemId
				AND i.ysnStockUnit = 1
			INNER JOIN tblICUnitMeasure u 
				ON u.intUnitMeasureId = i.intUnitMeasureId
		WHERE 
			s.intItemId = @intItemId
			AND (@intSubLocationId IS NULL OR s.intSubLocationId = @intSubLocationId)
			AND (@intStorageLocationId IS NULL OR s.intStorageLocationId = @intStorageLocationId)
			AND s.intItemLocationId = t.intItemLocationId
		GROUP BY 
			s.intItemId
			, s.intItemLocationId
			, u.strUnitMeasure
			, i.intItemUOMId
			, u.strUnitType
			, i.dblUnitQty
			, i.ysnStockUnit
	) stock 

	LEFT JOIN tblICItemUOM StockUOM
		ON StockUOM.intItemId = t.intItemId
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblSMCompanyLocation CompanyLocation
		ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation
		ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
	LEFT JOIN tblICStorageLocation strgLoc
		ON strgLoc.intStorageLocationId = t.intStorageLocationId
	LEFT JOIN tblICCostingMethod CostMethod
		ON CostMethod.intCostingMethodId = t.intCostingMethodId
	ORDER BY iUOM.strUnitMeasure ASC
