CREATE PROCEDURE [dbo].[uspICGetItemAddOns]
	@intItemId AS INT,
	@intItemUOMId AS INT,
	@intLocationId AS INT,
	@dblQuantity AS NUMERIC(18,6) = 1
AS
BEGIN

	SELECT	ItemAddOn.intItemAddOnId,
			intAddOnItemId = ItemDetail.intItemId,
			strAddOnItemNo = ItemDetail.strItemNo,
			strAddOnItemDesc = ItemDetail.strDescription,
			strAddOnType = ItemDetail.strBundleType,
			intAddOnItemUOMId = ItemAddOnUOM.intItemUOMId,
			strAddOnUOM = ibUOM.strUnitMeasure,
			strAddOnUOMType = ibUOM.strUnitType,
			dblAddOnUOMConvFactor = ItemAddOnUOM.dblUnitQty,
			dblAddOnQty = ISNULL(@dblQuantity, 1) * ItemAddOnUOM.dblUnitQty,

			-- Component Details
			intComponentItemId = Component.intItemId,
			strComponentItemNo = Component.strItemNo,
			strComponentType = Component.strType,
			strComponentDescription = Component.strDescription,
			dblComponentQuantity = ItemAddOn.dblQuantity,
			dblAddOnComponentQty = ItemAddOn.dblQuantity * (ISNULL(@dblQuantity, 1) * ItemAddOnUOM.dblUnitQty),
			intComponentUOMId = ComponentUOM.intItemUOMId,
			dblComponentConvFactor = ComponentUOM.dblUnitQty,
			strComponentUOM = cUOM.strUnitMeasure,
			strComponentUOMType = cUOM.strUnitType,
			ysnComponentAutoAdd = ItemAddOn.ysnAutoAdd,

			-- Stock UOM of Components
			intComponentStockUOMId = StockUOM.intItemUOMId,
			strComponentStockUOM = sUOM.strUnitMeasure,
			strComponentStockUOMType = sUOM.strUnitType,

			-- Other Details of Components
			Component.strLotTracking,
			Component.strInventoryTracking,
			Component.strStatus,
			ItemLocation.intLocationId,
			ItemLocation.intItemLocationId,
			ItemLocation.intSubLocationId,
			Component.intCategoryId,
			Category.strCategoryCode,
			Component.intCommodityId,
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

			Component.dblDefaultFull,
			Component.ysnAvailableTM,
			Component.dblMaintenanceRate,
			Component.strMaintenanceCalculationMethod,
			Component.dblOverReceiveTolerance,
			Component.dblWeightTolerance,
			Component.intGradeId,
			strGrade = Grade.strDescription,
			Component.intLifeTime,
			Component.strLifeTimeType,
			Component.strRequired,
			Component.intTonnageTaxUOMId,
			Component.intModuleId,
			Component.ysnUseWeighScales,
			Component.ysnLotWeightsRequired
			
	FROM tblICItemAddOn ItemAddOn
		INNER JOIN tblICItem ItemDetail ON ItemAddOn.intItemId = ItemDetail.intItemId
		INNER JOIN tblICItem Component ON Component.intItemId = ItemAddOn.intAddOnItemId
	
		LEFT JOIN (
			tblICItemUOM ItemAddOnUOM INNER JOIN tblICUnitMeasure ibUOM
				ON ibUOM.intUnitMeasureId = ItemAddOnUOM.intUnitMeasureId
		) ON ItemAddOnUOM.intItemId = ItemAddOn.intItemId
	
		LEFT JOIN (
			tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
				ON l.intCompanyLocationId = ItemLocation.intLocationId
		) ON ItemLocation.intItemId = Component.intItemId
			AND ItemLocation.intLocationId IS NOT NULL
	
		LEFT JOIN vyuICGetItemPricing ItemPricing
			ON ItemPricing.intItemId = Component.intItemId
			AND ItemPricing.intLocationId = l.intCompanyLocationId
			AND ItemPricing.intItemUOMId = ItemAddOn.intItemUOMId

		LEFT JOIN (
			tblICItemUOM ComponentUOM INNER JOIN tblICUnitMeasure cUOM
				ON ComponentUOM.intUnitMeasureId = cUOM.intUnitMeasureId
		) ON ComponentUOM.intItemUOMId = ItemAddOn.intItemUOMId

		LEFT JOIN (
			tblICItemUOM StockUOM INNER JOIN tblICUnitMeasure sUOM
				ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
		) ON StockUOM.intItemId = Component.intItemId 
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
			ON Category.intCategoryId = Component.intCategoryId
		LEFT JOIN tblICCommodity Commodity 
			ON Commodity.intCommodityId = Component.intCommodityId
		LEFT JOIN tblICCommodityAttribute Grade 
			ON Grade.intCommodityAttributeId = Component.intGradeId
	WHERE 
		ItemAddOn.intItemId = @intItemId 
		AND ItemAddOnUOM.intItemUOMId = @intItemUOMId
		AND l.intCompanyLocationId = @intLocationId
		AND Component.strType IN ('Inventory', 'Finished Good', 'Raw Material')

END