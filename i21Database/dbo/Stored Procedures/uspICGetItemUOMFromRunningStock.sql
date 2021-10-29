CREATE PROCEDURE [dbo].[uspICGetItemUOMFromRunningStock]
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
SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);

DECLARE @intStockUOM AS INT
		,@intLastInventoryTransactionId AS INT 

-- Get the item's stock unit. 
SELECT TOP 1 
	@intStockUOM = iu.intItemUOMId 
FROM 
	tblICItemUOM iu
WHERE
	iu.intItemId = @intItemId
	AND iu.ysnStockUnit = 1

-- Get the last valuation id
SELECT TOP 1 
	@intLastInventoryTransactionId = t.intInventoryTransactionId
FROM 
	tblICItem i INNER JOIN tblICItemLocation il
		ON il.intItemId = i.intItemId
		AND il.intLocationId = @intLocationId
	INNER JOIN tblICInventoryTransaction t 
		ON i.intItemId = t.intItemId
WHERE
	t.intItemId = @intItemId
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND t.intInTransitSourceLocationId IS NULL 
ORDER BY
	t.intInventoryTransactionId DESC 

DECLARE @tblInventoryTransaction TABLE(
	intItemId				INT,
	intItemUOMId			INT,
	intItemLocationId		INT,
	intSubLocationId		INT,
	intStorageLocationId	INT,
	intLotId				INT,
	intCostingMethod		INT,
	dtmDate					DATETIME,
	dblQty					NUMERIC(38, 20),
	dblUnitStorage			NUMERIC(38, 20),
	dblCost					NUMERIC(38, 20),
	intOwnershipType		INT
);

DECLARE @tblInventoryTransactionGrouped TABLE(
	intItemId				INT,
	intItemUOMId			INT,
	intItemLocationId		INT,
	intSubLocationId		INT,
	intStorageLocationId	INT,
	dblQty					NUMERIC(38, 20),
	dblUnitStorage			NUMERIC(38, 20),
	dblCost					NUMERIC(38, 20)
);

-- Get the stock quantities from the inventory transactions. 
INSERT INTO @tblInventoryTransaction (
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
-- Get the company-owned stocks
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
	,t.intCostingMethod
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
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND t.intInTransitSourceLocationId IS NULL 
	--AND ISNULL(t.ysnIsUnposted, 0) = 0 
	AND IL.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR  @intStorageLocationId = CASE WHEN Lot.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 1 -- Company-Owned Stocks

-- Get the customer-owned (aka Storage) stocks
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
		END	,Lot.intLotId
	,t.intCostingMethod
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
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND (@intSubLocationId IS NULL OR @intSubLocationId = CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END)
	AND @intOwnershipType = 2 -- Storage Stocks

-- Group the transaction to aggregrate the quantities. 
INSERT INTO @tblInventoryTransactionGrouped (
	intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId
	,intStorageLocationId
	,dblQty
	,dblUnitStorage
	,dblCost
)
SELECT 
	i.intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId = intSubLocationId
	,intStorageLocationId = intStorageLocationId
	,dblQty = SUM(ISNULL(t.dblQty, 0)) 
 	,dblUnitStorage = SUM(ISNULL(t.dblUnitStorage, 0))
	,dblCost = MAX(t.dblCost)
FROM	
	@tblInventoryTransaction t INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
GROUP BY 
	i.intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId
	,intStorageLocationId
HAVING 
	SUM(ISNULL(t.dblQty, 0)) <> 0 
	OR SUM(ISNULL(t.dblUnitStorage, 0)) <> 0 

-- If transaction does not exists for the item's uom, add a dummy record. 
BEGIN
	INSERT INTO @tblInventoryTransactionGrouped (
		intItemId
		,intItemUOMId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,dblUnitStorage
		,dblCost
	
	)
	SELECT	
		intItemId				= i.intItemId
		,intItemUOMId			= iu.intItemUOMId
		,intItemLocationId		= DefaultLocation.intItemLocationId
		,intSubLocationId		= @intSubLocationId
		,intStorageLocationId	= @intStorageLocationId
		,dblQty					= CAST(0 AS NUMERIC(38, 20)) 
		,dblUnitStorage			= CAST(0 AS NUMERIC(38, 20)) 
		,dblCost				= 0
	FROM 		
		tblICItem i INNER JOIN tblICItemUOM iu 
			ON i.intItemId = iu.intItemId 
		CROSS APPLY (
			SELECT	
				ItemLocation.intItemLocationId
				,ItemLocation.intCostingMethod
			FROM 
				tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
					ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
			WHERE 
				ItemLocation.intItemId = i.intItemId
				AND [Location].intCompanyLocationId = @intLocationId
		) DefaultLocation

		LEFT JOIN @tblInventoryTransactionGrouped g
			ON g.intItemId = i.intItemId
			AND g.intItemUOMId = iu.intItemUOMId
			AND g.intItemLocationId = DefaultLocation.intItemLocationId 

	WHERE 
		i.intItemId = @intItemId
		AND i.strLotTracking = 'No'
		AND (
			g.intItemId IS NULL
			AND g.intItemUOMId IS NULL
			AND g.intItemLocationId IS NULL 
		)
END

-- Return the result back to the caller. 
SELECT 
	intKey							= CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId) AS INT)
	,i.intItemId
	,i.strItemNo 
	,ItemUOM.intItemUOMId
	,strItemUOM = iUOM.strUnitMeasure
	,strItemUOMType = iUOM.strUnitType
	,ItemUOM.ysnStockUnit
	,ItemUOM.dblUnitQty
	,CostMethod.strCostingMethod
	,CostMethod.intCostingMethodId
	,ItemLocation.intLocationId
	,strLocationName				= CompanyLocation.strLocationName
	,t.intSubLocationId
	,SubLocation.strSubLocationName
	,t.intStorageLocationId
	,strStorageLocationName			= strgLoc.strName
	,intOwnershipType				= @intOwnershipType
	,strOwnershipType				= dbo.fnICGetOwnershipType(@intOwnershipType)
	,dblRunningAvailableQty			= t.dblQty
	,dblStorageAvailableQty			= t.dblUnitStorage
	,dblCost = 
		COALESCE(
			NULLIF(
				CASE 
					-- If costing method is AVG, get the average cost
					WHEN CostMethod.intCostingMethodId = 1 AND @intOwnershipType = 1  THEN 
						dbo.fnCalculateCostBetweenUOM (
							@intStockUOM
							,ItemUOM.intItemUOMId
							,dbo.fnICGetMovingAverageCost(
								i.intItemId
								,ItemLocation.intItemLocationId
								,@intLastInventoryTransactionId
							)
						)
					
					-- Otherwise, use the last cost from the valaution. 
					WHEN @intOwnershipType = 1 THEN 
						dbo.fnCalculateCostBetweenUOM (
							LastCost.intItemUOMId 
							,ItemUOM.intItemUOMId
							,LastCost.dblCost
						)						
				END
				,0
			)
			,dbo.fnCalculateCostBetweenUOM (
				@intStockUOM
				,ItemUOM.intItemUOMId
				,COALESCE(NULLIF(ItemPricing.dblLastCost, 0), ItemPricing.dblStandardCost) 
			)
		)
FROM 
	@tblInventoryTransactionGrouped t INNER JOIN tblICItem i 
		ON i.intItemId = t.intItemId
	INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) 
		ON ItemUOM.intItemUOMId = t.intItemUOMId

	-- Get the last cost from the valuation. 
	OUTER APPLY (
		SELECT TOP 1 
			t.intItemUOMId
			,t.dblCost
		FROM
			tblICInventoryTransaction t 
		WHERE
			t.intItemId = t.intItemId
			AND t.intItemLocationId = t.intItemLocationId
			AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
			AND t.intInTransitSourceLocationId IS NULL 
			AND t.dblQty > 0 
		ORDER BY
			t.intInventoryTransactionId DESC 		
	) LastCost 

	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemPricing.intItemLocationId = t.intItemLocationId
		AND ItemPricing.intItemId = ItemLocation.intItemId
	LEFT JOIN tblICCostingMethod CostMethod
		ON CostMethod.intCostingMethodId = ItemLocation.intCostingMethod
	LEFT JOIN tblSMCompanyLocation CompanyLocation 
		ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
	LEFT JOIN tblICStorageLocation strgLoc 
		ON strgLoc.intStorageLocationId = t.intStorageLocationId