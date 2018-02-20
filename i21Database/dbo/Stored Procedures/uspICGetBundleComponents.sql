CREATE PROCEDURE [dbo].[uspICGetBundleComponents]
	@intItemId AS INT,
	@intItemUOMId AS INT,
	@intLocationId AS INT,
	@dblQuantity AS NUMERIC(18,6) = 1
AS

BEGIN

SELECT	ItemBundle.intItemBundleId,
		intBundleItemId = ItemDetail.intItemId,
		strBundleItemNo = ItemDetail.strItemNo,
		strBundleItemDesc = ItemDetail.strDescription,
		strBundleType = ItemDetail.strBundleType,
		intBundleItemUOMId = ItemBundleUOM.intItemUOMId,
		strBundleUOM = ibUOM.strUnitMeasure,
		strBundleUOMType = ibUOM.strUnitType,
		dblBundleUOMConvFactor = ItemBundleUOM.dblUnitQty,
		dblBundleQty = ISNULL(@dblQuantity, 1) * ItemBundleUOM.dblUnitQty,

		ItemBundle.dblMarkUpOrDown,
		ItemBundle.dtmBeginDate,
		ItemBundle.dtmEndDate,

		-- Component Details
		intComponentItemId = BundleComponent.intItemId,
		strComponentItemNo = BundleComponent.strItemNo,
		strComponentType = BundleComponent.strType,
		strComponentDescription = BundleComponent.strDescription,
		dblComponentQuantity = ItemBundle.dblQuantity,
		dblBundleComponentQty = ItemBundle.dblQuantity * (ISNULL(@dblQuantity, 1) * ItemBundleUOM.dblUnitQty),
		intComponentUOMId = ComponentUOM.intItemUOMId,
		dblComponentConvFactor = ComponentUOM.dblUnitQty,
		strComponentUOM = cUOM.strUnitMeasure,
		strComponentUOMType = cUOM.strUnitType,

		-- Stock UOM of Components
		intComponentStockUOMId = StockUOM.intItemUOMId,
		strComponentStockUOM = sUOM.strUnitMeasure,
		strComponentStockUOMType = sUOM.strUnitType,

		-- Other Details of Components
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
	INNER JOIN tblICItem ItemDetail ON ItemBundle.intItemId = ItemDetail.intItemId
	INNER JOIN tblICItem BundleComponent ON BundleComponent.intItemId = ItemBundle.intBundleItemId
	
	LEFT JOIN (
		tblICItemUOM ItemBundleUOM INNER JOIN tblICUnitMeasure ibUOM
			ON ibUOM.intUnitMeasureId = ItemBundleUOM.intUnitMeasureId
	) ON ItemBundleUOM.intItemId = ItemBundle.intItemId
	
	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	) ON ItemLocation.intItemId = BundleComponent.intItemId
		AND ItemLocation.intLocationId IS NOT NULL
	
	LEFT JOIN vyuICGetItemPricing ItemPricing
		ON ItemPricing.intItemId = BundleComponent.intItemId
		AND ItemPricing.intLocationId = l.intCompanyLocationId
		AND ItemPricing.intItemUOMId = ItemBundle.intItemUnitMeasureId

	LEFT JOIN (
		tblICItemUOM ComponentUOM INNER JOIN tblICUnitMeasure cUOM
			ON ComponentUOM.intUnitMeasureId = cUOM.intUnitMeasureId
	) ON ComponentUOM.intItemUOMId = CASE WHEN ItemDetail.strBundleType = 'Option' 
			THEN [dbo].[fnGetMatchingItemUOMId](BundleComponent.intItemId, ItemBundleUOM.intItemUOMId) 
			ELSE ItemBundle.intItemUnitMeasureId END

	LEFT JOIN (
		tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
			ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
	) ON StockUOM.intItemId = BundleComponent.intItemId 
		AND StockUOM.ysnStockUnit = 1

	LEFT JOIN (
		tblICItemUOM GrossUOM INNER JOIN tblICUnitMeasure gUOM 
		ON gUOM.intUnitMeasureId = GrossUOM.intUnitMeasureId
	) ON GrossUOM.intItemUOMId = ItemLocation.intGrossUOMId
	

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
	WHERE ItemBundle.intItemId = @intItemId 
		AND ItemBundleUOM.intItemUOMId = @intItemUOMId
		AND l.intCompanyLocationId = @intLocationId
END