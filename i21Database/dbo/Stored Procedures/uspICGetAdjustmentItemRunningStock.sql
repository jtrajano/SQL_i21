CREATE PROCEDURE [dbo].[uspICGetAdjustmentItemRunningStock]
	@intAdjustmentId INT,
	@ysnShowNoDiff BIT -- Show stock with no difference
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
	,t.dblCost
	,intOwnershipType	= 1
FROM
	tblICInventoryTransaction t
	INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intItemId = t.intItemId
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
WHERE t.intItemId = ad.intItemId
	AND dbo.fnDateLessThanEquals(t.dtmDate, a.dtmAdjustmentDate) = 1
	AND t.intInTransitSourceLocationId IS NULL
	AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND IL.intLocationId = a.intLocationId
	AND (ad.intSubLocationId IS NULL OR ad.intSubLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (ad.intStorageLocationId IS NULL OR ad.intStorageLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND ad.intOwnershipType = 1
	AND a.intInventoryAdjustmentId = @intAdjustmentId
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
	,t.dblCost
	,intOwnershipType	= 2
FROM
	tblICInventoryTransactionStorage t
	INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intItemId = t.intItemId
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
WHERE 
	t.intItemId = ad.intItemId
	AND IL.intLocationId = a.intLocationId
	AND dbo.fnDateLessThanEquals(t.dtmDate, a.dtmAdjustmentDate) = 1
	AND ISNULL(t.ysnIsUnposted, 0) = 0
	AND (ad.intSubLocationId IS NULL OR ad.intSubLocationId = CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (ad.intStorageLocationId IS NULL OR ad.intStorageLocationId = CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND ad.intOwnershipType = 2
	AND a.intInventoryAdjustmentId = @intAdjustmentId
-- end: Get the customer-owned (aka Storage) stocks

-- If transaction does not exists, add a dummy record. 
IF NOT EXISTS(SELECT TOP 1 1 FROM @tblInventoryTransaction)
BEGIN
	INSERT INTO @tblInventoryTransaction
	SELECT 
		i.intItemId
		,intItemUOMId		= ItemUOMStock.intItemUOMId
		,intItemLocationId	= DefaultLocation.intItemLocationId
		,intSubLocationId	= ad.intSubLocationId
		,intStorageLocationId= ad.intStorageLocationId
		,intLotId			= NULL
		,intCostingMethod	= DefaultLocation.intCostingMethod
		,dtmDate				= CAST(CONVERT(VARCHAR(10),a.dtmAdjustmentDate,112) AS datetime)
		,dblQty				= CAST(0 AS NUMERIC(38, 20))
		,dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
		,dblCost			= ItemPricing.dblLastCost
		,intOwnershipType	= 1
	FROM 
		tblICItem i
		INNER JOIN tblICItemUOM ItemUOMStock ON ItemUOMStock.intItemId = i.intItemId 
			AND ItemUOMStock.ysnStockUnit = 1
		INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intItemId = i.intItemId
		INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
		CROSS APPLY (
			SELECT 
				ItemLocation.intItemLocationId
				, ItemLocation.intCostingMethod
			FROM 
				tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location]
					ON [Location].intCompanyLocationId = ItemLocation.intLocationId
			WHERE 
				ItemLocation.intItemId = i.intItemId
				AND [Location].intCompanyLocationId = a.intLocationId
		) DefaultLocation
		LEFT JOIN tblICItemPricing ItemPricing
			ON i.intItemId = ItemPricing.intItemId
				AND DefaultLocation.intItemLocationId = ItemPricing.intItemLocationId
	WHERE 
		i.intItemId = ad.intItemId
		AND i.strLotTracking = 'No'
		AND a.intInventoryAdjustmentId = @intAdjustmentId
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
	, t.intItemUOMId
	, intItemLocationId
	, intSubLocationId = ad.intSubLocationId
	, intStorageLocationId = ad.intStorageLocationId
	, t.intCostingMethod
	, dblQty = SUM(t.dblQty) 
 	, dblUnitStorage = SUM(t.dblUnitStorage)
	, dblCost = MAX(t.dblCost)
FROM
	@tblInventoryTransaction t
	INNER JOIN tblICItem i ON t.intItemId = i.intItemId
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intItemId = t.intItemId
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
WHERE	
	(ad.intSubLocationId IS NULL OR t.intSubLocationId = ad.intSubLocationId) 
	AND (ad.intStorageLocationId IS NULL OR t.intStorageLocationId = ad.intStorageLocationId) 
	AND a.intInventoryAdjustmentId = @intAdjustmentId
GROUP BY 
	i.intItemId
	,t.intItemUOMId
	,intItemLocationId
	,t.intCostingMethod
	,ad.intStorageLocationId
	,ad.intSubLocationId

-- Return the result back to the caller. 
SELECT
	intKey							= ad.intInventoryAdjustmentDetailId
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
	, intOwnershipType				= ad.intOwnershipType
	, strOwnershipType				= dbo.fnICGetOwnershipType(ad.intOwnershipType)
	, dblRunningAvailableQty		= t.dblQty 
	, dblStorageAvailableQty		= t.dblUnitStorage
	, dblCost = CASE 
				WHEN CostMethod.intCostingMethodId = 1 THEN dbo.fnGetItemAverageCost(i.intItemId, ItemLocation.intItemLocationId, CASE WHEN ad.intSubLocationId IS NULL OR ad.intStorageLocationId IS NULL THEN stock.intItemUOMId ELSE ItemUOM.intItemUOMId END)
				WHEN CostMethod.intCostingMethodId = 2 THEN dbo.fnCalculateCostBetweenUOM(FIFO.intItemUOMId, StockUOM.intItemUOMId, FIFO.dblCost)
				WHEN CostMethod.intCostingMethodId = 3 THEN dbo.fnCalculateCostBetweenUOM(LIFO.intItemUOMId, StockUOM.intItemUOMId, LIFO.dblCost)
				ELSE t.dblCost
			END
	, dblDiffInQty = (CASE WHEN ad.intOwnershipType = 1 THEN t.dblQty - ad.dblQuantity ELSE t.dblUnitStorage - t.dblQty END)
	, ysnHasDiffQty = CAST(CASE WHEN (CASE WHEN ad.intOwnershipType = 1 THEN t.dblQty - ad.dblQuantity ELSE t.dblUnitStorage - t.dblQty END) <> 0 THEN 1 ELSE 0 END AS BIT)
FROM @tblInventoryTransactionGrouped t
	INNER JOIN tblICItem i ON i.intItemId = t.intItemId
	INNER JOIN tblICInventoryAdjustmentDetail ad ON ad.intItemId = t.intItemId
	INNER JOIN tblICInventoryAdjustment a ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
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
			s.intItemId = ad.intItemId
			AND (ad.intSubLocationId IS NULL OR s.intSubLocationId = ad.intSubLocationId)
			AND (ad.intStorageLocationId IS NULL OR s.intStorageLocationId = ad.intStorageLocationId)
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
	LEFT JOIN tblICCostingMethod CostMethod
		ON CostMethod.intCostingMethodId = t.intCostingMethodId	
	OUTER APPLY(
		SELECT TOP 1
			dblCost
			, intItemUOMId
		FROM	
			tblICInventoryFIFO FIFO
		WHERE	
			t.intItemId = FIFO.intItemId
			AND CostMethod.intCostingMethodId = 2
			AND t.intItemLocationId = FIFO.intItemLocationId
			AND FIFO.dblStockIn - FIFO.dblStockOut > 0
			AND dbo.fnDateLessThanEquals(FIFO.dtmDate, a.dtmAdjustmentDate) = 1
		ORDER BY FIFO.dtmDate ASC
	) FIFO
	OUTER APPLY(
		SELECT TOP 1
			dblCost
			, intItemUOMId
		FROM	
			tblICInventoryLIFO LIFO
		WHERE	
			t.intItemId = LIFO.intItemId
			AND CostMethod.intCostingMethodId = 3
			AND t.intItemLocationId = LIFO.intItemLocationId
			AND LIFO.dblStockIn - LIFO.dblStockOut > 0
			AND dbo.fnDateLessThanEquals(LIFO.dtmDate, a.dtmAdjustmentDate) = 1
		ORDER BY LIFO.dtmDate DESC
	) LIFO
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

WHERE a.intInventoryAdjustmentId = @intAdjustmentId
	AND 1 = CAST(CASE WHEN (CASE WHEN (CASE WHEN ad.intOwnershipType = 1 THEN t.dblQty - ad.dblQuantity 
			ELSE t.dblUnitStorage - t.dblQty END) <> 0 THEN 1 ELSE 0 END) = 0 THEN 
		 CASE WHEN @ysnShowNoDiff = 1 THEN 1 ELSE 0 END
	ELSE 1 END AS BIT)