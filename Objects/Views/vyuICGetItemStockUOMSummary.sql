CREATE VIEW [dbo].[vyuICGetItemStockUOMSummary]
	AS

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY StockUOM.intItemId
			, StockUOM.intItemLocationId
			, StockUOM.intSubLocationId
			, StockUOM.intStorageLocationId
			, StockUOM.intItemUOMId) AS INT)
	, StockUOM.intItemId
	, StockUOM.intItemLocationId
	, intLocationId = Location.intCompanyLocationId
	, Location.strLocationName
	, StockUOM.intItemUOMId
	, UOM.strUnitMeasure
	, ItemUOM.dblUnitQty
	, StockUOM.intSubLocationId
	, SubLocation.strSubLocationName
	, StockUOM.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, StockUOM.dblOnHand
	, StockUOM.dblInConsigned
	, StockUOM.dblOnOrder
	, StockUOM.dblOrderCommitted
	, StockUOM.dblUnitReserved
	, StockUOM.dblInTransitInbound
	, StockUOM.dblInTransitOutbound
	, StockUOM.dblUnitStorage
	, StockUOM.dblConsignedPurchase
	, StockUOM.dblConsignedSale
FROM tblICItemStockUOM StockUOM
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = StockUOM.intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
WHERE ItemUOM.ysnStockUnit = 1