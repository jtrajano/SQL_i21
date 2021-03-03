CREATE VIEW vyuICSearchBundleDetails
AS

SELECT 
	i.strItemNo
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