CREATE VIEW [dbo].[vyuICGetItemStockUOMForAdjustment]
AS 

SELECT	StockUOM.intItemStockUOMId
		,Item.intItemId
		,Item.strItemNo
		,strItemDescription		= Item.strDescription
		,Item.strType
		,strLotTracking			= Item.strLotTracking
		,intLocationId			= Location.intCompanyLocationId
		,StockUOM.intItemLocationId
		,Location.strLocationName
		,ItemUOM.intItemUOMId
		,UOM.strUnitMeasure
		,UOM.strUnitType
		,intSubLocationId		= SubLocation.intCompanyLocationSubLocationId
		,SubLocation.strSubLocationName
		,StorageLocation.intStorageLocationId
		,strStorageLocationName	= StorageLocation.strName
		,dblOnHand				= CAST(ISNULL(StockUOM.dblOnHand, 0) AS NUMERIC(18, 6)) 
		,dblOnOrder				= CAST(ISNULL(StockUOM.dblOnOrder, 0) AS NUMERIC(18, 6)) 
		,dblUnitQty				= CAST(ISNULL(ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6)) 
		,ysnStockUnit			= CAST(ISNULL(ItemUOM.ysnStockUnit, 0) AS BIT)
FROM	tblICItem Item INNER JOIN tblICItemUOM ItemUOM
			ON Item.intItemId = ItemUOM.intItemId
		LEFT JOIN tblICItemStockUOM StockUOM
			ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
		LEFT JOIN tblICItemLocation ItemLoc
			ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
				AND ItemLoc.intItemId = Item.intItemId
		LEFT JOIN tblSMCompanyLocation Location 
			ON Location.intCompanyLocationId = ItemLoc.intLocationId
		LEFT JOIN tblICUnitMeasure UOM 
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation
			ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
		LEFT JOIN tblICStorageLocation StorageLocation 
			ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
