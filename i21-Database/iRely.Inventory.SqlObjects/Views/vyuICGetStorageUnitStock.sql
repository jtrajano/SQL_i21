CREATE VIEW [dbo].[vyuICGetStorageUnitStock]
AS
SELECT
      intItemStockUOMId		= StockUOM.intItemStockUOMId
	, strItemNo				= Item.strItemNo
	, intItemId				= Item.intItemId
	, intCommodityId		= Item.intCommodityId
	, strCommodityCode		= Commodity.strCommodityCode
	, intLocationId			= ItemLoc.intLocationId
	, strLocation			= Location.strLocationName
	, intStorageLocationId	= SubLocation.intCompanyLocationSubLocationId
	, strStorageLocation	= SubLocation.strSubLocationName
	, intStorageUnitId		= StorageLocation.intStorageLocationId
	, strStorageUnit		= StorageLocation.strName
	, dblOnHand				= (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END)
	, strUnitMeasure		= UOM.strUnitMeasure
	, dblEffectiveDepth		= StorageLocation.dblEffectiveDepth
	, dblResidualUnit		= StorageLocation.dblResidualUnit
	, dblUnitPerFoot		= StorageLocation.dblUnitPerFoot
	, dblPackFactor			= StorageLocation.dblPackFactor
	, intLotId				= Lot.intLotId
	, strLotNumber			= Lot.strLotNumber
FROM tblICItemStockUOM StockUOM
	INNER JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
	LEFT OUTER JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
	LEFT OUTER JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLoc.intLocationId
	LEFT OUTER JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
	LEFT OUTER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT OUTER JOIN tblICLot Lot ON Lot.intItemId = StockUOM.intItemId
		AND Lot.intItemLocationId = StockUOM.intItemLocationId
		AND Lot.intItemUOMId = StockUOM.intItemUOMId
		AND Lot.intSubLocationId = StockUOM.intSubLocationId
		AND Lot.intStorageLocationId = StockUOM.intStorageLocationId