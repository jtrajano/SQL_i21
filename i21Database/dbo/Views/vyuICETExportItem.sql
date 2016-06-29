CREATE VIEW [dbo].[vyuICETExportItem]
AS
SELECT
	CAST(location.strLocationNumber AS VARCHAR(3)) inloc,
	CAST(item.strItemNo AS VARCHAR(15)) initm,
	CAST(item.strDescription AS VARCHAR(30)) indesc,
	NULL intax,
	CAST(ISNULL(itemPricing.dblSalePrice, 0) AS NUMERIC(18, 6)) salepr,
	CAST(REPLACE(salesAccount.strAccountId, '-', '') AS VARCHAR(13)) salact,
	unitMeasure.strUnitMeasure sunmsr,
	1 msgno, NULL interm,
	CASE WHEN item.strType IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') THEN 'N' ELSE 'Y' END Counted
FROM tblICItem item
	INNER JOIN tblICItemLocation itemLocation ON itemLocation.intItemId = item.intItemId
	INNER JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = itemLocation.intLocationId
	LEFT JOIN tblICItemPricing itemPricing ON itemPricing.intItemId = item.intItemId
		AND itemPricing.intItemLocationId = itemLocation.intItemLocationId
	LEFT JOIN tblICItemUOM itemUOM ON itemUOM.intItemId = item.intItemId
		AND itemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = itemUOM.intUnitMeasureId
	LEFT JOIN (
		SELECT itemAccount.intItemId, account.strAccountId
		FROM tblICItemAccount itemAccount
			INNER JOIN tblGLAccount account ON account.intAccountId = itemAccount.intAccountId
			INNER JOIN tblGLAccountCategory accountCategory ON accountCategory.intAccountCategoryId = itemAccount.intAccountCategoryId
		WHERE accountCategory.strAccountCategory = 'Sales Account'
	) salesAccount ON salesAccount.intItemId = item.intItemId
	LEFT OUTER JOIN tblETExportFilterItem exportItem ON item.intItemId = exportItem.intItemId
	LEFT OUTER JOIN tblETExportFilterCategory exportCategory ON item.intCategoryId = exportCategory.intCategoryId
WHERE item.ysnUsedForEnergyTracExport = 1
	AND item.intItemId = exportItem.intItemId OR item.intCategoryId = exportCategory.intCategoryId