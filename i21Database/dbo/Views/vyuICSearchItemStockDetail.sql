CREATE VIEW [dbo].[vyuICSearchItemStockDetail]
AS 
SELECT ItemStockDetail.intItemStockDetailId
	   ,ItemStockDetail.intItemStockTypeId
	   ,Item.strItemNo
	   ,Item.strDescription
	   ,Item.strType
	   ,ItemCommodity.strDescription AS strCommodityDescription
       ,ItemCategory.strDescription AS strCategoryDescription
	   ,CompanyLocation.strLocationName
	   ,ItemStockDetail.strTransactionId
	   ,ItemStockType.strName AS strStockTypeName
	   ,UnitMeasure.strUnitMeasure
	   ,Item.strLotTracking
	   ,ItemStockDetail.dblQty
FROM tblICItemStockDetail AS ItemStockDetail
LEFT JOIN tblICItemStockType AS ItemStockType ON ItemStockDetail.intItemStockTypeId = ItemStockType.intItemStockTypeId
LEFT JOIN tblICItem AS Item ON ItemStockDetail.intItemId = Item.intItemId
LEFT JOIN tblICCommodity AS ItemCommodity ON Item.intCommodityId = ItemCommodity.intCommodityId
LEFT JOIN tblICCategory AS ItemCategory ON Item.intCategoryId = ItemCategory.intCategoryId
LEFT JOIN tblICItemLocation AS ItemLocation ON ItemStockDetail.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICItemUOM AS ItemUnitOfMeasure ON ItemStockDetail.intItemUOMId = ItemUnitOfMeasure.intItemUOMId
LEFT JOIN tblICUnitMeasure AS UnitMeasure ON ItemUnitOfMeasure.intUnitMeasureId = UnitMeasure.intUnitMeasureId

