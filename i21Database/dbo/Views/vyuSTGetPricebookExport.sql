CREATE VIEW [dbo].[vyuSTGetPricebookExport]
AS
SELECT CAST(ItemPricing.intItemPricingId AS NVARCHAR(1000)) + '0' + CAST(ItemUOM.intItemUOMId AS NVARCHAR(1000)) + '0' + CAST(ST.intStoreId AS NVARCHAR(1000)) COLLATE Latin1_General_CI_AS AS strUniqueId
    , ST.intStoreId
	, ST.intStoreNo
	, Item.strItemNo
	, ItemPricing.intItemId
	, CASE 
			WHEN ISNULL(Item.strShortName, '') != ''
				THEN Item.strShortName
			ELSE ItemLocation.strDescription
	END AS strShortName
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
	, dblLastCost = CAST(ItemPricing.dblLastCost AS NUMERIC(18, 6))
	, dblSalePrice = CAST(itemHierarchyPricing.dblSalePrice AS NUMERIC(18, 6))
	, dblUnitQty = CAST(ItemUOM.dblUnitQty AS NUMERIC(18, 6))
	, dblUOMCost = CAST(ItemUOM.dblUnitQty * ItemPricing.dblLastCost AS NUMERIC(18, 6))
	, ItemUOM.ysnStockUnit
	, dblAvailableQty = CAST(ItemStock.dblAvailableQty AS NUMERIC(18, 6))
	, dblOnHand = CAST(ItemStock.dblOnHand AS NUMERIC(18, 6))
	, CategoryLocation.strCashRegisterDepartment 
	, CASE 
			WHEN ItemUOM.strLongUPCCode NOT LIKE '%[^0-9]%' 
				THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
	END AS ysnIsUPCNumberic
FROM tblICItem Item 
LEFT JOIN tblICItemUOM ItemUOM 
	ON ItemUOM.intItemId = Item.intItemId
INNER JOIN tblICUnitMeasure UOM 
	ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemPricing ItemPricing
	ON ItemPricing.intItemId = Item.intItemId
LEFT JOIN vyuICGetItemLocation ItemLocation 
	ON ItemLocation.intItemId = Item.intItemId 
	AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
JOIN vyuSTItemHierarchyPricing itemHierarchyPricing
	ON Item.intItemId = itemHierarchyPricing.intItemId
	AND ItemLocation.intItemLocationId = itemHierarchyPricing.intItemLocationId
	AND ItemUOM.intItemUOMId = itemHierarchyPricing.intItemUOMId
LEFT JOIN tblSTStore ST
	ON ST.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN vyuICGetItemStockUOM ItemStock 
	ON ItemStock.intItemId = Item.intItemId 
	AND ItemStock.intItemLocationId = ItemLocation.intItemLocationId 
	AND ItemStock.intItemUOMId = ItemUOM.intItemUOMId
LEFT JOIN vyuICCategoryLocation CategoryLocation 
	ON CategoryLocation.intCategoryId = Item.intCategoryId 
	AND CategoryLocation.intLocationId = ItemLocation.intLocationId
WHERE ItemPricing.intItemPricingId IS NOT NULL
AND ItemUOM.intItemUOMId IS NOT NULL
AND ST.intStoreId IS NOT NULL
AND Item.intCategoryId IS NOT NULL
--AND CategoryLocation.strCashRegisterDepartment IS NOT NULL

--http://jira.irelyserver.com/browse/ST-1036
--http://jira.irelyserver.com/browse/ST-2050