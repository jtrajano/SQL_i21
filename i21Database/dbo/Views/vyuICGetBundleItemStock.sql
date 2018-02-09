CREATE VIEW [dbo].[vyuICGetBundleItemStock]
	AS
SELECT	intKey = CAST(ROW_NUMBER() OVER(ORDER BY BundleComponent.intItemId, ItemLocation.intLocationId) AS INT),
		intBundleItemId = ItemBundle.intItemId,
		strBundleItemNo = ItemBundleDetail.strItemNo,
		strBundleItemDesc = ItemBundleDetail.strDescription,
		strBundleType = ItemBundleDetail.strBundleType,
		
		intComponentItemId = BundleComponent.intItemId,
		strComponentItemNo = BundleComponent.strItemNo,
		strComponentType = BundleComponent.strType,
		strComponentDescription = BundleComponent.strDescription,
		dblComponentQuantity = ItemBundle.dblQuantity,
		intComponentUOMId = BundleComponentUOM.intItemUOMId,
		strComponentUOM = bcUOM.strUnitMeasure,
		strComponentUOMType = bcUOM.strUnitType,
		dblComponentConvFactor = BundleComponentUOM.dblUnitQty,
		ItemBundle.dblMarkUpOrDown,
		ItemBundle.dtmBeginDate,
		ItemBundle.dtmEndDate,
		

		BundleComponent.strLotTracking,
		BundleComponent.strInventoryTracking,
		BundleComponent.strStatus,
		ItemLocation.intLocationId,
		ItemLocation.intItemLocationId,
		ItemLocation.intSubLocationId,
		BundleComponent.intCategoryId,
		Category.strCategoryCode,
		BundleComponent.intCommodityId,
		Commodity.strCommodityCode,
		strStorageLocationName = StorageLocation.strName,
		strSubLocationName = SubLocation.strSubLocationName,
		ItemLocation.intStorageLocationId,
		l.strLocationName,
		l.strLocationType,
		intStockUOMId = StockUOM.intItemUOMId,
		strStockUOM = sUOM.strUnitMeasure,
		strStockUOMType = sUOM.strUnitType,
		dblStockUnitQty = StockUOM.dblUnitQty,
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

		intGrossUOMId = GrossUOM.intItemUOMId,
		dblGrossUOMConvFactor = GrossUOM.dblUnitQty,
		strGrossUOMType = gUOM.strUnitType,
		strGrossUOM = gUOM.strUnitMeasure,
		strGrossUPC = GrossUOM.strUpcCode,
		strGrossLongUPC = GrossUOM.strLongUPCCode,

		BundleComponent.dblDefaultFull,
		BundleComponent.ysnAvailableTM,
		BundleComponent.dblMaintenanceRate,
		BundleComponent.strMaintenanceCalculationMethod,
		BundleComponent.dblOverReceiveTolerance,
		BundleComponent.dblWeightTolerance,
		BundleComponent.intGradeId,
		strGrade = Grade.strDescription,
		BundleComponent.intLifeTime,
		BundleComponent.strLifeTimeType,
		BundleComponent.ysnListBundleSeparately,
		BundleComponent.strRequired,
		BundleComponent.intTonnageTaxUOMId,
		BundleComponent.intModuleId,
		BundleComponent.ysnUseWeighScales,
		BundleComponent.ysnLotWeightsRequired	
FROM tblICItemBundle ItemBundle
	INNER JOIN tblICItem ItemBundleDetail ON ItemBundle.intItemId = ItemBundleDetail.intItemId
	INNER JOIN tblICItem BundleComponent ON BundleComponent.intItemId = ItemBundle.intBundleItemId
	LEFT JOIN (
			tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
				ON l.intCompanyLocationId = ItemLocation.intLocationId
		)
		ON ItemLocation.intItemId = BundleComponent.intItemId
		AND ItemLocation.intLocationId IS NOT NULL
	LEFT JOIN (
			tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
				ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
		)
		ON StockUOM.intItemId = BundleComponent.intItemId 
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN (
		tblICItemUOM GrossUOM INNER JOIN tblICUnitMeasure gUOM 
		ON gUOM.intUnitMeasureId = GrossUOM.intUnitMeasureId
	)
		ON GrossUOM.intItemUOMId = ItemLocation.intGrossUOMId
	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemLocation.intItemId = ItemPricing.intItemId 
		AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = BundleComponent.intCategoryId
	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = BundleComponent.intCommodityId
	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = BundleComponent.intGradeId
	LEFT JOIN ( 
		tblICItemUOM BundleComponentUOM INNER JOIN tblICUnitMeasure bcUOM
		ON bcUOM.intUnitMeasureId = BundleComponentUOM.intUnitMeasureId
	) 
		ON BundleComponentUOM.intItemUOMId = ItemBundle.intItemUnitMeasureId