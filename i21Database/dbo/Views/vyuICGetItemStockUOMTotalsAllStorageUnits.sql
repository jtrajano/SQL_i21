CREATE VIEW vyuICGetItemStockUOMTotalsAllStorageUnits
AS
SELECT xl.*
FROM (
	SELECT DISTINCT
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
	FROM tblSMCompanyLocationSubLocation sl
		INNER JOIN tblICItemLocation il ON il.intLocationId = sl.intCompanyLocationId
		INNER JOIN tblICItem i ON i.intItemId = il.intItemId
		LEFT JOIN tblICStorageLocation sloc ON sloc.intSubLocationId = sl.intCompanyLocationSubLocationId
			AND sloc.intLocationId = sl.intCompanyLocationId
		LEFT JOIN vyuICGetItemStockUOMTotals v ON v.intSubLocationId = sl.intCompanyLocationSubLocationId
			AND il.intItemLocationId = v.intItemLocationId
            AND v.ysnStockUnit = 1
            AND (v.dblOnHand > 0 OR v.intAllowNegativeInventory = 1)
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
		, sloc.strName
		, v.dblOnHand
		, sloc.intStorageLocationId
		, v.strUnitMeasure
		, v.intItemUOMId
		, v.intItemStockUOMId
        , il.intItemLocationId        
		, v.ysnStockUnit
		, v.dblStorageQty
        , v.dblAvailableQty
		, sl.strClassification
		, il.intAllowNegativeInventory
) AS xl
WHERE ((xl.intAllowNegativeInventory = 3 AND xl.ysnHasStock = 1) OR (xl.intAllowNegativeInventory = 1))