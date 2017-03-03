CREATE VIEW [dbo].[vyuICGetItemStock]
AS
SELECT
	intKey										= CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId, ItemStock.intItemStockId) AS INT)
	, intItemId									= Item.intItemId
	, strItemNo									= Item.strItemNo
	, strType									= Item.strType
	, strDescription							= Item.strDescription
	, strLotTracking							= Item.strLotTracking
	, strInventoryTracking						= Item.strInventoryTracking
	, strStatus									= Item.strStatus
	, intLocationId								= ItemLocation.intLocationId
	, intItemLocationId							= ItemLocation.intItemLocationId
	, intSubLocationId							= ItemLocation.intSubLocationId
	, intCategoryId								= Item.intCategoryId
	, strCategoryCode							= Category.strCategoryCode
	, intCommodityId							= Item.intCommodityId
	, strCommodityCode							= Commodity.strCommodityCode
	, strStorageLocationName					= StorageLocation.strName
	, strSubLocationName						= SubLocation.strSubLocationName
	, intStorageLocationId						= ItemLocation.intStorageLocationId
	, strLocationName							= l.strLocationName
	, strLocationType							= l.strLocationType
	, intVendorId								= ItemLocation.intVendorId
	, strVendorId								= v.strVendorId
	, intStockUOMId								= StockUOM.intItemUOMId
	, strStockUOM								= sUOM.strUnitMeasure
	, strStockUOMType							= sUOM.strUnitType
	, dblStockUnitQty							= StockUOM.dblUnitQty
	, intReceiveUOMId							= COALESCE(ItemLocation.intReceiveUOMId, StockUOM.intItemUOMId)
	, dblReceiveUOMConvFactor					= ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, intIssueUOMId								= COALESCE(ItemLocation.intIssueUOMId, StockUOM.intItemUOMId)
	, dblIssueUOMConvFactor						= ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, strReceiveUOMType							= COALESCE(rUOM.strUnitType, sUOM.strUnitType)
	, strIssueUOMType							= COALESCE(iUOM.strUnitType, sUOM.strUnitType)
	, strReceiveUOM								= COALESCE(rUOM.strUnitMeasure, sUOM.strUnitMeasure)
	, strReceiveUPC								= ISNULL(COALESCE(ReceiveUOM.strUpcCode, StockUOM.strUpcCode), '')
	, dblReceiveSalePrice						= ISNULL(ItemPricing.dblSalePrice, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblReceiveMSRPPrice						= ISNULL(ItemPricing.dblMSRPPrice, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblReceiveLastCost						= ISNULL(ItemPricing.dblLastCost, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblReceiveStandardCost					= ISNULL(ItemPricing.dblStandardCost, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblReceiveAverageCost						= ISNULL(ItemPricing.dblAverageCost, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblReceiveEndMonthCost					= ISNULL(ItemPricing.dblEndMonthCost, 0.0) * ISNULL(COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, ysnReceiveUOMAllowPurchase				= COALESCE(ReceiveUOM.ysnAllowPurchase, StockUOM.ysnAllowPurchase)
	, ysnReceiveUOMAllowSale					= COALESCE(ReceiveUOM.ysnAllowSale, StockUOM.ysnAllowSale)
	, strIssueUOM								= COALESCE(iUOM.strUnitMeasure, sUOM.strUnitMeasure)
	, strIssueUPC								= COALESCE(IssueUOM.strUpcCode, StockUOM.strUpcCode, '')
	, dblIssueSalePrice							= ISNULL(ItemPricing.dblSalePrice, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblIssueMSRPPrice							= ISNULL(ItemPricing.dblMSRPPrice, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblIssueLastCost							= ISNULL(ItemPricing.dblLastCost, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblIssueStandardCost						= ISNULL(ItemPricing.dblStandardCost, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblIssueAverageCost						= ISNULL(ItemPricing.dblAverageCost, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, dblIssueEndMonthCost						= ISNULL(ItemPricing.dblEndMonthCost, 0.0) * ISNULL(COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty), 0.0)
	, ysnIssueUOMAllowPurchase					= COALESCE(IssueUOM.ysnAllowPurchase, StockUOM.ysnAllowPurchase)
	, ysnIssueUOMAllowSale						= COALESCE(IssueUOM.ysnAllowSale, StockUOM.ysnAllowSale)
	, dblMinOrder								= ISNULL(ItemLocation.dblMinOrder, 0.0)
	, dblReorderPoint							= ISNULL(ItemLocation.dblReorderPoint, 0.0)
	, intAllowNegativeInventory					= ItemLocation.intAllowNegativeInventory
	, strAllowNegativeInventory					= (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes' WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off' WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END)
	, intCostingMethod							= ItemLocation.intCostingMethod
	, strCostingMethod							= (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG' WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO' WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END)
	, dblAmountPercent							= ISNULL(ItemPricing.dblAmountPercent, 0.0)
	, dblSalePrice								= ISNULL(ItemPricing.dblSalePrice, 0.0)
	, dblMSRPPrice								= ISNULL(ItemPricing.dblMSRPPrice, 0.0)
	, strPricingMethod							= ItemPricing.strPricingMethod
	, dblLastCost								= ISNULL(ItemPricing.dblLastCost, 0.0)
	, dblStandardCost							= ISNULL(ItemPricing.dblStandardCost, 0.0)
	, dblAverageCost							= ISNULL(ItemPricing.dblAverageCost, 0.0)
	, dblEndMonthCost							= ISNULL(ItemPricing.dblEndMonthCost, 0.0)
	, dblOnOrder								= ISNULL(ItemStock.dblOnOrder, 0.0)
	, dblInTransitInbound						= ISNULL(ItemStock.dblInTransitInbound, 0.0)
	, dblUnitOnHand								= CAST(ItemStock.dblUnitOnHand AS NUMERIC(38, 7))
	, dblInTransitOutbound						= ISNULL(ItemStock.dblInTransitOutbound, 0.0)
	, dblBackOrder								= 
		CASE	-- Compute the back order qty when committed > available Qty. 
				WHEN	ISNULL(ItemStock.dblOrderCommitted, 0) > ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) 
					+ ISNULL(ItemStock.dblUnitReserved, 0) + ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))))
						AND ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) + ISNULL(ItemStock.dblUnitReserved, 0) 
							+ ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))) ) > 0 THEN 
							ABS(ISNULL(ItemStock.dblOrderCommitted, 0)
								- ((ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblBackOrder, 0) + ISNULL(ItemStock.dblUnitReserved, 0)
								+ ISNULL(ItemStock.dblInTransitOutbound, 0) + ISNULL(ItemStock.dblConsignedSale, 0))) )										
							)
				ELSE 
					0.0
		END
	, dblOrderCommitted							= ISNULL(ItemStock.dblOrderCommitted, 0)
	, dblUnitStorage							= ISNULL(ItemStock.dblUnitStorage, 0)
	, dblConsignedPurchase						= ISNULL(ItemStock.dblConsignedPurchase, 0)
	, dblConsignedSale							= ISNULL(ItemStock.dblConsignedSale, 0)
	, dblUnitReserved							= ISNULL(ItemStock.dblUnitReserved, 0)
	, dblLastCountRetail						= ISNULL(ItemStock.dblLastCountRetail, 0)
	, dblAvailable								= ISNULL(ItemStock.dblUnitOnHand, 0) - (ISNULL(ItemStock.dblUnitReserved, 0) + ISNULL(ItemStock.dblConsignedSale, 0))
	, dblDefaultFull							= Item.dblDefaultFull
	, ysnAvailableTM							= Item.ysnAvailableTM
	, dblMaintenanceRate						= Item.dblMaintenanceRate
	, strMaintenanceCalculationMethod			= Item.strMaintenanceCalculationMethod
	, dblOverReceiveTolerance					= Item.dblOverReceiveTolerance
	, dblWeightTolerance						= Item.dblWeightTolerance
	, intGradeId								= Item.intGradeId
	, strGrade									= Grade.strDescription
	, intLifeTime								= Item.intLifeTime
	, strLifeTimeType							= Item.strLifeTimeType
	, ysnListBundleSeparately					= Item.ysnListBundleSeparately
	, dblExtendedCost							= ISNULL(ItemStock.dblUnitOnHand, 0) * ISNULL(ItemPricing.dblAverageCost, 0)
FROM tblICItem Item 
	LEFT JOIN (tblICItemLocation ItemLocation
		INNER JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = ItemLocation.intLocationId
	) ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId IS NOT NULL 
	LEFT JOIN (tblICItemUOM ReceiveUOM
		INNER JOIN tblICUnitMeasure rUOM ON rUOM.intUnitMeasureId = ReceiveUOM.intUnitMeasureId
	) ON ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId
	LEFT JOIN (tblICItemUOM IssueUOM
		INNER JOIN tblICUnitMeasure iUOM ON iUOM.intUnitMeasureId = IssueUOM.intUnitMeasureId
	) ON IssueUOM.intItemUOMId = ItemLocation.intIssueUOMId
	LEFT JOIN (tblICItemUOM StockUOM 
		INNER JOIN tblICUnitMeasure sUOM ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	) ON StockUOM.intItemId = Item.intItemId 
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN tblICItemPricing ItemPricing ON ItemLocation.intItemId = ItemPricing.intItemId 
		AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId
	LEFT JOIN tblICItemStock ItemStock ON ItemStock.intItemId = Item.intItemId 
		AND ItemLocation.intItemLocationId = ItemStock.intItemLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = Item.intGradeId
	LEFT JOIN tblAPVendor v ON v.intEntityVendorId = ItemLocation.intVendorId
