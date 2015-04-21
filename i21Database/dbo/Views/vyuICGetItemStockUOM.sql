CREATE VIEW [dbo].[vyuICGetItemStockUOM]
	AS 

SELECT 
	StockUOM.intItemStockUOMId,
	StockUOM.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	strType = Item.strType,
	strLotTracking = Item.strLotTracking,
	intLocationId = Location.intCompanyLocationId,
	StockUOM.intItemLocationId,
	Location.strLocationName,
	StockUOM.intItemUOMId,
	UOM.strUnitMeasure,
	UOM.strUnitType,
	StockUOM.intSubLocationId,
	SubLocation.strSubLocationName,
	StockUOM.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	StockUOM.dblOnHand,
	StockUOM.dblOnOrder
FROM tblICItemStockUOM StockUOM
LEFT JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLoc.intLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId