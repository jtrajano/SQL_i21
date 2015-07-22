CREATE VIEW [dbo].[vyuICGetItemCommodity]
	AS

SELECT Item.intItemId
, Item.strItemNo
, Item.strType
, Item.strDescription
, Item.strStatus
, Item.strModelNo
, Item.strLotTracking
, Item.intBrandId
, strBrand = Brand.strBrandCode
, Item.intManufacturerId
, strManufacturer = Manufacturer.strManufacturer
, Item.intCategoryId
, strCategory = Category.strCategoryCode
, ItemLocation.intItemLocationId
, ItemLocation.intLocationId
, strTracking = Item.strInventoryTracking
, Item.intCommodityId
, Commodity.strCommodityCode
, Item.intOriginId
, strOrigin = Origin.strDescription
, Item.intProductTypeId
, strProductType = ProductType.strDescription
, Item.intRegionId
, strRegion = Region.strDescription
, Item.intSeasonId
, strSeason = Season.strDescription
, Item.intClassVarietyId
, strClassVariety = Class.strDescription
, Item.intProductLineId
, strProductLine = ProductLine.strDescription
, Item.intGradeId
, strGrade = Grade.strDescription
FROM tblICItem Item
	LEFT JOIN tblICBrand Brand ON Brand.intBrandId = Item.intBrandId
	LEFT JOIN tblICManufacturer Manufacturer ON Manufacturer.intManufacturerId = Item.intManufacturerId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	INNER JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
	LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = Item.intProductTypeId
	LEFT JOIN tblICCommodityAttribute Region ON Region.intCommodityAttributeId = Item.intRegionId
	LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = Item.intSeasonId
	LEFT JOIN tblICCommodityAttribute Class ON Class.intCommodityAttributeId = Item.intClassVarietyId
	LEFT JOIN tblICCommodityAttribute ProductLine ON ProductLine.intCommodityAttributeId = Item.intProductLineId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = Item.intGradeId