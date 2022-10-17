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
	 , ISNULL(ItemPricing.dblSalePrice, 0) AS dblSalePrice
	 , CompanyLocation.intCompanyLocationId AS intCompanyLocationId
FROM tblICItem AS Item 
JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId
JOIN tblICItemPricing AS ItemPricing ON Item.intItemId = ItemPricing.intItemId
JOIN tblICUnitMeasure AS UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
JOIN tblICItemLocation AS ItemLocation ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intItemLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICCategory AS Category ON Item.intCategoryId = Category.intCategoryId
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
	 , 0 AS intCompanyLocationId
FROM tblICItem 
WHERE strType in ('Comment','Other Charge')
