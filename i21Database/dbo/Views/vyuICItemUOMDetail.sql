CREATE VIEW [dbo].[vyuICItemUOMDetail]
AS
SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY stockUOM.intItemStockUOMId) AS INT)
	, item.intItemId
	, item.strItemNo
	, item.strType
	, item.strDescription
	, item.strLotTracking
	, item.strInventoryTracking
	, item.strStatus
	, intLocationId = companyLocation.intCompanyLocationId
	, stockUOM.intItemLocationId
	, stockUOM.intSubLocationId
	, item.intCategoryId
	, category.strCategoryCode
	, item.intCommodityId
	, commodity.strCommodityCode
	, strStorageLocationName = storageLocation.strName 
	, strSubLocationName = subLocation.strSubLocationName 
	, stockUOM.intStorageLocationId
	, strLocationName = companyLocation.strLocationName 
	, strLocationType = companyLocation.strLocationType 
	, intStockUOMId = stockUOM.intItemUOMId
	, strStockUOM = unitmeasure.strUnitMeasure
	, strStockUOMType = unitmeasure.strUnitType
	, itemUOM.strUpcCode
	, itemUOM.strLongUPCCode
	, dblStockUnitQty = itemUOM.dblUnitQty
	, itemLocation.intAllowNegativeInventory
	, strAllowNegativeInventory = (
			CASE 
				WHEN itemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
				WHEN itemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
				WHEN itemLocation.intAllowNegativeInventory = 3 THEN 'No' 
			END
		) COLLATE Latin1_General_CI_AS
	, itemLocation.intCostingMethod
	, strCostingMethod = (
			CASE 
				WHEN itemLocation.intCostingMethod = 1 THEN 'AVG'
				WHEN itemLocation.intCostingMethod = 2 THEN 'FIFO'
				WHEN itemLocation.intCostingMethod = 3 THEN 'LIFO' 
			END
		) COLLATE Latin1_General_CI_AS
	, dblAmountPercent = ISNULL((itemPricing.dblAmountPercent), 0.00)
	, dblSalePrice = ISNULL((itemPricing.dblSalePrice), 0.00)
	, dblMSRPPrice = ISNULL((itemPricing.dblMSRPPrice), 0.00)
	, itemPricing.strPricingMethod
	, dblLastCost = ISNULL((itemPricing.dblLastCost), 0.00)
	, dblStandardCost = ISNULL((itemPricing.dblStandardCost), 0.00)
	, dblAverageCost = ISNULL((itemPricing.dblAverageCost), 0.00)
	, dblEndMonthCost = ISNULL((itemPricing.dblEndMonthCost), 0.00)

	, dblOnOrder = COALESCE(stockInStockUOM.dblOnOrder, stockUOM.dblOnOrder, 0)
	, dblInTransitInbound = COALESCE(stockInStockUOM.dblInTransitInbound, stockUOM.dblInTransitInbound, 0)
	, dblUnitOnHand = COALESCE(stockInStockUOM.dblUnitOnHand, stockUOM.dblOnHand, 0)
	, dblInTransitOutbound = COALESCE(stockInStockUOM.dblInTransitOutbound, stockUOM.dblInTransitOutbound, 0)
	, dblBackOrder = 0 --COALESCE(stockInStockUOM.dblOnUnitOnHand, stockUOM.dblOnHand, 0)
	, dblOrderCommitted = COALESCE(stockInStockUOM.dblOrderCommitted, stockUOM.dblOrderCommitted, 0)
	, dblUnitStorage = COALESCE(stockInStockUOM.dblUnitStorage, stockUOM.dblUnitStorage, 0)
	, dblConsignedPurchase = COALESCE(stockInStockUOM.dblConsignedPurchase, stockUOM.dblConsignedPurchase, 0)
	, dblConsignedSale = COALESCE(stockInStockUOM.dblConsignedSale, stockUOM.dblConsignedSale, 0)
	, dblUnitReserved = COALESCE(stockInStockUOM.dblUnitReserved, stockUOM.dblUnitReserved, 0)
	, dblAvailable = 
		COALESCE(stockInStockUOM.dblUnitOnHand, stockUOM.dblOnHand, 0)
		- COALESCE(stockInStockUOM.dblUnitReserved, stockUOM.dblUnitReserved, 0)
		- COALESCE(stockInStockUOM.dblConsignedSale, stockUOM.dblConsignedSale, 0)
		+ COALESCE(stockInStockUOM.dblUnitStorage, stockUOM.dblUnitStorage, 0)
	, dblExtended = 
		(
			COALESCE(stockInStockUOM.dblUnitOnHand, stockUOM.dblOnHand, 0)
			+ COALESCE(stockInStockUOM.dblUnitStorage, stockUOM.dblUnitStorage, 0)
			+ COALESCE(stockInStockUOM.dblConsignedPurchase, stockUOM.dblConsignedPurchase, 0)
		) 
		* dbo.fnCalculateCostBetweenUOM(
			intItemStockUOM.intItemUOMId
			,itemUOM.intItemUOMId
			,ISNULL(itemPricing.dblAverageCost, 0)
		)
		
		
	, dblMinOrder = ISNULL(itemLocation.dblMinOrder, 0)
	, dblReorderPoint = ISNULL(itemLocation.dblReorderPoint, 0)
	, dblNearingReorderBy = 
		CAST(
			COALESCE(stockInStockUOM.dblUnitOnHand, stockUOM.dblOnHand, 0)
			- ISNULL(itemLocation.dblReorderPoint, 0) 
			AS NUMERIC(38, 7)
		)
	, itemUOM.ysnStockUnit
	, dblInTransitDirect = COALESCE(stockInStockUOM.dblInTransitDirect, stockUOM.dblInTransitDirect, 0)
FROM
	tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitmeasure
		ON itemUOM.intUnitMeasureId = unitmeasure.intUnitMeasureId
	INNER JOIN tblICItem item
		ON itemUOM.intItemId = item.intItemId

	INNER JOIN tblICItemUOM intItemStockUOM 
		ON intItemStockUOM.intItemId = item.intItemId
		AND intItemStockUOM.ysnStockUnit = 1

	INNER JOIN (
		tblICItemLocation itemLocation INNER JOIN tblSMCompanyLocation companyLocation
			ON companyLocation.intCompanyLocationId = itemLocation.intLocationId
	)
		ON itemLocation.intItemId = item.intItemId
	INNER JOIN tblICItemPricing itemPricing
		ON itemPricing.intItemId = item.intItemId
		AND itemPricing.intItemLocationId = itemLocation.intItemLocationId	

	OUTER APPLY (
		SELECT 
			stockUOM.intItemStockUOMId
			,stockUOM.intItemId
			,stockUOM.intItemLocationId
			,stockUOM.intItemUOMId
			,stockUOM.intStorageLocationId
			,stockUOM.intSubLocationId
			,dblOnHand = SUM(stockUOM.dblOnHand) 
			,dblInTransitInbound = SUM(stockUOM.dblInTransitInbound) 
			,dblInTransitOutbound = SUM(stockUOM.dblInTransitOutbound) 
			,dblInTransitDirect = SUM(stockUOM.dblInTransitDirect) 
			,dblConsignedPurchase = SUM(stockUOM.dblConsignedPurchase) 
			,dblConsignedSale = SUM(stockUOM.dblConsignedSale) 
			,dblOrderCommitted = SUM(stockUOM.dblOrderCommitted) 
			,dblUnitReserved = SUM(stockUOM.dblUnitReserved) 
			,dblOnOrder = SUM(stockUOM.dblOnOrder) 
			,dblUnitStorage = SUM(stockUOM.dblUnitStorage) 
		FROM 
			tblICItemStockUOM stockUOM
		WHERE
			stockUOM.intItemId = item.intItemId
			AND stockUOM.intItemUOMId = itemUOM.intItemUOMId
			AND stockUOM.intItemLocationId = itemLocation.intItemLocationId	
			AND (ISNULL(item.ysnSeparateStockForUOMs, 0) = 1 OR item.strLotTracking LIKE 'Yes%') 
		GROUP BY 
			stockUOM.intItemStockUOMId
			,stockUOM.intItemId
			,stockUOM.intItemLocationId
			,stockUOM.intItemUOMId
			,stockUOM.intStorageLocationId
			,stockUOM.intSubLocationId
	) stockUOM

	OUTER APPLY (
		SELECT 
			dblUnitOnHand = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblUnitOnHand)
			,dblInTransitInbound = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblInTransitInbound) 
			,dblInTransitOutbound = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblInTransitOutbound) 
			,dblInTransitDirect = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblInTransitDirect) 
			,dblConsignedPurchase = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblConsignedPurchase) 
			,dblConsignedSale = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblConsignedSale) 
			,dblOrderCommitted = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblOrderCommitted) 
			,dblUnitReserved = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblUnitReserved) 
			,dblOnOrder = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblOnOrder) 
			,dblUnitStorage = dbo.fnCalculateQtyBetweenUOM(su.intItemUOMId, itemUOM.intItemUOMId, s.dblUnitStorage) 
		FROM
			tblICItemStock s 
			INNER JOIN tblICItemUOM su
				ON su.intItemId = s.intItemId
				AND su.ysnStockUnit = 1
		WHERE 
			s.intItemId = item.intItemId			
			AND s.intItemLocationId = itemLocation.intItemLocationId
			AND ISNULL(item.ysnSeparateStockForUOMs, 0) = 0			

	) stockInStockUOM

	LEFT JOIN tblICCategory category
		ON category.intCategoryId = item.intCategoryId
	LEFT JOIN tblICCommodity commodity 
		ON commodity.intCommodityId = item.intCommodityId	
	LEFT JOIN tblICStorageLocation storageLocation 
		ON storageLocation.intStorageLocationId = stockUOM.intStorageLocationId	
	LEFT JOIN tblSMCompanyLocationSubLocation subLocation 
		ON subLocation.intCompanyLocationSubLocationId = stockUOM.intSubLocationId
