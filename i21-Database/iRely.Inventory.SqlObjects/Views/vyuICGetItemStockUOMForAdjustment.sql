CREATE VIEW [dbo].[vyuICGetItemStockUOMForAdjustment]
AS 

SELECT
	  intItemStockUOMId = ISNULL(suom.intItemStockUOMId, 0)
	, intItemId = i.intItemId
	, strItemNo = i.strItemNo
	, strItemDescription = i.strDescription
	, strType = i.strType
	, i.strBundleType
	, strLotTracking = i.strLotTracking
	, intLocationId = cl.intCompanyLocationId
	, strLocationName = cl.strLocationName
	, intItemLocationId = COALESCE(suom.intItemLocationId, il.intItemLocationId)
	, intItemUOMId = uom.intItemUOMId
	, strUnitMeasure = um.strUnitMeasure
	, strUnitType = um.strUnitType
	, intSubLocationId = suom.intSubLocationId
	, strSubLocationName = sl.strSubLocationName
	, intStorageLocationId = suom.intStorageLocationId
	, strStorageLocationName = su.strName
	, dblOnHand = CAST(ISNULL(suom.dblOnHand, 0.00) AS NUMERIC(18, 6))
	, dblUnitStorage = CAST(ISNULL(suom.dblUnitStorage, 0.00) AS NUMERIC(18, 6))
	, dblOnOrder = CAST(ISNULL(suom.dblOnOrder, 0.00) AS NUMERIC(18, 6))
	, dblUnitQty = CAST(ISNULL(uom.dblUnitQty, 0.00) AS NUMERIC(18, 6))
	, ysnStockUnit = CAST(ISNULL(uom.ysnStockUnit, 0) AS BIT)
FROM tblICItemUOM uom
	INNER JOIN tblICItemLocation il ON il.intItemId = uom.intItemId
	INNER JOIN tblICItem i ON i.intItemId = uom.intItemId
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = uom.intUnitMeasureId
	LEFT JOIN tblICItemStockUOM suom ON suom.intItemId = uom.intItemId
		AND suom.intItemLocationId = il.intItemLocationId
		AND suom.intItemUOMId = uom.intItemUOMId
	LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = suom.intSubLocationId
	LEFT JOIN tblICStorageLocation su ON su.intStorageLocationId = suom.intStorageLocationId
