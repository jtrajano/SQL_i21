CREATE VIEW [dbo].[vyuICGetItemStock]
AS 

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId, ItemStockUOM.intItemStockUOMId) AS INT)
	,Item.intItemId
	,Item.strItemNo
	,Item.strType
	,Item.strDescription
	,Item.strLotTracking
	,Item.strInventoryTracking
	,Item.strStatus
	,ItemLocation.intLocationId
	,ItemLocation.intItemLocationId
	,ItemLocation.intSubLocationId
	,Item.intCategoryId
	,Category.strCategoryCode
	,Item.intCommodityId
	,Commodity.strCommodityCode
	,StorageLocation.strName AS strStorageLocationName
	,SubLocation.strSubLocationName AS strSubLocationName
	,ItemLocation.intStorageLocationId
	,l.strLocationName
	,l.strLocationType
	,ItemLocation.intVendorId
	,strVendorId = v.strVendorId
	,intStockUOMId = StockUOM.intItemUOMId
	,strStockUOM = sUOM.strUnitMeasure
	,strStockUOMType = sUOM.strUnitType
	,dblStockUnitQty = StockUOM.dblUnitQty
	,intReceiveUOMId = COALESCE(ReceiveUOM.intItemUOMId, StockUOM.intItemUOMId)
	,intReceiveUnitMeasureId = COALESCE(ReceiveUOM.intUnitMeasureId, StockUOM.intUnitMeasureId)
	,dblReceiveUOMConvFactor = COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,intIssueUOMId = COALESCE(IssueUOM.intItemUOMId, StockUOM.intItemUOMId)
	,intIssueUnitMeasureId = COALESCE(IssueUOM.intUnitMeasureId, StockUOM.intUnitMeasureId)
	,dblIssueUOMConvFactor = COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,strReceiveUOMType = COALESCE(rUOM.strUnitType, sUOM.strUnitType)
	,strIssueUOMType = COALESCE(iUOM.strUnitType, sUOM.strUnitType)
	,strReceiveUOM = COALESCE(rUOM.strUnitMeasure, sUOM.strUnitMeasure)
	,strReceiveUPC = COALESCE(ReceiveUOM.strUpcCode, StockUOM.strUpcCode, '')
	,dblReceiveSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblReceiveMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblReceiveLastCost = ISNULL(ItemPricing.dblLastCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblReceiveStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblReceiveAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblReceiveEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,ysnReceiveUOMAllowPurchase = COALESCE(ReceiveUOM.ysnAllowPurchase, StockUOM.ysnAllowPurchase)
	,ysnReceiveUOMAllowSale = COALESCE(ReceiveUOM.ysnAllowSale, StockUOM.ysnAllowSale)
	,strIssueUOM = COALESCE(iUOM.strUnitMeasure, sUOM.strUnitMeasure)
	,strIssueUPC = COALESCE(IssueUOM.strUpcCode, StockUOM.strUpcCode, '')
	,dblIssueSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblIssueMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblIssueLastCost = ISNULL(ItemPricing.dblLastCost, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblIssueStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblIssueAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,dblIssueEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * COALESCE(IssueUOM.dblUnitQty, StockUOM.dblUnitQty, 0)
	,ysnIssueUOMAllowPurchase = COALESCE(IssueUOM.ysnAllowPurchase, StockUOM.ysnAllowPurchase)
	,ysnIssueUOMAllowSale = COALESCE(IssueUOM.ysnAllowSale, StockUOM.ysnAllowSale)
	,dblMinOrder = ISNULL(ItemLocation.dblMinOrder, 0)
	,dblReorderPoint = ISNULL(ItemLocation.dblReorderPoint, 0)
	,ItemLocation.intAllowNegativeInventory
	,strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END)
	,ItemLocation.intCostingMethod
	,strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END)
	,dblAmountPercent = ISNULL(ItemPricing.dblAmountPercent, 0)
	,dblSalePrice = ISNULL(ItemPricing.dblSalePrice, 0)
	,dblMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0)
	,ItemPricing.strPricingMethod
	,dblLastCost = ISNULL(ItemPricing.dblLastCost, 0)
	,dblStandardCost = ISNULL(ItemPricing.dblStandardCost, 0)
	,dblAverageCost = ISNULL(ItemPricing.dblAverageCost, 0)
	,dblEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0)

	,dblOnOrder = ISNULL(ItemStockUOM.dblOnOrder, 0)
	,dblInTransitInbound = ISNULL(ItemStockUOM.dblInTransitInbound, 0)
	,dblUnitOnHand = CAST(ISNULL(ItemStockUOM.dblOnHand, 0) AS NUMERIC(38, 7))
	,dblInTransitOutbound = ISNULL(ItemStockUOM.dblInTransitOutbound, 0)
	,dblBackOrder =	CASE	-- Compute the back order qty when committed > available Qty. 
							WHEN	ISNULL(ItemStockUOM.dblOrderCommitted, 0) > ((ISNULL(ItemStockUOM.dblOnHand, 0) - (ISNULL(ItemStockUOM.dblUnitReserved, 0) + ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + ISNULL(ItemStockUOM.dblConsignedSale, 0))) )
									AND ((ISNULL(ItemStockUOM.dblOnHand, 0) - (ISNULL(ItemStockUOM.dblUnitReserved, 0) + ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + ISNULL(ItemStockUOM.dblConsignedSale, 0))) ) > 0 THEN 
										ABS(
											ISNULL(ItemStockUOM.dblOrderCommitted, 0)
											- ((ISNULL(ItemStockUOM.dblOnHand, 0) - (ISNULL(ItemStockUOM.dblUnitReserved, 0) + ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + ISNULL(ItemStockUOM.dblConsignedSale, 0))) )										
										)
							ELSE 
								0
					END
	,dblOrderCommitted = ISNULL(ItemStockUOM.dblOrderCommitted, 0)
	,dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0)
	,dblConsignedPurchase = ISNULL(ItemStockUOM.dblConsignedPurchase, 0)
	,dblConsignedSale = ISNULL(ItemStockUOM.dblConsignedSale, 0)
	,dblUnitReserved = ISNULL(ItemStockUOM.dblUnitReserved, 0)
	,dblLastCountRetail = CAST(0 AS NUMERIC(38, 20)) --ISNULL(ItemStockUOM.dblLastCountRetail, 0), COMMENT THIS OUT SINCE I DON'T SEE USED ANYWHERE. 
	,dblAvailable = 
				ISNULL(ItemStockUOM.dblOnHand, 0)  
				- (
						ISNULL(ItemStockUOM.dblUnitReserved, 0) 
						+ ISNULL(ItemStockUOM.dblConsignedSale, 0)
				)
	
	,Item.dblDefaultFull
	,Item.ysnAvailableTM
	,Item.dblMaintenanceRate
	,Item.strMaintenanceCalculationMethod
	,Item.dblOverReceiveTolerance
	,Item.dblWeightTolerance
	,Item.intGradeId
	,strGrade = Grade.strDescription
	,Item.intLifeTime
	,Item.strLifeTimeType
	,Item.ysnListBundleSeparately
	,dblExtendedCost = ISNULL(ItemStockUOM.dblOnHand, 0) * ISNULL(ItemPricing.dblAverageCost, 0)
	,Item.strRequired
	,Item.intTonnageTaxUOMId
	,strTonnageTaxUOM = TonnageUOM.strUnitMeasure
	,Item.intModuleId
	,m.strModule
FROM	
	tblICItem Item 
	
	LEFT JOIN (
		tblICItemStockUOM ItemStockUOM INNER JOIN tblICItemUOM StockUOM
			ON ItemStockUOM.intItemUOMId = StockUOM.intItemUOMId
			AND StockUOM.ysnStockUnit = 1		
		INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	)
		ON ItemStockUOM.intItemId = Item.intItemId 	

	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	)
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intItemLocationId = ItemStockUOM.intItemLocationId

	LEFT JOIN (
		tblICItemUOM ReceiveUOM INNER JOIN tblICUnitMeasure rUOM 
			ON rUOM.intUnitMeasureId = ReceiveUOM.intUnitMeasureId
	)	
		ON ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId

	LEFT JOIN (
		tblICItemUOM IssueUOM INNER JOIN tblICUnitMeasure iUOM 
			ON iUOM.intUnitMeasureId = IssueUOM.intUnitMeasureId
	)
		ON IssueUOM.intItemUOMId = ItemLocation.intIssueUOMId

	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemLocation.intItemId = ItemPricing.intItemId 
		AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId	

	LEFT JOIN tblICStorageLocation StorageLocation 
		ON ItemStockUOM.intStorageLocationId = StorageLocation.intStorageLocationId

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON ItemStockUOM.intSubLocationId = SubLocation.intCompanyLocationSubLocationId

	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId

	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId

	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = Item.intGradeId

	LEFT JOIN tblAPVendor v
		ON v.intEntityVendorId = ItemLocation.intVendorId

	LEFT JOIN tblICUnitMeasure TonnageUOM 
		ON TonnageUOM.intUnitMeasureId = Item.intTonnageTaxUOMId

	LEFT JOIN tblSMModule m
		ON m.intModuleId = Item.intModuleId