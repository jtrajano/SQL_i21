CREATE VIEW [dbo].[vyuICGetItemStockUOMForAdjustment]
AS 

SELECT	StockUOM.intItemStockUOMId
		,intItemId								= Item.intItemId
		,strItemNo								= Item.strItemNo
		,strItemDescription						= Item.strDescription
		,strType								= Item.strType
		,strLotTracking							= Item.strLotTracking
		,intLocationId							= ISNULL(Location.intCompanyLocationId, ItemLoc2.intLocationId)
		,intItemLocationId						= ISNULL(StockUOM.intItemLocationId, ItemLoc2.intItemLocationId)
		,strLocationName						= ISNULL(Location.strLocationName, Location2.strLocationName)
		,intItemUOMId							= ItemUOM.intItemUOMId
		,strUnitMeasure							= UOM.strUnitMeasure
		,strUnitType							= UOM.strUnitType
		,intSubLocationId						= SubLocation.intCompanyLocationSubLocationId
		,strSubLocationName						= SubLocation.strSubLocationName
		,intStorageLocationId					= StorageLocation.intStorageLocationId
		,strStorageLocationName					= StorageLocation.strName
		,dblOnHand								= CAST(ISNULL(StockUOM.dblOnHand, 0) AS NUMERIC(18, 6)) 
		,dblOnOrder								= CAST(ISNULL(StockUOM.dblOnOrder, 0) AS NUMERIC(18, 6)) 
		,dblUnitQty								= CAST(ISNULL(ItemUOM.dblUnitQty, 0) AS NUMERIC(18, 6)) 
		,ysnStockUnit							= CAST(ISNULL(ItemUOM.ysnStockUnit, 0) AS BIT)
FROM tblICItemUOM ItemUOM 
	INNER JOIN tblICItem Item ON Item.intItemId = ItemUOM.intItemId
	CROSS APPLY tblICItemLocation ItemLoc2
	LEFT JOIN tblSMCompanyLocation Location2 ON Location2.intCompanyLocationId = ItemLoc2.intLocationId
	LEFT JOIN tblICItemStockUOM StockUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemLocationId = StockUOM.intItemLocationId
			AND ItemLoc.intItemId = Item.intItemId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLoc.intLocationId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StockUOM.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = StockUOM.intStorageLocationId
WHERE ItemLoc2.intItemId = ItemUOM.intItemId
