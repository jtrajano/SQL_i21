CREATE VIEW [dbo].[vyuICGetItemStockUOMSummaryByUOM]
AS 

SELECT	StockUOM.intItemStockUOMId
		,StockUOM.intItemId
		,StockUOM.intItemLocationId
		,intLocationId = [Location].intCompanyLocationId
		,StockUOM.intSubLocationId
		,StockUOM.intStorageLocationId
		,StockUOM.intItemUOMId
		,ItemUOM.ysnStockUnit
		
		,Item.strItemNo
		,strLocation = [Location].strLocationName
		,strStorageLocation = SubLocation.strSubLocationName
		,strStorageUnit = StorageLocation.strName
		,UOM.strUnitMeasure

		,StockUOM.dblOnHand
		,StockUOM.dblOrderCommitted
		,StockUOM.dblOnOrder
		,StockUOM.dblUnitReserved
		,dblBackOrder = dbo.fnMaxNumeric(ISNULL(StockUOM.dblOrderCommitted, 0.00) - (ISNULL(StockUOM.dblOnHand, 0.00) - (ISNULL(StockUOM.dblUnitReserved, 0.00) + ISNULL(StockUOM.dblConsignedSale, 0.00))), 0)
		,dblAvailableQty = 
				ISNULL(StockUOM.dblOnHand, 0.00) 
				- ISNULL(StockUOM.dblUnitReserved, 0.00) 
				- ISNULL(StockUOM.dblConsignedSale, 0.00) 

FROM	tblICItemStockUOM StockUOM
		INNER JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
			AND ItemUOM.intItemId = StockUOM.intItemId
		INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		INNER JOIN tblICItem Item ON Item.intItemId = StockUOM.intItemId
		INNER JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
		LEFT JOIN tblSMCompanyLocation [Location] ON [Location].intCompanyLocationId = ItemLoc.intLocationId
		LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId

