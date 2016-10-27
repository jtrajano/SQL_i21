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
	Item.intCategoryId,
	Category.strCategoryCode,
	Item.intCommodityId,
	Commodity.strCommodityCode,
	StorageLocation.strName AS strStorageLocationName,
	SubLocation.strSubLocationName AS strSubLocationName,
	ItemLocation.intStorageLocationId,
	Location.strLocationName,
	Location.strLocationType,
	ItemLocation.intVendorId,
	strVendorId = Vendor.strVendorId,
	intStockUOMId = StockUOM.intItemUOMId,
	strStockUOM = StockUOM.strUnitMeasure,
	strStockUOMType = StockUOM.strUnitType,
	dblStockUnitQty = StockUOM.dblUnitQty,
	ItemLocation.intReceiveUOMId,
	dblReceiveUOMConvFactor = ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	COALESCE(ItemLocation.intIssueUOMId, ReceiveUOMStock.intItemUOMId) intIssueUOMId,
	dblIssueUOMConvFactor = ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	strReceiveUOMType = COALESCE(rUOM.strUnitType, rUOMStock.strUnitType),
	strIssueUOMType = COALESCE(iUOM.strUnitType, iUOMStock.strUnitType),
	strReceiveUOM = COALESCE(rUOM.strUnitMeasure, rUOMStock.strUnitMeasure),
	strReceiveUPC = ISNULL(COALESCE(ReceiveUOM.strUpcCode, ReceiveUOMStock.strUpcCode), ''),
	dblReceiveSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	dblReceiveMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	dblReceiveLastCost = ISNULL(ItemPricing.dblLastCost, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	dblReceiveStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	dblReceiveAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	dblReceiveEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, ReceiveUOMStock.dblUnitQty), 0),
	ysnReceiveUOMAllowPurchase = ISNULL(COALESCE(ReceiveUOM.ysnAllowPurchase, ReceiveUOMStock.ysnAllowPurchase), dbo.fnICCheckAllowPurchase(Item.intItemId)),
	ysnReceiveUOMAllowSale = ISNULL(COALESCE(ReceiveUOM.ysnAllowSale, ReceiveUOMStock.ysnAllowSale), dbo.fnICCheckAllowSale(Item.intItemId)),
	strIssueUOM = COALESCE(iUOM.strUnitMeasure, iUOMStock.strUnitMeasure),
	strIssueUPC = ISNULL(COALESCE(IssueUOM.strUpcCode, IssueUOMStock.strUpcCode), ''),
	dblIssueSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	dblIssueMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	dblIssueLastCost = ISNULL(ItemPricing.dblLastCost, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	dblIssueStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	dblIssueAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	dblIssueEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, IssueUOMStock.dblUnitQty), 0),
	ysnIssueUOMAllowPurchase = ISNULL(COALESCE(IssueUOM.ysnAllowPurchase, IssueUOMStock.ysnAllowPurchase), dbo.fnICCheckAllowPurchase(Item.intItemId)),
	ysnIssueUOMAllowSale = ISNULL(COALESCE(IssueUOM.ysnAllowSale, IssueUOMStock.ysnAllowSale), dbo.fnICCheckAllowSale(Item.intItemId)),
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

	dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0),
	dblInTransitInbound = ISNULL(ItemStock.dblInTransitInbound, 0),
	dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0),
	dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0),
	dblBackOrder =	CASE	-- Compute the back order qty when committed > available Qty. 
							WHEN	ISNULL(ItemStock.dblOrderCommitted, 0) > ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) + ISNULL(ItemStock.dblUnitReserved, 0) + ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))) )
									AND ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) + ISNULL(ItemStock.dblUnitReserved, 0) + ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))) ) > 0 THEN 
										ABS(
											ISNULL(ItemStock.dblOrderCommitted, 0)
											- ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) + ISNULL(ItemStock.dblUnitReserved, 0) + ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))) )										
										)
							ELSE 
								0
					END,
	dblOrderCommitted = ISNULL(ItemStock.dblOrderCommitted, 0),
	dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0),
	dblConsignedPurchase = ISNULL(ItemStock.dblConsignedPurchase, 0),
	dblConsignedSale = ISNULL(ItemStock.dblConsignedSale, 0),
	dblUnitReserved = ISNULL(ItemStock.dblUnitReserved, 0),
	dblLastCountRetail = ISNULL(ItemStock.dblLastCountRetail, 0),
	dblAvailable = 
				ISNULL(ItemStock.dblUnitOnHand, 0)  
				- (
						ISNULL(ItemStock.dblUnitReserved, 0) 
						+ ISNULL(ItemStock.dblInTransitOutbound, 0) 
						+ ISNULL(ItemStock.dblConsignedSale, 0)
				),
	
	Item.dblDefaultFull,
	Item.ysnAvailableTM,
	Item.dblMaintenanceRate,
	Item.strMaintenanceCalculationMethod,
	Item.dblOverReceiveTolerance,
	Item.dblWeightTolerance,
	Item.intGradeId,
	strGrade = Grade.strDescription,
	Item.intLifeTime,
	Item.strLifeTimeType,
	Item.ysnListBundleSeparately,
	dblExtendedCost = ISNULL(ItemStock.dblUnitOnHand, 0) * ISNULL(ItemPricing.dblAverageCost, 0)
FROM tblICItem Item
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId
LEFT JOIN tblICItemUOM ReceiveUOM ON ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId
LEFT JOIN tblICItemUOM ReceiveUOMStock ON ReceiveUOMStock.intItemId = Item.intItemId AND ReceiveUOMStock.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure rUOM ON rUOM.intUnitMeasureId = ReceiveUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure rUOMStock ON rUOMStock.intUnitMeasureId = ReceiveUOMStock.intUnitMeasureId
LEFT JOIN tblICItemUOM IssueUOM ON IssueUOM.intItemUOMId = ItemLocation.intIssueUOMId
LEFT JOIN tblICItemUOM IssueUOMStock ON IssueUOMStock.intItemId = Item.intItemId AND IssueUOMStock.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure iUOM ON iUOM.intUnitMeasureId = IssueUOM.intUnitMeasureId
LEFT JOIN tblICUnitMeasure iUOMStock ON iUOMStock.intUnitMeasureId = IssueUOMStock.intUnitMeasureId
LEFT JOIN tblICItemPricing ItemPricing ON ItemLocation.intItemId = ItemPricing.intItemId AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblICItemStock ItemStock ON ItemStock.intItemId = Item.intItemId AND ItemLocation.intItemLocationId = ItemStock.intItemLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = Item.intGradeId
LEFT JOIN vyuAPVendor Vendor ON Vendor.intEntityVendorId = ItemLocation.intVendorId
LEFT JOIN vyuICGetItemUOM StockUOM ON StockUOM.intItemId = Item.intItemId AND StockUOM.ysnStockUnit = 1