CREATE VIEW [dbo].[vyuICGetItemStockUOM]
	AS 

SELECT 
	intItemStockUOMId			= StockUOM.intItemStockUOMId
	, intItemId					= ISNULL(StockUOM.intItemId, Item.intItemId)
	, strItemNo					= Item.strItemNo
	, strItemDescription		= Item.strDescription
	, strType					= Item.strType
	, intCategoryId				= Item.intCategoryId
	, strCategory				= Category.strCategoryCode
	, intCommodityId			= Item.intCommodityId
	, strCommodity				= Commodity.strCommodityCode
	, strLotTracking			= Item.strLotTracking
	, intLocationId				= ISNULL(Location.intCompanyLocationId, ItemLocation2.intLocationId)
	, intItemLocationId			= ISNULL(StockUOM.intItemLocationId, ItemLocation2.intItemLocationId)
	, intCountGroupId			= ItemLoc.intCountGroupId
	, strCountGroup				= CountGroup.strCountGroup
	, strLocationName			= ISNULL(Location.strLocationName, Location2.strLocationName) 
	, intItemUOMId				= ISNULL(StockUOM.intItemUOMId, ItemUOM2.intItemUOMId)
	, strUnitMeasure			= ISNULL(UOM.strUnitMeasure, UOM2.strUnitMeasure)
	, strUnitType				= ISNULL(UOM.strUnitType, UOM2.strUnitType)
	, intSubLocationId			= ISNULL(StockUOM.intSubLocationId, SubLocation2.intCompanyLocationSubLocationId)
	, strSubLocationName		= ISNULL(SubLocation.strSubLocationName, SubLocation2.strSubLocationName)
	, intStorageLocationId		= ISNULL(StockUOM.intStorageLocationId, StorageLocation2.intStorageLocationId)
	, strStorageLocationName	= ISNULL(StorageLocation.strName, StorageLocation2.strName)
	, intLotId					= Lot.intLotId
	, strLotNumber				= Lot.strLotNumber
	, strLotAlias				= Lot.strLotAlias
	, dblOnHand					= (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END)
	, dblOnOrder				= StockUOM.dblOnOrder
	, dblReservedQty			= ISNULL(Reserve.dblTotalQty, 0)
	, dblAvailableQty			= CASE WHEN Lot.intLotId IS NOT NULL THEN Lot.dblQty
									ELSE ISNULL(StockUOM.dblOnHand, 0) - (ISNULL(StockUOM.dblUnitReserved, 0) + ISNULL(StockUOM.dblConsignedSale, 0))
								  END
	, dblStorageQty				= StockUOM.dblUnitStorage
	, dblUnitQty				= ItemUOM.dblUnitQty
	, ysnStockUnit				= ItemUOM.ysnStockUnit
	, dblStockUnitCost			= ItemPricing.dblLastCost
	, dblLastCost				= ItemPricing.dblLastCost * ItemUOM.dblUnitQty
	, intLifeTime				= Item.intLifeTime
	, strLifeTimeType			= Item.strLifeTimeType
FROM tblICItemStockUOM StockUOM
	FULL JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
	LEFT JOIN tblICItemLocation ItemLocation2 ON ItemLocation2.intItemId = Item.intItemId
		AND StockUOM.intItemId IS NULL
	LEFT JOIN tblSMCompanyLocation Location2 ON Location2.intCompanyLocationId = ItemLocation2.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation2 ON SubLocation2.intCompanyLocationId = ItemLocation2.intLocationId
	LEFT JOIN tblICStorageLocation StorageLocation2 ON StorageLocation2.intSubLocationId = SubLocation2.intCompanyLocationSubLocationId
	LEFT JOIN tblICItemUOM ItemUOM2 ON ItemUOM2.intItemId = ItemLocation2.intItemId
		AND ItemUOM2.intItemId = ItemLocation2.intItemId
		AND ItemUOM2.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure UOM2 ON UOM2.intUnitMeasureId = ItemUOM2.intUnitMeasureId

	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
	LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemLocationId = StockUOM.intItemLocationId
	LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = ItemLoc.intCountGroupId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLoc.intLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
	LEFT JOIN (
			SELECT intItemId
				, intItemLocationId
				, intItemUOMId
				, intSubLocationId
				, intStorageLocationId
				, dblTotalQty = SUM(dblQty)
			FROM tblICStockReservation
			GROUP BY intItemId
				, intItemLocationId
				, intItemUOMId
				, intSubLocationId
				, intStorageLocationId
		) Reserve ON Reserve.intItemId = StockUOM.intItemId
		AND Reserve.intItemLocationId = StockUOM.intItemLocationId
		AND Reserve.intItemUOMId = StockUOM.intItemUOMId
		AND Reserve.intSubLocationId = StockUOM.intSubLocationId
		AND Reserve.intStorageLocationId = StockUOM.intStorageLocationId
	LEFT JOIN tblICLot Lot ON Lot.intItemId = StockUOM.intItemId
		AND Lot.intItemLocationId = StockUOM.intItemLocationId
		AND Lot.intItemUOMId = StockUOM.intItemUOMId
		AND Lot.intSubLocationId = StockUOM.intSubLocationId
		AND Lot.intStorageLocationId = StockUOM.intStorageLocationId