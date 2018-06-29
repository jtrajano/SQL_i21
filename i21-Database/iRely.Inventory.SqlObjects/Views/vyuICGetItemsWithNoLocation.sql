CREATE VIEW [dbo].[vyuICGetItemsWithNoLocation]
AS 

SELECT 
	Item.intItemId
	,Item.strItemNo 
	,strItemDescription = Item.strDescription 
	,Item.strType 
	,ItemCommodity.strCommodityCode 
	,Item.intCategoryId
	,ItemCategory.strCategoryCode 
	,ItemManufacturer.strManufacturer 
	,ItemBrand.strBrandName 
	,ItemLocation.intLocationId
	,ItemLocation.intVendorId
	,Vendor.strVendorId
	,strVendorName = Vendor.strName 
FROM	
	tblICItem Item LEFT JOIN tblICItemLocation ItemLocation 
		ON Item.intItemId = ItemLocation.intItemId
	LEFT JOIN tblICCommodity ItemCommodity 
		ON Item.intCommodityId = ItemCommodity.intCommodityId
	LEFT JOIN tblICCategory ItemCategory 
		ON Item.intCategoryId = ItemCategory.intCategoryId
	LEFT JOIN tblICManufacturer ItemManufacturer 
		ON Item.intManufacturerId = ItemManufacturer.intManufacturerId
	LEFT JOIN tblICBrand ItemBrand 
		ON Item.intBrandId = ItemBrand.intBrandId
	LEFT JOIN vyuAPVendor Vendor 
		ON Vendor.[intEntityId] = ItemLocation.intVendorId
WHERE
	ItemLocation.intItemLocationId IS NULL 