﻿CREATE VIEW [dbo].[vyuICGetItemStockUOM]
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
	Lot.intLotId,
	Lot.strLotNumber,
	Lot.strLotAlias,
	dblOnHand = (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN ISNULL(StockUOM.dblOnHand, 0) ELSE ISNULL(Lot.dblQty, 0) END),
	dblOnOrder = StockUOM.dblOnOrder,
	dblReservedQty = ISNULL(Reserve.dblTotalQty, 0),
	dblAvailableQty = (CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN (ISNULL(StockUOM.dblOnHand, 0) - ISNULL(Reserve.dblTotalQty, 0)) ELSE ISNULL(Lot.dblQty, 0) END)
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