CREATE VIEW [dbo].[vyuSTGetPricebookExport]

AS

SELECT CAST(ItemPricing.intItemPricingId AS NVARCHAR(1000)) + '0' + CAST(ItemUOM.intItemUOMId AS NVARCHAR(1000)) AS strUniqueId
	, Item.strItemNo
	, ItemPricing.intItemId
	, Item.strShortName
	, Item.strDescription
	, ItemLocation.strLocationName
	, ItemLocation.intItemLocationId
	, ItemLocation.intLocationId
	, ItemUOM.intItemUOMId
	, ItemLocation.intVendorId
	, ItemLocation.strVendorId
	, ItemLocation.strVendorName
	, UOM.strUnitMeasure
	, ItemUOM.strUpcCode
	, ItemUOM.strLongUPCCode
	, ItemPricing.dblLastCost
	, ItemPricing.dblSalePrice
	, ItemUOM.dblUnitQty
	, dblUOMCost = ItemUOM.dblUnitQty * ItemPricing.dblLastCost
	, ItemUOM.ysnStockUnit
	, ItemStock.dblAvailableQty
	, ItemStock.dblOnHand
	, CategoryLocation.intRegisterDepartmentId
FROM tblICItemPricing ItemPricing
LEFT JOIN tblICItem Item ON Item.intItemId = ItemPricing.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN vyuICGetItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
LEFT JOIN vyuICGetItemStockUOM ItemStock ON ItemStock.intItemId = Item.intItemId AND ItemStock.intItemLocationId = ItemLocation.intItemLocationId AND ItemStock.intItemUOMId = ItemUOM.intItemUOMId
LEFT JOIN vyuICCategoryLocation CategoryLocation ON CategoryLocation.intCategoryId = Item.intCategoryId AND CategoryLocation.intLocationId = ItemLocation.intLocationId