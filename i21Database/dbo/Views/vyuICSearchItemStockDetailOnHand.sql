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
	   ,strTransactionType = TransType.strName
FROM 
	tblICInventoryTransaction InventoryTransaction
	LEFT JOIN tblICItem Item 
		ON InventoryTransaction.intItemId = Item.intItemId
	LEFT JOIN tblICCommodity ItemCommodity 
		ON Item.intCommodityId = ItemCommodity.intCommodityId
	LEFT JOIN tblICCategory ItemCategory 
		ON Item.intCategoryId = ItemCategory.intCategoryId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON InventoryTransaction.intItemLocationId = ItemLocation.intItemLocationId
	LEFT JOIN tblSMCompanyLocation CompanyLocation 
		ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUnitOfMeasure 
		ON InventoryTransaction.intItemUOMId = ItemUnitOfMeasure.intItemUOMId
	LEFT JOIN tblICUnitMeasure UnitMeasure 
		ON ItemUnitOfMeasure.intUnitMeasureId = UnitMeasure.intUnitMeasureId
	LEFT JOIN tblICInventoryTransactionType TransType 
		ON TransType.intTransactionTypeId = InventoryTransaction.intTransactionTypeId
WHERE 
	strUnitMeasure IS NOT NULL