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
	StorageLocation.strName AS strStorageLocationName,
	SubLocation.strSubLocationName AS strSubLocationName,
	ItemLocation.intStorageLocationId,
	Location.strLocationName,
	Location.strLocationType,
	ItemLocation.intVendorId,
	strVendorId = (SELECT TOP 1 strVendorId FROM tblAPVendor WHERE intVendorId = ItemLocation.intVendorId),
	intStockUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1),
	strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1),
	strStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1),
	ItemLocation.intReceiveUOMId,
	ItemLocation.intIssueUOMId,
	strReceiveUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	strIssueUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	strReceiveUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId),
	dblReceiveSalePrice = ISNULL(ItemPricing.dblSalePrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	dblReceiveMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	dblReceiveLastCost = ISNULL(ItemPricing.dblLastCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	dblReceiveStandardCost = ISNULL(ItemPricing.dblStandardCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	dblReceiveAverageCost = ISNULL(ItemPricing.dblAverageCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	dblReceiveEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intReceiveUOMId), 0),
	strIssueUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueSalePrice = ItemPricing.dblSalePrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueMSRPPrice = ItemPricing.dblMSRPPrice * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueLastCost = ItemPricing.dblLastCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueStandardCost = ItemPricing.dblStandardCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueAverageCost = ItemPricing.dblAverageCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblIssueEndMonthCost = ItemPricing.dblEndMonthCost * (SELECT TOP 1 ISNULL(dblUnitQty, 0) FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId),
	dblMinOrder = ISNULL(ItemLocation.dblMinOrder, 0),
	dblReorderPoint = ISNULL(ItemLocation.dblReorderPoint, 0),
	ItemLocation.intAllowNegativeInventory,
	strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END),
	ItemLocation.intCostingMethod,
	strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END),
	dblAmountPercent = ISNULL(ItemPricing.dblAmountPercent, 0),
	dblSalePrice = ISNULL(ItemPricing.dblSalePrice, 0),
	dblMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0),
	ItemPricing.strPricingMethod,
	dblLastCost = ISNULL(ItemPricing.dblLastCost, 0),
	dblStandardCost = ISNULL(ItemPricing.dblStandardCost, 0),
	dblAverageCost = ISNULL(ItemPricing.dblAverageCost, 0),
	dblEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0),
	dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0),
	dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0),
	dblOrderCommitted = ISNULL(ItemStock.dblOrderCommitted, 0),
	dblBackOrder = ISNULL(ItemStock.dblBackOrder, 0)
	
FROM tblICItem Item
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
LEFT JOIN tblICItemPricing ItemPricing ON ItemLocation.intItemId = ItemPricing.intItemId AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblICItemStock ItemStock ON ItemStock.intItemId = Item.intItemId AND ItemLocation.intItemLocationId = ItemStock.intItemLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId