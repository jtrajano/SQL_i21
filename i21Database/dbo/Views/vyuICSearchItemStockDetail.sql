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
FROM 
	tblICItemStockDetail ItemStockDetail
	LEFT JOIN tblICItemStockType ItemStockType 
		ON ItemStockDetail.intItemStockTypeId = ItemStockType.intItemStockTypeId
	LEFT JOIN tblICItem Item 
		ON ItemStockDetail.intItemId = Item.intItemId
	LEFT JOIN tblICCommodity ItemCommodity 
		ON Item.intCommodityId = ItemCommodity.intCommodityId
	LEFT JOIN tblICCategory ItemCategory 
		ON Item.intCategoryId = ItemCategory.intCategoryId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemStockDetail.intItemLocationId = ItemLocation.intItemLocationId
	LEFT JOIN tblSMCompanyLocation CompanyLocation 
		ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUnitOfMeasure 
		ON ItemStockDetail.intItemUOMId = ItemUnitOfMeasure.intItemUOMId
	LEFT JOIN tblICUnitMeasure UnitMeasure 
		ON ItemUnitOfMeasure.intUnitMeasureId = UnitMeasure.intUnitMeasureId

