CREATE VIEW [dbo].[vyuICGetItemStockUOMTotalsAllLocations]
AS
	--SELECT xl.*
	--FROM (
	SELECT
		intLocationId = sl.intCompanyLocationId
		, i.intItemId
		, i.strItemNo
		, intSubLocationId = sl.intCompanyLocationSubLocationId
		, sl.strSubLocationName
		, sl.strSubLocationDescription
		, sl.strClassification
		, v.strStorageLocationName
		, v.intStorageLocationId
		, dblOnHand = ISNULL(v.dblOnHand, 0.0)
		, v.strUnitMeasure
		, v.intItemUOMId
		, v.intItemStockUOMId
        , il.intItemLocationId
		, ysnStockUnit = ISNULL(v.ysnStockUnit, CAST(0 AS BIT))
		, dblStorageQty = ISNULL(v.dblStorageQty, 0.00)
        , dblAvailableQty = ISNULL(v.dblAvailableQty, 0.00)
		, ysnHasStock = (CAST(CASE WHEN v.strSubLocationName IS NULL THEN 0 ELSE 1 END AS BIT))
		, il.intAllowNegativeInventory
		, dblCost = CASE 
				WHEN CostMethod.intCostingMethodId = 1 THEN dbo.fnGetItemAverageCost(i.intItemId, il.intItemLocationId, v.intItemUOMId)
				WHEN CostMethod.intCostingMethodId = 2 THEN dbo.fnCalculateCostBetweenUOM(FIFO.intItemUOMId, v.intItemUOMId, FIFO.dblCost)
				ELSE FIFO.dblCost
			END
		, dblUnitQty = iu.dblUnitQty
	FROM tblSMCompanyLocationSubLocation sl
		INNER JOIN tblICItemLocation il ON il.intLocationId = sl.intCompanyLocationId
		INNER JOIN tblICItem i ON i.intItemId = il.intItemId
		LEFT JOIN vyuICGetItemStockUOMTotals v ON v.intSubLocationId = sl.intCompanyLocationSubLocationId
			AND il.intItemLocationId = v.intItemLocationId
			AND v.ysnStockUnit = 1
			AND ((v.dblStorageQty + v.dblOnHand) > 0 OR v.intAllowNegativeInventory = 1)
		LEFT JOIN tblICCostingMethod CostMethod
				ON CostMethod.intCostingMethodId = il.intCostingMethod
		LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = v.intItemUOMId
		OUTER APPLY(
			SELECT TOP 1
					dblCost
					,intItemUOMId
			FROM	tblICInventoryFIFO FIFO 
			WHERE	i.intItemId = FIFO.intItemId 
					AND il.intItemLocationId = FIFO.intItemLocationId 
					AND dblStockIn- dblStockOut > 0
			ORDER BY dtmDate ASC
		) FIFO 
	GROUP BY
		  sl.intCompanyLocationId
		, i.intItemId
		, i.strItemNo
		, sl.intCompanyLocationSubLocationId
		, v.strSubLocationName
		, sl.strSubLocationName
		, sl.strSubLocationDescription
		, v.strStorageLocationName
		, v.intStorageLocationId
		, v.intItemUOMId
		, CostMethod.intCostingMethodId
		, FIFO.intItemUOMId
		, FIFO.dblCost
		, iu.dblUnitQty
		, v.dblOnHand
		, v.strUnitMeasure
		, v.intItemUOMId
		, v.intItemStockUOMId
        , il.intItemLocationId        
		, v.ysnStockUnit
		, v.dblStorageQty
        , v.dblAvailableQty
		, sl.strClassification
		, il.intAllowNegativeInventory
	HAVING (il.intAllowNegativeInventory = 3 AND (CAST(CASE WHEN v.strSubLocationName IS NULL THEN 0 ELSE 1 END AS BIT)) = 1) OR (il.intAllowNegativeInventory = 1)
--) AS xl
--WHERE ((xl.intAllowNegativeInventory = 3 AND xl.ysnHasStock = 1) OR (xl.intAllowNegativeInventory = 1))