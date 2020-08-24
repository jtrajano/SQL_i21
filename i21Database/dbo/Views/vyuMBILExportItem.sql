CREATE VIEW [dbo].[vyuMBILExportItem]    
AS    
SELECT DISTINCT   
	ROW_NUMBER() OVER(ORDER BY strLocationNumber) AS intInventoryItemId,
	location.strLocationNumber,
	item.intItemId,
	item.strItemNo,
	item.strDescription,
	ISNULL(itemPricing.dblSalePrice, 0) as dblSalePrice,
	salesAccount.strAccountId, 
	unitMeasure.strUnitMeasure,  
	CASE WHEN item.strType IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') THEN 'N' ELSE 'Y' END as strType,
	item.intCategoryId

FROM tblICItem item    
INNER JOIN tblICItemLocation itemLocation ON itemLocation.intItemId = item.intItemId    
INNER JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = itemLocation.intLocationId    
INNER JOIN tblETExportFilterLocation ExportLocation ON location.intCompanyLocationId = ExportLocation.intCompanyLocationId    
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
WHERE item.strStatus = 'Active'    
 AND (item.intItemId = exportItem.intItemId OR item.intCategoryId = exportCategory.intCategoryId)