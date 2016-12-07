CREATE VIEW [dbo].[vyuICGetItemStockSummary]
	AS 

SELECT
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY ItemStock.intItemId
	, ItemStock.intItemLocationId
	, ItemStock.intSubLocationId
	, ItemStock.intStorageLocationId
	, ItemStock.intItemUOMId) AS INT)
	, ItemStock.intItemId
	, ItemStock.intItemLocationId
	, ItemStock.intSubLocationId
	, ItemStock.intStorageLocationId
	, ItemStock.intItemUOMId
	, ItemStock.dblStockIn
	, ItemStock.dblStockOut
	, ItemStock.dblOnHand
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.intCommodityId
	, Commodity.strCommodityCode
	, ItemLocation.intLocationId
	, ItemLocation.intCountGroupId
	, Location.strLocationName
	, SubLocation.strSubLocationName
	, strStorageLocationName = StorageLocation.strName
	, UOM.strUnitMeasure
	, dblConversionFactor = ItemUOM.dblUnitQty
	, ItemPricing.dblLastCost
	, dblTotalCost = ItemStock.dblOnHand * ItemUOM.dblUnitQty * ItemPricing.dblLastCost
FROM (
	SELECT intItemId
			, intItemLocationId
			, intSubLocationId = COALESCE(tblCostingBuckets.intSubLocationId, s.intSubLocationId)
			, intStorageLocationId = COALESCE(tblCostingBuckets.intStorageLocationId, s.intStorageLocationId)
			, intItemUOMId
			, dblStockIn = SUM(dblStockIn)
			, dblStockOut = SUM(dblStockOut)
			, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
	FROM (
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId = NULL
			, intStorageLocationId = NULL
			, intItemUOMId
			, dblStockIn = SUM(dblStockIn)
			, dblStockOut = SUM(dblStockOut)
			, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryFIFO
		GROUP BY intItemId, intItemLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId = NULL
			, intStorageLocationId = NULL
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryLIFO
		GROUP BY intItemId, intItemLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryLot
		GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId = NULL
			, intStorageLocationId = NULL
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryActualCost
		GROUP BY intItemId, intItemLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId = NULL
			, intStorageLocationId = NULL
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryFIFOStorage
		GROUP BY intItemId, intItemLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId = NULL
			, intStorageLocationId = NULL
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
			FROM tblICInventoryLIFOStorage
		GROUP BY intItemId, intItemLocationId, intItemUOMId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, SUM(dblStockIn)
			, SUM(dblStockOut)
			, SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryLotStorage
		GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId
	) tblCostingBuckets
	CROSS APPLY (
		SELECT intSubLocationId = MAX(uom.intSubLocationId), intStorageLocationId = MAX(uom.intStorageLocationId)
		FROM tblICItemStockUOM uom
		WHERE uom.intItemId = tblCostingBuckets.intItemId
			AND uom.intItemLocationId = tblCostingBuckets.intItemLocationId
			AND uom.intItemUOMId = tblCostingBuckets.intItemUOMId
	) s
	GROUP BY tblCostingBuckets.intItemId
			, tblCostingBuckets.intItemLocationId
			, tblCostingBuckets.intSubLocationId
			, tblCostingBuckets.intStorageLocationId
			, tblCostingBuckets.intItemUOMId
			, s.intSubLocationId
			, s.intStorageLocationId
) ItemStock
	LEFT JOIN tblICItem Item ON Item.intItemId = ItemStock.intItemId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = ItemStock.intItemLocationId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = ItemStock.intItemLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemStock.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ItemStock.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ItemStock.intStorageLocationId