CREATE PROCEDURE [dbo].[uspICGetBundleComponent2]
	@intItemId AS INT	
	,@intLocationId AS INT
	,@intItemUOMId AS INT
	,@dblQuantity AS NUMERIC(18,6) = 1
	,@intCostUOMId AS INT = NULL 
	,@intGrossNetUOMId AS INT = NULL 
	,@dblCost AS NUMERIC(18, 6) = NULL 
	,@dblGross AS NUMERIC(38, 20) = NULL 
	,@dblNet AS NUMERIC(38, 20) = NULL 
AS

BEGIN

SELECT	Bundle.intItemBundleId
		,intBundleItemId = BundleItem.intItemId
		,strBundleItemNo = BundleItem.strItemNo
		,strBundleItemDesc = BundleItem.strDescription
		,strBundleType = BundleItem.strBundleType
		,intBundleItemUOMId = BundleUOM.intItemUOMId
		,strBundleUOM = BundleUnitMeasure.strUnitMeasure
		,strBundleUOMType = BundleUnitMeasure.strUnitType
		,dblBundleUOMConvFactor = BundleUOM.dblUnitQty		
		,Bundle.dblMarkUpOrDown
		,Bundle.dtmBeginDate
		,Bundle.dtmEndDate

		-- Component Details
		,intComponentItemId = BundleComponent.intItemId
		,strComponentItemNo = BundleComponent.strItemNo
		,strComponentType = BundleComponent.strType
		,strComponentDescription = BundleComponent.strDescription
		,dblComponentQuantity = Bundle.dblQuantity
		,dblBundleComponentQty = 
				CASE 
					WHEN BundleItem.strBundleType = 'Option' AND ComponentUOM.intItemUOMId IS NOT NULL THEN ISNULL(@dblQuantity, 1) 
					ELSE 
						dbo.fnCalculateQtyBetweenUOM (
							Bundle.intItemUnitMeasureId
							,ComponentUOM.intItemUOMId
							,Bundle.dblQuantity * (
								dbo.fnCalculateQtyBetweenUOM (
									@intItemUOMId
									,BundleStockUOM.intItemUOMId
									,ISNULL(@dblQuantity, 1)				
								)
							)				
						)
					END
		,intComponentUOMId = ComponentUOM.intItemUOMId
		,dblComponentConvFactor = ComponentUOM.dblUnitQty
		,strComponentUOM = ComponentUnitMeasure.strUnitMeasure
		,strComponentUOMType = ComponentUnitMeasure.strUnitType

		,intComponentCostUOMId = COALESCE(ComponentCostUOM.intItemUOMId, ComponentDefaultCostUOM.intItemUOMId) 
		,dblComponentCostConvFactor = COALESCE(ComponentCostUOM.dblUnitQty, ComponentDefaultCostUOM.dblUnitQty) 
		,strComponentCostUOM = COALESCE(ComponentCostUnitMeasure.strUnitMeasure, ComponentCostUnitMeasure.strUnitMeasure) 
		,strComponentCostUOMType = COALESCE(ComponentCostUnitMeasure.strUnitType, ComponentCostUnitMeasure.strUnitType) 
		,dblBundleComponentCost = 
				CASE 
					WHEN ComponentCostUOM.intItemUOMId IS NOT NULL THEN @dblCost 
					WHEN ComponentDefaultCostUOM.intItemUOMId IS NOT NULL THEN 
						dbo.fnCalculateCostBetweenUOM (
							@intCostUOMId
							,BundleStockUOM.intItemUOMId
							,@dblCost
						)					
				END 		
		,intComponentGrossNetUOMId = ComponentGrossNetUOM.intItemUOMId
		,dblComponentGrossNetConvFactor = ComponentGrossNetUOM.dblUnitQty
		,strComponentGrossNetUOM = ComponentGrossNetUnitMeasure.strUnitMeasure
		,strComponentGrossNetUOMType = ComponentGrossNetUnitMeasure.strUnitType
		,dblBundleComponentGross = 
				CASE 
					WHEN ComponentGrossNetUOM.intItemUOMId IS NOT NULL THEN @dblGross
				END
		,dblBundleComponentNet = 
				CASE 
					WHEN ComponentGrossNetUOM.intItemUOMId IS NOT NULL THEN @dblNet
				END

		-- Other Details of Components
		,BundleComponent.strLotTracking
		,BundleComponent.strInventoryTracking
		,BundleComponent.strStatus
		,ComponentItemLocation.intLocationId
		,ComponentItemLocation.intItemLocationId
		,ComponentItemLocation.intSubLocationId
		,BundleComponent.intCategoryId
		,ComponentCategory.strCategoryCode
		,BundleComponent.intCommodityId
		,ComponentCommodity.strCommodityCode
		,strStorageLocationName = ComponentStorageLocation.strName
		,strSubLocationName = ComponentSubLocation.strSubLocationName
		,ComponentItemLocation.intStorageLocationId
		,ComponentLocation.strLocationName
		,ComponentLocation.strLocationType
		,intStockUOMId = BundleStockUOM.intItemUOMId
		,strStockUOM = BundleStockUnitMeasure.strUnitMeasure
		,strStockUOMType = BundleStockUnitMeasure.strUnitType
		,dblStockUnitQty = BundleStockUOM.dblUnitQty
		,strAllowNegativeInventory = 
			CASE 
				WHEN ComponentItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
				WHEN ComponentItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
				WHEN ComponentItemLocation.intAllowNegativeInventory = 3 THEN 'No' 
			END
			
		,ComponentItemLocation.intCostingMethod
		,strCostingMethod = 
			CASE 
				WHEN ComponentItemLocation.intCostingMethod = 1 THEN 'AVG'
				WHEN ComponentItemLocation.intCostingMethod = 2 THEN 'FIFO'
				WHEN ComponentItemLocation.intCostingMethod = 3 THEN 'LIFO' 
			END
		
		,dblAmountPercent = ISNULL(ComponentPricing.dblAmountPercent, 0)
		,dblSalePrice = ISNULL(ComponentPricing.dblSalePrice, 0)
		,dblMSRPPrice = ISNULL(ComponentPricing.dblMSRPPrice, 0)
		,ComponentPricing.strPricingMethod
		,dblLastCost = ISNULL(ComponentPricing.dblLastCost, 0)
		,dblStandardCost = ISNULL(ComponentPricing.dblStandardCost, 0)
		,dblAverageCost = ISNULL(ComponentPricing.dblAverageCost, 0)
		,dblEndMonthCost = ISNULL(ComponentPricing.dblEndMonthCost, 0)

		,intGrossUOMId = ComponentGrossNetUOM.intItemUOMId
		,dblGrossUOMConvFactor = ComponentGrossNetUOM.dblUnitQty
		,strGrossUOMType = ComponentGrossNetUnitMeasure.strUnitType
		,strGrossUOM = ComponentGrossNetUnitMeasure.strUnitMeasure
		,strGrossUPC = ComponentGrossNetUOM.strUpcCode
		,strGrossLongUPC = ComponentGrossNetUOM.strLongUPCCode

		,BundleComponent.dblDefaultFull
		,BundleComponent.ysnAvailableTM
		,BundleComponent.dblMaintenanceRate
		,BundleComponent.strMaintenanceCalculationMethod
		,BundleComponent.dblOverReceiveTolerance
		,BundleComponent.dblWeightTolerance
		,BundleComponent.intGradeId
		,strGrade = ComponentGrade.strDescription
		,BundleComponent.intLifeTime
		,BundleComponent.strLifeTimeType
		,BundleComponent.ysnListBundleSeparately
		,BundleComponent.strRequired
		,BundleComponent.intTonnageTaxUOMId
		,BundleComponent.intModuleId
		,BundleComponent.ysnUseWeighScales
		,BundleComponent.ysnLotWeightsRequired
			
FROM	
	tblICItemBundle Bundle
	INNER JOIN tblICItem BundleItem ON BundleItem.intItemId = Bundle.intItemId
	INNER JOIN tblICItem BundleComponent ON BundleComponent.intItemId = Bundle.intBundleItemId

	LEFT JOIN (
		tblICItemUOM BundleUOM INNER JOIN tblICUnitMeasure BundleUnitMeasure
			ON BundleUOM.intUnitMeasureId = BundleUnitMeasure.intUnitMeasureId
	)
		ON BundleUOM.intItemId = BundleItem.intItemId
		AND BundleUOM.intItemUOMId = @intItemUOMId
	 	
	LEFT JOIN (
		tblICItemUOM BundleStockUOM INNER JOIN tblICUnitMeasure BundleStockUnitMeasure
			ON BundleStockUOM.intUnitMeasureId = BundleStockUnitMeasure.intUnitMeasureId
	)
		ON BundleStockUOM.intItemId = BundleItem.intItemId
		AND BundleStockUOM.ysnStockUnit = 1

	LEFT JOIN (
		tblICItemUOM BundleCostUOM INNER JOIN tblICUnitMeasure BundleCostUnitMeasure
			ON BundleCostUOM.intUnitMeasureId = BundleCostUnitMeasure.intUnitMeasureId
	)
		ON BundleCostUOM.intItemId = BundleItem.intItemId
		AND BundleCostUOM.intItemUOMId = @intCostUOMId

	LEFT JOIN (
		tblICItemUOM BundleGrossNetUOM INNER JOIN tblICUnitMeasure BundleGrossNetUnitMeasure
			ON BundleGrossNetUOM.intUnitMeasureId = BundleGrossNetUnitMeasure.intUnitMeasureId
	)
		ON BundleGrossNetUOM.intItemId = BundleItem.intItemId
		AND BundleGrossNetUOM.intItemUOMId = @intGrossNetUOMId
	
	LEFT JOIN (
		tblICItemLocation ComponentItemLocation INNER JOIN tblSMCompanyLocation ComponentLocation
			ON ComponentLocation.intCompanyLocationId = ComponentItemLocation.intLocationId
	) ON ComponentItemLocation.intItemId = BundleComponent.intItemId
		AND ComponentItemLocation.intLocationId IS NOT NULL

	LEFT JOIN (
		tblICItemUOM ComponentUOM INNER JOIN tblICUnitMeasure ComponentUnitMeasure
			ON ComponentUOM.intUnitMeasureId = ComponentUnitMeasure.intUnitMeasureId
	) ON 
		ComponentUOM.intItemId = BundleComponent.intItemId
		AND ComponentUOM.intItemUOMId = 
			CASE 
				WHEN BundleItem.strBundleType = 'Option' THEN [dbo].[fnGetMatchingItemUOMId](BundleComponent.intItemId, @intItemUOMId) 
				ELSE Bundle.intItemUnitMeasureId
			END

	LEFT JOIN (
		tblICItemUOM ComponentCostUOM INNER JOIN tblICUnitMeasure ComponentCostUnitMeasure
			ON ComponentCostUOM.intUnitMeasureId = ComponentCostUnitMeasure.intUnitMeasureId
	) ON 
		ComponentCostUOM.intItemId = BundleComponent.intItemId
		AND ComponentCostUOM.intItemUOMId = [dbo].[fnGetMatchingItemUOMId](BundleComponent.intItemId, @intCostUOMId) 

	LEFT JOIN (
		tblICItemUOM ComponentGrossNetUOM INNER JOIN tblICUnitMeasure ComponentGrossNetUnitMeasure
			ON ComponentGrossNetUOM.intUnitMeasureId = ComponentGrossNetUnitMeasure.intUnitMeasureId
	) ON 
		ComponentGrossNetUOM.intItemId = BundleComponent.intItemId
		AND ComponentGrossNetUOM.intItemUOMId = [dbo].[fnGetMatchingItemUOMId](BundleComponent.intItemId, @intGrossNetUOMId) 
		
	LEFT JOIN (
		tblICItemUOM ComponentDefaultCostUOM INNER JOIN tblICUnitMeasure ComponentDefaultCostUnitMeasure
			ON ComponentDefaultCostUOM.intUnitMeasureId = ComponentDefaultCostUnitMeasure.intUnitMeasureId
	) ON 
		ComponentDefaultCostUOM.intItemId = BundleComponent.intItemId
		AND ComponentDefaultCostUOM.intItemUOMId = [dbo].[fnGetMatchingItemUOMId](
			BundleComponent.intItemId
			, BundleStockUOM.intItemUOMId
		) 
		AND ComponentDefaultCostUnitMeasure.strUnitType IN ('Weight', 'Volume')
		
	LEFT JOIN vyuICGetItemPricing ComponentPricing
		ON ComponentPricing.intItemId = BundleComponent.intItemId
		AND ComponentPricing.intLocationId = ComponentLocation.intCompanyLocationId
		AND ComponentPricing.intItemUOMId = ISNULL(ComponentGrossNetUOM.intItemUOMId, ComponentUOM.intItemUOMId) 
		
	LEFT JOIN tblICStorageLocation ComponentStorageLocation 
		ON ComponentStorageLocation.intStorageLocationId = ComponentItemLocation.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation ComponentSubLocation 
		ON ComponentSubLocation.intCompanyLocationSubLocationId = ComponentItemLocation.intSubLocationId

	LEFT JOIN tblICCategory ComponentCategory 
		ON ComponentCategory.intCategoryId = BundleComponent.intCategoryId
	LEFT JOIN tblICCommodity ComponentCommodity 
		ON ComponentCommodity.intCommodityId = BundleComponent.intCommodityId
	LEFT JOIN tblICCommodityAttribute ComponentGrade 
		ON ComponentGrade.intCommodityAttributeId = BundleComponent.intGradeId

WHERE 
	Bundle.intItemId = @intItemId 
	AND ComponentLocation.intCompanyLocationId = @intLocationId
END