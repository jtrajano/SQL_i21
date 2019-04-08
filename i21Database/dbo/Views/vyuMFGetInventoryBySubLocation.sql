CREATE VIEW vyuMFGetInventoryBySubLocation
AS
SELECT [Location Name] = c.strLocationName
	,[Commodity Code] = cd.strCommodityCode
	,[Product Type] = att.strDescription
	,[Item No] = i.strItemNo
	,[Item Description] = i.strDescription
	,[Sub Location Name] = sc.strSubLocationName
	,Stock = SUM((sm.dblOnHand + sm.dblUnitStorage))
	,[Unit Measure] = um.strUnitMeasure
FROM tblICItemStockUOM sm
INNER JOIN tblICItemUOM im ON im.intItemUOMId = sm.intItemUOMId
	AND im.ysnStockUnit = 1
INNER JOIN tblICItem i ON i.intItemId = sm.intItemId
INNER JOIN tblICItemLocation il ON il.intItemId = sm.intItemId
	AND il.intItemLocationId = sm.intItemLocationId
	AND il.intLocationId = 1
INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
LEFT OUTER JOIN tblICCommodity cd ON cd.intCommodityId = i.intCommodityId
INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
LEFT JOIN tblICCommodityAttribute att ON att.intCommodityAttributeId = i.intProductTypeId
WHERE i.strType IN (
		N'Inventory'
		,N'Finished Good'
		,N'Raw Material'
		)
GROUP BY sm.intItemId
	,sc.strSubLocationName
	,c.strLocationName
	,i.strItemNo
	,i.strDescription
	,cd.strCommodityCode
	,um.strUnitMeasure
	,att.strDescription
