CREATE VIEW [dbo].[vyuICGetItemStockSummaryByLot]
	AS 

SELECT
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY ItemStock.intItemId
			, ItemStock.intItemLocationId
			, ItemStock.intSubLocationId
			, ItemStock.intStorageLocationId
			, ItemStock.intItemUOMId
			, ItemStock.intLotId) AS INT)
	, ItemStock.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.intCommodityId
	, Commodity.strCommodityCode
	, ItemStock.intItemLocationId
	, ItemLocation.intLocationId
	, ItemLocation.intCountGroupId
	, Location.strLocationName
	, ItemStock.intSubLocationId
	, SubLocation.strSubLocationName
	, ItemStock.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, Lot.intItemUOMId
	, Lot.intWeightUOMId
	, UOM.strUnitMeasure
	, ItemStock.intLotId
	, Lot.strLotNumber
	, Lot.strLotAlias
	, ItemStock.dtmDate
	--, ItemStock.dblStockIn
	--, ItemStock.dblStockOut
	, dblLotQty  = CASE 
					WHEN Item.ysnLotWeightsRequired = 1 THEN ISNULL(dbo.fnDivide(ItemStock.dblOnHand, Lot.dblWeightPerQty), 0)
					ELSE ItemStock.dblOnHand
				END
	, dblLotWeight = CASE 
						WHEN Item.ysnLotWeightsRequired = 1 THEN dblOnHand
						ELSE 0
					END
	, dblConversionFactor = ItemUOM.dblUnitQty
	, Lot.dblWeightPerQty
	, ItemPricing.dblLastCost
	, dblTotalCost = ItemStock.dblOnHand * ItemUOM.dblUnitQty * ItemPricing.dblLastCost
	, Lot.intParentLotId
	, ParentLot.strParentLotNumber
	, ParentLot.strParentLotAlias
FROM (
	SELECT intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, intLotId
			, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
			, dblOnHand = SUM(dblQty)
			--, dblStockIn = SUM(dblStockIn)
			--, dblStockOut = SUM(dblStockOut)
			--, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
	FROM tblICInventoryTransaction
	--WHERE intLotId IS NOT NULL
	--FROM (
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId = NULL
	--		, intStorageLocationId = NULL
	--		, intItemUOMId
	--		, intLotId = NULL
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, dblStockIn = SUM(dblStockIn)
	--		, dblStockOut = SUM(dblStockOut)
	--		, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
	--	FROM tblICInventoryFIFO
	--	GROUP BY intItemId, intItemLocationId, intItemUOMId, CONVERT(VARCHAR(10),dtmDate,112)

	--	UNION ALL
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId = NULL
	--		, intStorageLocationId = NULL
	--		, intItemUOMId
	--		, intLotId = NULL
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, SUM(dblStockIn)
	--		, SUM(dblStockOut)
	--		, SUM(dblStockIn) - SUM(dblStockOut)
	--	FROM tblICInventoryLIFO
	--	GROUP BY intItemId, intItemLocationId, intItemUOMId, CONVERT(VARCHAR(10), dtmDate,112)

	--	UNION ALL
		
	--	 --SELECT intItemId
	--	 --	, intItemLocationId
	--	 --	, intSubLocationId
	--	 --	, intStorageLocationId
	--	 --	, intItemUOMId
	--	 --	, intLotId
	--		--, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--	 --	, SUM(dblStockIn)
	--	 --	, SUM(dblStockOut)
	--	 --	, SUM(dblStockIn) - SUM(dblStockOut)
	--	 --FROM tblICInventoryLot
	--	 --GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId, intLotId, CONVERT(VARCHAR(10),dtmDate,112)
	--	SELECT
	--		intItemId,
	--		intItemLocationId,
	--		intSubLocationId,
	--		intStorageLocationId,
	--		intItemUOMId,
	--		lot.intLotId,
	--		dtmDate = CAST(CONVERT(VARCHAR(10),invLot.dtmDate,112) AS datetime),
	--		SUM(dblQty),
	--		0,
	--		SUM(dblQty)
	--	FROM tblICLot lot
	--	LEFT JOIN (SELECT DISTINCT intLotId, dtmDate = MAX(CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)) FROM tblICInventoryLot GROUP BY intLotId) invLot ON invLot.intLotId = lot.intLotId
	--	GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId, lot.intLotId, invLot.dtmDate

	--	UNION ALL
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId = NULL
	--		, intStorageLocationId = NULL
	--		, intItemUOMId
	--		, intLotId = NULL
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, SUM(dblStockIn)
	--		, SUM(dblStockOut)
	--		, SUM(dblStockIn) - SUM(dblStockOut)
	--	FROM tblICInventoryActualCost
	--	GROUP BY intItemId, intItemLocationId, intItemUOMId, CONVERT(VARCHAR(10),dtmDate,112)

	--	UNION ALL
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId = NULL
	--		, intStorageLocationId = NULL
	--		, intItemUOMId
	--		, intLotId = NULL
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, SUM(dblStockIn)
	--		, SUM(dblStockOut)
	--		, SUM(dblStockIn) - SUM(dblStockOut)
	--	FROM tblICInventoryFIFOStorage
	--	GROUP BY intItemId, intItemLocationId, intItemUOMId, CONVERT(VARCHAR(10),dtmDate,112)

	--	UNION ALL
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId = NULL
	--		, intStorageLocationId = NULL
	--		, intItemUOMId
	--		, intLotId = NULL
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, SUM(dblStockIn)
	--		, SUM(dblStockOut)
	--		, SUM(dblStockIn) - SUM(dblStockOut)
	--		FROM tblICInventoryLIFOStorage
	--	GROUP BY intItemId, intItemLocationId, intItemUOMId, CONVERT(VARCHAR(10),dtmDate,112)

	--	UNION ALL
	--	SELECT intItemId
	--		, intItemLocationId
	--		, intSubLocationId
	--		, intStorageLocationId
	--		, intItemUOMId
	--		, intLotId
	--		, dtmDate = CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime)
	--		, SUM(dblStockIn)
	--		, SUM(dblStockOut)
	--		, SUM(dblStockIn) - SUM(dblStockOut)
	--	FROM tblICInventoryLotStorage
	--	GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId, intLotId, CONVERT(VARCHAR(10),dtmDate,112)
	--	) tblCostingBuckets
	GROUP BY intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, intLotId
			, CONVERT(VARCHAR(10), dtmDate,112)
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
	LEFT JOIN tblICLot Lot ON Lot.intLotId = ItemStock.intLotId
	LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId