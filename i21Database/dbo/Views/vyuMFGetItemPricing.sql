CREATE VIEW [dbo].[vyuMFGetItemPricing]
AS
SELECT Item.intItemId
	 , Item.strItemNo
	 , Item.strDescription
	 , Item.strType
	 , Item.intCategoryId
	 , Item.strStatus
	 , Item.strInventoryTracking
	 , ItemUOM.intItemUOMId AS intStockItemUOMId
	 , ItemUOM.intUnitMeasureId AS intStockUOMId 
	 , UnitMeasure.strUnitMeasure AS strStockUOM 
	 , Category.strCategoryCode
	 , Item.strRequired
	 , ISNULL(SalePrice.dblSalePrice, 0) AS dblSalePrice
FROM tblICItem AS Item 
JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId
JOIN tblICUnitMeasure AS UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
LEFT JOIN tblICCategory AS Category ON Item.intCategoryId = Category.intCategoryId
OUTER APPLY (SELECT TOP 1 dblSalePrice 
			 FROM tblICItemPricing
			 WHERE intItemId = Item.intItemId) AS SalePrice
WHERE ItemUOM.ysnStockUnit = 1 
  AND Item.strStatus = 'Active' 
  AND Item.strType NOT IN ('Comment','Other Charge')
UNION
SELECT intItemId
	 , strItemNo
	 , strDescription
	 , strType
	 , 0 AS intCategoryId
	 , '' AS strStatus
	 , '' AS strInventoryTracking
	 , 0 AS intStockItemUOMId
	 , 0 AS intStockUOMId
	 , '' AS strStockUOM
	 , '' AS strCategoryCode
	 , '' AS strRequired
	 , 0 AS dblSalePrice
FROM tblICItem 
WHERE strType in ('Comment','Other Charge')
