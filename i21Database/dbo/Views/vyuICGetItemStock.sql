CREATE VIEW [dbo].[vyuICGetItemStock]

AS 

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId, ItemStock.intItemStockId) AS INT),
	Item.intItemId,
	Item.strItemNo,
	Item.strType,
	Item.strDescription,
	ItemLocation.intLocationId,
	Location.strLocationName,
	Location.strLocationType,
	ItemLocation.intVendorId,
	strVendorId = (SELECT TOP 1 strVendorId FROM tblAPVendor WHERE intVendorId = ItemLocation.intVendorId),
	ItemLocation.intReceiveUOMId,
	ItemLocation.intIssueUOMId,
	strReceiveUOM = (SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = ItemLocation.intReceiveUOMId),
	strIssueUOM = (SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = ItemLocation.intIssueUOMId),
	ItemLocation.intAllowNegativeInventory,
	strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END),
	ItemLocation.intCostingMethod,
	strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END),
	ItemStock.intUnitMeasureId,
	strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = ItemStock.intUnitMeasureId),
	ItemStock.dblUnitOnHand,
	ItemStock.dblAverageCost,
	ItemStock.dblMinOrder,
	ItemStock.dblOnOrder,
	ItemStock.dblOrderCommitted
FROM tblICItem Item
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblICItemStock ItemStock ON ItemStock.intItemId = Item.intItemId AND ItemLocation.intLocationId = ItemStock.intLocationId