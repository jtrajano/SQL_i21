CREATE VIEW [dbo].[vyuICGetItemStockUOMTotals]
AS 

SELECT 
	StockUOM.intItemStockUOMId,
	StockUOM.intItemId,
	intLocationId = Location.intCompanyLocationId,
	StockUOM.intItemLocationId,
	Location.strLocationName,
	StockUOM.intItemUOMId,
	UOM.strUnitMeasure,
	StockUOM.intSubLocationId,
	SubLocation.strSubLocationName,
	StockUOM.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	dblOnHand = SUM((CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END)),	
	dblAvailableQty = 
		SUM(
			CASE	WHEN Lot.intLotId IS NOT NULL THEN 
						Lot.dblQty
					ELSE 
						ISNULL(StockUOM.dblOnHand, 0)  
						- (
								ISNULL(StockUOM.dblUnitReserved, 0) 
								--+ ISNULL(StockUOM.dblInTransitOutbound, 0) 
								+ ISNULL(StockUOM.dblConsignedSale, 0)
						)
			END
		),
	dblStorageQty = SUM(StockUOM.dblUnitStorage),
	ysnStockUnit = ItemUOM.ysnStockUnit,
	ItemLoc.intAllowNegativeInventory
FROM tblICItemStockUOM StockUOM
	LEFT JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
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
	GROUP BY ItemUOM.ysnStockUnit,
		StockUOM.intItemStockUOMId,
		ItemLoc.intAllowNegativeInventory,
		StockUOM.intItemId,
		Location.intCompanyLocationId,
		StockUOM.intItemLocationId,
		Location.strLocationName,
		StockUOM.intItemUOMId,
		UOM.strUnitMeasure,
		StockUOM.intSubLocationId,
		SubLocation.strSubLocationName,
		StockUOM.intStorageLocationId,
		StorageLocation.strName