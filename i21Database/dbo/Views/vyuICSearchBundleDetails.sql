CREATE VIEW vyuICSearchBundleDetails
AS

SELECT 
	i.strItemNo
	,i.intItemId
	,i.strBundleType
	,i.strShortName
	,i.strDescription
	,i.strStatus
	,i.intCommodityId
	,com.strCommodityCode
	,i.intCategoryId
	,cat.strCategoryCode
	,i.intBrandId
	,b.strBrandCode
	,i.intManufacturerId
	,m.strManufacturer
	,i.ysnListBundleSeparately
	,intBundleItemId = bundle.intItemId
	,strBundleItemNo = bundle.strItemNo
	,bundleItems.dblQuantity
	,bundleItems.intItemUnitMeasureId
	,bundleUOM.strUnitMeasure
FROM 
	tblICItem i 
	LEFT JOIN tblICCommodity com
		ON i.intCommodityId = com.intCommodityId
	LEFT JOIN tblICCategory cat
		ON cat.intCategoryId = i.intCategoryId
	LEFT JOIN tblICBrand b
		ON b.intBrandId = i.intBrandId
	LEFT JOIN tblICManufacturer m
		ON m.intManufacturerId = i.intManufacturerId
	LEFT JOIN (
		tblICItemBundle bundleItems INNER JOIN tblICItem bundle
			ON bundleItems.intBundleItemId = bundle.intItemId
		INNER JOIN tblICItemUOM bundleItemUOM 
			ON bundleItemUOM.intItemUOMId = bundleItems.intItemUnitMeasureId
		INNER JOIN tblICUnitMeasure bundleUOM
			ON bundleUOM.intUnitMeasureId = bundleItemUOM.intUnitMeasureId
	)
		ON bundleItems.intItemId = i.intItemId
WHERE
	i.strType IN ('Bundle')

