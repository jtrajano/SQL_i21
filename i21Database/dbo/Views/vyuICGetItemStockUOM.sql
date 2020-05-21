CREATE VIEW [dbo].[vyuICGetItemStockUOM]
	AS 

SELECT 
	StockUOM.intItemStockUOMId,
	StockUOM.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	strType = Item.strType,
	Item.strBundleType,
	Item.intCategoryId,
	strCategory = Category.strCategoryCode,
	Item.intCommodityId,
	strCommodity = Commodity.strCommodityCode,
	strLotTracking = Item.strLotTracking,
	intLocationId = Location.intCompanyLocationId,
	StockUOM.intItemLocationId,
	ItemLoc.intCountGroupId,
	CountGroup.strCountGroup,
	Location.strLocationName,
	StockUOM.intItemUOMId,
	UOM.strUnitMeasure,
	UOM.strUnitType,
	StockUOM.intSubLocationId,
	SubLocation.strSubLocationName,
	StockUOM.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	Lot.intLotId,
	Lot.strLotNumber,
	Lot.strLotAlias,
	dblOnHand = (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END),	
	dblOnOrder = StockUOM.dblOnOrder,
	dblReservedQty = ISNULL(Reserve.dblTotalQty, 0),
	dblAvailableQty = 
		CASE	WHEN Lot.intLotId IS NOT NULL THEN 
					Lot.dblQty
				ELSE 
					ISNULL(StockUOM.dblOnHand, 0)  
					- (
							ISNULL(StockUOM.dblUnitReserved, 0) 
							-- + ISNULL(StockUOM.dblInTransitOutbound, 0) 
							+ ISNULL(StockUOM.dblConsignedSale, 0)
					)
		END,

	dblStorageQty = StockUOM.dblUnitStorage,
	dblUnitQty = ItemUOM.dblUnitQty,
	ysnStockUnit = ItemUOM.ysnStockUnit,
	dblStockUnitCost = ItemPricing.dblLastCost,
	dblLastCost = ItemPricing.dblLastCost * ItemUOM.dblUnitQty,
	Item.intLifeTime,
	Item.strLifeTimeType,
	strReceiveUPC = COALESCE(ItemUOM.strLongUPCCode, ItemUOM.strLongUPCCode, ''),
	Item.ysnLotWeightsRequired,
	ItemLoc.ysnStorageUnitRequired
FROM tblICItemStockUOM StockUOM
LEFT JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
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

UNION

SELECT
	intItemStockUOMId = im.intItemUOMId,
	i.intItemId,
	i.strItemNo,
	strItemDescription = i.strDescription,
	strType = i.strType,
	i.strBundleType,
	i.intCategoryId,
	strCategory = cg.strCategoryCode,
	i.intCommodityId,
	strCommodity = cd.strCommodityCode,
	strLotTracking = i.strLotTracking,
	intLocationId = c.intCompanyLocationId,
	l.intItemLocationId,
	l.intCountGroupId,
	g.strCountGroup,
	c.strLocationName,
	im.intItemUOMId,
	u.strUnitMeasure,
	u.strUnitType,
	intSubLocationId = NULL,
	strSubLocationName = NULL,
	intStorageLocationId = NULL,
	strStorageLocationName = NULL,
	intLotId = NULL,
	strLotNumber = NULL,
	strLotAlias = NULL,
	dblOnHand = 0,	
	dblOnOrder = 0,
	dblReservedQty = 0,
	dblAvailableQty = 0,
	dblStorageQty = 0,
	dblUnitQty = im.dblUnitQty,
	ysnStockUnit = im.ysnStockUnit,
	dblStockUnitCost = p.dblLastCost,
	dblLastCost = p.dblLastCost,
	i.intLifeTime,
	i.strLifeTimeType,
	strReceiveUPC = COALESCE(im.strLongUPCCode, im.strLongUPCCode, ''),
	i.ysnLotWeightsRequired,
	l.ysnStorageUnitRequired
FROM tblICItem i
	INNER JOIN tblICItemUOM im ON im.intItemId = i.intItemId
		AND im.ysnStockUnit = 1
	INNER JOIN tblICItemLocation l ON l.intItemId = i.intItemId
	INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = im.intUnitMeasureId
	LEFT OUTER JOIN tblICItemPricing p ON p.intItemId = i.intItemId
		AND p.intItemLocationId = l.intItemLocationId
	INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = l.intLocationId
	LEFT OUTER JOIN tblICCountGroup g ON g.intCountGroupId = l.intCountGroupId
	LEFT OUTER JOIN tblICCommodity cd ON cd.intCommodityId = i.intCommodityId
	LEFT OUTER JOIN tblICCategory cg ON cd.intCommodityId = i.intCategoryId
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemStockUOM
	WHERE intItemId = i.intItemId
		AND intItemLocationId = l.intItemLocationId
		AND im.intItemUOMId = intItemUOMId)