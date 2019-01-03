CREATE VIEW [dbo].[vyuICItemUOMDetail]
AS
	SELECT
		intKey = CAST(ROW_NUMBER() OVER(ORDER BY x.intItemUOMId, x.intItemId, x.intItemLocationId, x.intSubLocationId, x.intStorageLocationId) AS INT)
	, x.intItemId
	, Item.strItemNo
	, Item.strType
	, Item.strDescription
	, Item.strLotTracking
	, Item.strInventoryTracking
	, Item.strStatus
	, intLocationId = CompanyLocation.intCompanyLocationId
	, x.intItemLocationId
	, x.intSubLocationId
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.intCommodityId
	, Commodity.strCommodityCode
	, StorageLocation.strName AS strStorageLocationName
	, SubLocation.strSubLocationName AS strSubLocationName
	, x.intStorageLocationId
	, CompanyLocation.strLocationName strLocationName
	, CompanyLocation.strLocationType strLocationType
	, intStockUOMId = x.intItemUOMId
	, strStockUOM = x.strUnitMeasure
	, strStockUOMType = x.strUnitType
	, x.strUpcCode
	, x.strLongUPCCode
	, dblStockUnitQty = x.dblUnitQty
	, ItemLocation.intAllowNegativeInventory
	, strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END)
	, ItemLocation.intCostingMethod
	, strCostingMethod = (CASE WHEN ItemLocation.intCostingMethod = 1 THEN 'AVG'
							 WHEN ItemLocation.intCostingMethod = 2 THEN 'FIFO'
							 WHEN ItemLocation.intCostingMethod = 3 THEN 'LIFO' END)
	, dblAmountPercent = ISNULL((ItemPricing.dblAmountPercent), 0.00)
	, dblSalePrice = ISNULL((ItemPricing.dblSalePrice), 0.00)
	, dblMSRPPrice = ISNULL((ItemPricing.dblMSRPPrice), 0.00)
	, ItemPricing.strPricingMethod
	, dblLastCost = ISNULL((ItemPricing.dblLastCost), 0.00)
	, dblStandardCost = ISNULL((ItemPricing.dblStandardCost), 0.00)
	, dblAverageCost = ISNULL((ItemPricing.dblAverageCost), 0.00)
	, dblEndMonthCost = ISNULL((ItemPricing.dblEndMonthCost), 0.00)

	, dblOnOrder = SUM(x.dblOnOrder) 
	, dblInTransitInbound = SUM(x.dblInTransitInbound)
	, dblUnitOnHand = SUM(x.dblOnHand)
	, dblInTransitOutbound = SUM(x.dblInTransitOutbound)
	, dblBackOrder =	SUM(x.dblOnHand)
	, dblOrderCommitted = SUM(x.dblOrderCommitted)
	, dblUnitStorage = SUM(x.dblUnitStorage)
	, dblConsignedPurchase = SUM(x.dblConsignedPurchase)
	, dblConsignedSale = SUM(x.dblConsignedSale)
	, dblUnitReserved = SUM(x.dblUnitReserved)
	, dblAvailable = SUM(x.dblOnHand) - (SUM(x.dblUnitReserved) + SUM(x.dblConsignedSale))
	, dblExtended = (SUM(x.dblOnHand) + SUM(x.dblUnitStorage) + SUM(x.dblConsignedPurchase)) * (ItemPricing.dblAverageCost)
	, dblMinOrder = (ItemLocation.dblMinOrder)
	, dblReorderPoint = (ItemLocation.dblReorderPoint)
	, dblNearingReorderBy = CAST(SUM(x.dblOnHand) - (ItemLocation.dblReorderPoint) AS NUMERIC(38, 7))
	, x.ysnStockUnit
	FROM (
		SELECT
			ISNULL(StockUOM.intSubLocationId,  CASE WHEN StockUnit.intItemUOMId = ItemUOM.intItemUOMId THEN StockUnit.intSubLocationId ELSE NULL END) intSubLocationId,
			ISNULL(StockUOM.intStorageLocationId, CASE WHEN StockUnit.intItemUOMId = ItemUOM.intItemUOMId THEN StockUnit.intStorageLocationId ELSE NULL END) intStorageLocationId,
			UnitMeasure.strUnitMeasure,
			UnitMeasure.strUnitType,
			ItemUOM.strUpcCode,
			ItemUOM.dblUnitQty,
			ItemUOM.strLongUPCCode,
			ItemUOM.ysnStockUnit,
			ItemUOM.intItemId,
			ItemUOM.intItemUOMId,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblOnOrder - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblOnOrder)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblOnOrder
			END AS dblOnOrder, 
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblConsignedPurchase - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblConsignedPurchase)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblConsignedPurchase
			END AS dblConsignedPurchase,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblConsignedSale - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblConsignedSale)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblConsignedSale
			END AS dblConsignedSale,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblInTransitInbound - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblInTransitInbound)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblInTransitInbound
			END AS dblInTransitInbound,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblInTransitOutbound - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblInTransitOutbound)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblInTransitOutbound
			END AS dblInTransitOutbound,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblOrderCommitted - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblOrderCommitted)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblOrderCommitted
			END AS dblOrderCommitted,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblUnitReserved - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblUnitReserved)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblUnitReserved
			END AS dblUnitReserved,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblUnitStorage - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblUnitStorage)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblUnitStorage
			END AS dblUnitStorage,
			CASE WHEN ItemUOM.ysnStockUnit = 1 
            THEN ROUND(StockUnit.dblOnHand - ISNULL(SUM(dbo.fnCalculateQtyBetweenUOM(StockUOM.intItemUOMId, 
                        StockUnit.intItemUOMId, StockUOM.dblOnHand)) OVER (PARTITION BY StockUnit.intItemLocationId), 0), 2)
            ELSE StockUOM.dblOnHand 
		END AS dblOnHand,
			ItemLocation.intItemLocationId
		FROM tblICItemUOM ItemUOM
			INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = ItemUOM.intItemId
			INNER JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT OUTER JOIN tblICItemStockUOM StockUOM ON StockUOM.intItemId = ItemUOM.intItemId
				AND StockUOM.intItemUOMId = ItemUOM.intItemUOMId
				AND StockUOM.intItemLocationId = ItemLocation.intItemLocationId
				AND ItemUOM.ysnStockUnit <> 1
			LEFT JOIN (
				SELECT
					ItemUOM.intItemId,
					ItemLocation.intItemLocationId,
					ItemUOM.intItemUOMId,
					SUM(StockUOM.dblOnHand) dblOnHand,
					SUM(StockUOM.dblInTransitInbound) dblInTransitInbound,
					SUM(StockUOM.dblInTransitOutbound) dblInTransitOutbound,
					SUM(StockUOM.dblConsignedPurchase) dblConsignedPurchase,
					SUM(StockUOM.dblConsignedSale) dblConsignedSale,
					SUM(StockUOM.dblOrderCommitted) dblOrderCommitted,
					SUM(StockUOM.dblUnitReserved) dblUnitReserved,
					SUM(StockUOM.dblOnOrder) dblOnOrder,
					SUM(StockUOM.dblUnitStorage) dblUnitStorage,
					StockUOM.intStorageLocationId,
					StockUOM.intSubLocationId
				FROM tblICItemUOM ItemUOM
					INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = ItemUOM.intItemId
					INNER JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
					INNER JOIN tblICItemStockUOM StockUOM ON StockUOM.intItemUOMId = ItemUOM.intItemUOMId
						AND StockUOM.intItemId = ItemUOM.intItemId
						AND StockUOM.intItemLocationId = ItemLocation.intItemLocationId
				WHERE ItemUOM.ysnStockUnit = 1
				GROUP BY ItemUOM.intItemId, ItemLocation.intItemLocationId, ItemUOM.intItemUOMId, StockUOM.intStorageLocationId, StockUOM.intSubLocationId
			) StockUnit ON StockUnit.intItemId = ItemUOM.intItemId
				AND StockUnit.intItemLocationId = ItemLocation.intItemLocationId
	) x
		INNER JOIN tblICItem Item ON Item.intItemId = x.intItemId
		INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = x.intItemLocationId
		LEFT OUTER JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
		LEFT OUTER JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
		LEFT OUTER JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = x.intStorageLocationId
		LEFT OUTER JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = x.intSubLocationId
		INNER JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
		INNER JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Item.intItemId
			AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	GROUP BY x.strUnitMeasure, x.strUnitType, x.ysnStockUnit, x.intItemUOMId, x.intItemId, x.intItemLocationId, x.strLongUPCCode, x.strUpcCode, x.intStorageLocationId, x.intSubLocationId, x.dblUnitQty,
	Item.strItemNo, Item.strType, Item.strDescription, Item.strLotTracking, Item.strInventoryTracking, Item.strStatus, CompanyLocation.intCompanyLocationId, Item.intCategoryId,
	Category.strCategoryCode, Item.intCommodityId, Commodity.strCommodityCode, StorageLocation.strName, SubLocation.strSubLocationName, CompanyLocation.strLocationName, CompanyLocation.strLocationType,
	ItemLocation.intAllowNegativeInventory, ItemLocation.intCostingMethod, ItemPricing.strPricingMethod, ItemPricing.dblAmountPercent, ItemPricing.dblSalePrice, ItemPricing.dblMSRPPrice,
	ItemPricing.dblLastCost, ItemPricing.dblAverageCost, ItemPricing.dblStandardCost, ItemPricing.dblEndMonthCost, ItemLocation.dblMinOrder, ItemLocation.dblReorderPoint