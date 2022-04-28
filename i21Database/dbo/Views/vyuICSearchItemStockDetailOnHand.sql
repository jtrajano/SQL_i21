CREATE VIEW [dbo].[vyuICSearchItemStockDetailOnHand]
AS 
SELECT  InventoryTransaction.intInventoryTransactionId
	   ,Item.strItemNo
	   ,Item.strDescription
	   ,Item.strType
	   ,ItemCommodity.strDescription AS strCommodityDescription
       ,ItemCategory.strDescription AS strCategoryDescription
	   ,CompanyLocation.strLocationName
	   ,InventoryTransaction.strTransactionId
	   ,UnitMeasure.strUnitMeasure
	   ,Item.strLotTracking
	   ,InventoryTransaction.dblQty
FROM tblICInventoryTransaction AS InventoryTransaction
LEFT JOIN tblICItem AS Item ON InventoryTransaction.intItemId = Item.intItemId
LEFT JOIN tblICCommodity AS ItemCommodity ON Item.intCommodityId = ItemCommodity.intCommodityId
LEFT JOIN tblICCategory AS ItemCategory ON Item.intCategoryId = ItemCategory.intCategoryId
LEFT JOIN tblICItemLocation AS ItemLocation ON InventoryTransaction.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICItemUOM AS ItemUnitOfMeasure ON InventoryTransaction.intItemUOMId = ItemUnitOfMeasure.intItemUOMId
LEFT JOIN tblICUnitMeasure AS UnitMeasure ON ItemUnitOfMeasure.intUnitMeasureId = UnitMeasure.intUnitMeasureId
WHERE strUnitMeasure IS NOT NULL