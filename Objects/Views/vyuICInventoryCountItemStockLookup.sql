CREATE VIEW [dbo].[vyuICInventoryCountItemStockLookup]
AS 
SELECT
      intKey                 = CAST(ROW_NUMBER() OVER(ORDER BY iu.intItemUOMId, i.intItemId, il.intItemLocationId) AS INT)
    , intItemId              = i.intItemId
    , strItemNo              = i.strItemNo 
    , dblOnHand              = ISNULL(su.dblOnHand, 0) 
    , intItemStockUOMId      = su.intItemStockUOMId
    , intSubLocationId       = subloc.intCompanyLocationSubLocationId
    , intStorageLocationId   = storageLoc.intStorageLocationId
	, intLocationId          = il.intLocationId
	, strSubLocationName     = subloc.strSubLocationName
	, strStorageLocationName = storageLoc.strName
	, intUnitMeasureId       = u.intUnitMeasureId
    , strUnitMeasure         = u.strUnitMeasure
	, intItemUOMId           = iu.intItemUOMId
FROM tblICItem i
    LEFT JOIN tblICItemLocation il ON i.intItemId = il.intItemId
    LEFT JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId
    LEFT JOIN tblSMCompanyLocationSubLocation subloc ON	subloc.intCompanyLocationId = il.intLocationId
	LEFT JOIN tblICStorageLocation storageLoc ON storageLoc.intSubLocationId = subloc.intCompanyLocationSubLocationId
    LEFT JOIN tblICItemStockUOM su ON su.intItemId = i.intItemId
    	AND su.intItemLocationId = il.intItemLocationId
    	AND su.intItemUOMId = iu.intItemUOMId
    	AND	su.intSubLocationId = subloc.intCompanyLocationSubLocationId
    	AND su.intStorageLocationId = storageLoc.intStorageLocationId
	LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId