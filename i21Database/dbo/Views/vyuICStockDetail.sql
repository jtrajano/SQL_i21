CREATE VIEW [dbo].[vyuICStockDetail]
AS 

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemStockUOM.intItemStockUOMId) AS INT)
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
	,intStockUOMId = StockUOM.intItemUOMId
	,strStockUOM = sUOM.strUnitMeasure
	,strStockUOMType = sUOM.strUnitType
	,dblStockUnitQty = StockUOM.dblUnitQty
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
	,dblAvailable = 
				ISNULL(ItemStockUOM.dblOnHand, 0)  
				- (
						ISNULL(ItemStockUOM.dblUnitReserved, 0) 
						+ ISNULL(ItemStockUOM.dblConsignedSale, 0)
				)
	
	,dblExtendedCost = ISNULL(ItemStockUOM.dblOnHand, 0) * ISNULL(ItemPricing.dblAverageCost, 0)
FROM	
	tblICItem Item 
	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	)
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId IS NOT NULL 

	LEFT JOIN (
		tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	)
		ON StockUOM.intItemId = Item.intItemId 
		AND StockUOM.ysnStockUnit = 1

	LEFT JOIN tblICItemStockUOM ItemStockUOM 
		ON ItemStockUOM.intItemId = Item.intItemId 
		AND ItemStockUOM.intItemUOMId = StockUOM.intItemUOMId
		AND ItemLocation.intItemLocationId = ItemStockUOM.intItemLocationId

	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemPricing.intItemId = Item.intItemId 
		AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId

	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = ItemStockUOM.intStorageLocationId 

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON ItemStockUOM.intSubLocationId = SubLocation.intCompanyLocationSubLocationId

	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId

	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId

	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = Item.intGradeId
