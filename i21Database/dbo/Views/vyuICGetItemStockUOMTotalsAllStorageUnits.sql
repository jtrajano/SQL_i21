CREATE VIEW [dbo].[vyuICGetItemStockUOMTotalsAllStorageUnits]
AS
	SELECT xl.*
	FROM (
	SELECT
			intLocationId = sl.intCompanyLocationId
		, i.intItemId
		, i.strItemNo
		, intSubLocationId = sl.intCompanyLocationSubLocationId
		, sl.strSubLocationName
		, sl.strSubLocationDescription
		, sl.strClassification
		, strStorageLocationName = COALESCE(v.strStorageLocationName, sloc.strName)
		, intStorageLocationId = COALESCE(v.intStorageLocationId, sloc.intStorageLocationId)
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
		FROM
			tblICItem i INNER JOIN tblICItemLocation il
			ON i.intItemId = il.intItemId
			INNER JOIN tblSMCompanyLocationSubLocation sl
			ON sl.intCompanyLocationId = il.intLocationId
			LEFT JOIN tblICStorageLocation sloc
			ON sloc.intSubLocationId = sl.intCompanyLocationSubLocationId
				AND sloc.intLocationId = sl.intCompanyLocationId
			LEFT JOIN vyuICGetItemStockUOMTotals v
			ON v.intItemId = i.intItemId
				AND v.intItemLocationId = il.intItemLocationId
				AND v.intSubLocationId = sl.intCompanyLocationSubLocationId
				AND v.intStorageLocationId = sloc.intStorageLocationId
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
) AS xl
	WHERE ((xl.intAllowNegativeInventory = 3 AND xl.ysnHasStock = 1) OR (xl.intAllowNegativeInventory = 1))