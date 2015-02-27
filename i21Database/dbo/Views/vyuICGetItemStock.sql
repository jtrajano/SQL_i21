CREATE VIEW [dbo].[vyuICGetItemStock]

AS 

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId, ItemStock.intItemStockId) AS INT),
	Item.intItemId,
	Item.strItemNo,
	Item.strType,
	Item.strDescription,
	Item.strLotTracking,
	Item.strInventoryTracking,
	Item.strStatus,
	ItemLocation.intLocationId,
	ItemLocation.intItemLocationId,
	ItemLocation.intSubLocationId,
	ItemLocation.intStorageLocationId,
	Location.strLocationName,
	Location.strLocationType,
	ItemLocation.intVendorId,
	strVendorId = (SELECT TOP 1 strVendorId FROM tblAPVendor WHERE intVendorId = ItemLocation.intVendorId),
	ItemLocation.intReceiveUOMId,
	ItemLocation.intIssueUOMId,

	strReceiveUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveSalePrice = ItemPricing.dblSalePrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveMSRPPrice = ItemPricing.dblMSRPPrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveLastCost = ItemPricing.dblLastCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveStandardCost = ItemPricing.dblStandardCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveAverageCost = ItemPricing.dblAverageCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveEndMonthCost = ItemPricing.dblEndMonthCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),

	strIssueUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueSalePrice = ItemPricing.dblSalePrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueMSRPPrice = ItemPricing.dblMSRPPrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueLastCost = ItemPricing.dblLastCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueStandardCost = ItemPricing.dblStandardCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueAverageCost = ItemPricing.dblAverageCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueEndMonthCost = ItemPricing.dblEndMonthCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),

	StorageLocation.strName AS strStorageLocationName,
	ItemLocation.dblMinOrder,
	ItemLocation.dblReorderPoint,
	ItemLocation.intAllowNegativeInventory,
	strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END),
	ItemLocation.intCostingMethod,
	strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END),
	ItemPricing.dblAmountPercent,
	ItemPricing.dblSalePrice ,
	ItemPricing.dblMSRPPrice ,
	ItemPricing.strPricingMethod,
	ItemPricing.dblLastCost,
	ItemPricing.dblStandardCost,
	ItemPricing.dblAverageCost,
	ItemPricing.dblEndMonthCost,
	ItemStock.dblUnitOnHand,
	ItemStock.dblOnOrder,
	ItemStock.dblOrderCommitted,
	ItemStock.dblBackOrder
	
FROM tblICItem Item
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
LEFT JOIN tblICItemPricing ItemPricing ON ItemLocation.intItemId = ItemPricing.intItemId AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblICItemStock ItemStock ON ItemStock.intItemId = Item.intItemId AND ItemLocation.intLocationId = ItemStock.intItemLocationId