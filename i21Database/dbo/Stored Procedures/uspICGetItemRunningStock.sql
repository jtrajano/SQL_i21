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

DECLARE @tblInventoryTransactionGrouped TABLE(
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
	AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND IL.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 1
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
	AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 2
-- end: Get the customer-owned (aka Storage) stocks

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
		,dtmDate				= CAST(CONVERT(VARCHAR(10),@dtmDate,112) AS datetime)
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
	, dblCost = MAX(t.dblCost)
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
	, dblRunningAvailableQty		= t.dblQty 
	, dblStorageAvailableQty		= t.dblUnitStorage
	, dblCost = CASE 
				WHEN CostMethod.intCostingMethodId = 1 THEN dbo.fnGetItemAverageCost(i.intItemId, ItemLocation.intItemLocationId, CASE WHEN @intSubLocationId IS NULL OR @intStorageLocationId IS NULL THEN stock.intItemUOMId ELSE ItemUOM.intItemUOMId END)
				WHEN CostMethod.intCostingMethodId = 2 THEN dbo.fnCalculateCostBetweenUOM(FIFO.intItemUOMId, StockUOM.intItemUOMId, FIFO.dblCost)
				ELSE t.dblCost
			END
FROM @tblInventoryTransactionGrouped t INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) 
		ON ItemUOM.intItemUOMId = t.intItemUOMId
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
	OUTER APPLY(
		SELECT TOP 1
			dblCost
			, intItemUOMId
		FROM	
			tblICInventoryFIFO FIFO
		WHERE	
			t.intItemId = FIFO.intItemId
			AND t.intItemLocationId = FIFO.intItemLocationId
			AND dblStockIn - dblStockOut > 0
		ORDER BY dtmDate ASC
	) FIFO
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
