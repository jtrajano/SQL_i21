CREATE VIEW [dbo].[vyuICETExportItem]
AS
SELECT Item.intItemId, ItemLocation.intItemLocationId,
	Item.strItemNo, Item.strDescription, Item.strType strItemType, Item.strLotTracking,
	CASE WHEN Item.strType IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') THEN 'Y' ELSE 'N' END strCounted,
	Measure.strUnitMeasure, ItemPricing.dblSalePrice, ItemAccount.intAccountId, Item.strStatus, Account.intAccountGroupId
FROM tblICItem Item
	LEFT OUTER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
	LEFT OUTER JOIN tblSMCompanyLocation Location ON ItemLocation.intLocationId = Location.intCompanyLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation sub ON sub.intCompanyLocationSubLocationId = ItemLocation.intSubLocationId
	LEFT OUTER JOIN tblICStorageLocation sloc ON sloc.intStorageLocationId = ItemLocation.intStorageLocationId
	LEFT OUTER JOIN tblICItemUOM UOM ON UOM.intItemId = Item.intItemId AND UOM.intItemUOMId = ItemLocation.intIssueUOMId
		AND UOM.ysnStockUnit = 1
	LEFT OUTER JOIN tblICUnitMeasure Measure ON Measure.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT OUTER JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId
		AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	LEFT OUTER JOIN tblICItemAccount ItemAccount ON ItemAccount.intItemId = Item.intItemId
	LEFT OUTER JOIN tblGLAccount Account ON Account.intAccountId = ItemAccount.intAccountId
	LEFT OUTER JOIN tblETExportFilterItem ExportItem ON Item.intItemId = ExportItem.intItemId
	LEFT OUTER JOIN tblETExportFilterCategory ExportCategory ON Item.intCategoryId = ExportCategory.intCategoryId
WHERE Item.ysnUsedForEnergyTracExport = 1 AND Item.intItemId = ExportItem.intItemId OR Item.intCategoryId = ExportCategory.intCategoryId