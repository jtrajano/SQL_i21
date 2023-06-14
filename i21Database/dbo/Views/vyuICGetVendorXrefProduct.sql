CREATE VIEW [dbo].[vyuICGetVendorXrefProduct]
AS 

SELECT 
	intKey = row_no.intKey, 
	Item.intItemId,
	Item.strItemNo,
	Item.strShortName,
	Item.strType,
	Item.strManufactureType,
	Item.strBundleType,
	Item.strDescription,
	Item.strLotTracking,
	Item.strInventoryTracking,
	Item.strStatus,
	ItemLocation.intLocationId,
	ItemLocation.ysnStorageUnitRequired,
	ItemLocation.intItemLocationId,
	ItemLocation.intSubLocationId,
	ItemLocation.ysnActive,
	Item.intCategoryId,
	Category.strCategoryCode,
	Category.ysnRetailValuation,
	Item.intCommodityId,
	Commodity.strCommodityCode,
	Commodity.ysnExchangeTraded,
	StorageLocation.strName AS strStorageLocationName,
	SubLocation.strSubLocationName AS strSubLocationName,
	ItemLocation.intStorageLocationId,
	l.strLocationName,
	l.strLocationType,
	intStockUOMId = StockUOM.intItemUOMId,
	strStockUOM = StockUOM.strUnitMeasure,
	strStockUOMType = StockUOM.strUnitType,
	dblStockUnitQty = StockUOM.dblUnitQty,
	
	intReceiveUOMId = ReceiveUOM.intItemUOMId,
	intReceiveUnitMeasureId = ReceiveUOM.intUnitMeasureId,
	dblReceiveUOMConvFactor = ISNULL(ReceiveUOM.dblUnitQty, 0),
	intIssueUOMId = IssueUOM.intItemUOMId,
	intIssueUnitMeasureId = IssueUOM.intUnitMeasureId,
	dblIssueUOMConvFactor = COALESCE(IssueUOM.dblUnitQty, 0),

	strReceiveUOMType = IssueUOM.strUnitType,
	strIssueUOMType = IssueUOM.strUnitType,
	strReceiveUOM = ReceiveUOM.strUnitMeasure,
	strReceiveUPC = COALESCE(ReceiveUOM.strLongUPCCode, ReceiveUOM.strUpcCode, ''),
	strReceiveLongUPC = COALESCE(ReceiveUOM.strLongUPCCode, ''),
	dblReceiveSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * COALESCE(ReceiveUOM.dblUnitQty, 0),
	dblReceiveMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * COALESCE(ReceiveUOM.dblUnitQty, 0),
	dblReceiveLastCost = ISNULL(ItemPricing.dblLastCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, StockUOM.dblUnitQty, 0),
	dblReceiveStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, 0),
	dblReceiveAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, 0),
	dblReceiveEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * COALESCE(ReceiveUOM.dblUnitQty, 0),
	ysnReceiveUOMAllowPurchase = ReceiveUOM.ysnAllowPurchase, 
	ysnReceiveUOMAllowSale = ReceiveUOM.ysnAllowSale, 
	
	strIssueUOM = IssueUOM.strUnitMeasure,
	strIssueUPC = COALESCE(IssueUOM.strLongUPCCode, IssueUOM.strUpcCode, ''),
	strIssueLongUPC = COALESCE(IssueUOM.strLongUPCCode, ''),
	dblIssueSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	dblIssueMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	dblIssueLastCost = ISNULL(ItemPricing.dblLastCost, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	dblIssueStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	dblIssueAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	dblIssueEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * COALESCE(IssueUOM.dblUnitQty, 0),
	ysnIssueUOMAllowPurchase = IssueUOM.ysnAllowPurchase, 
	ysnIssueUOMAllowSale = IssueUOM.ysnAllowSale, 
	
	intGrossUOMId = GrossUOM.intItemUOMId,
	intGrossUnitMeasureId = GrossUOM.intUnitMeasureId,
	dblGrossUOMConvFactor = GrossUOM.dblUnitQty,
	strGrossUOMType = gUOM.strUnitType,
	strGrossUOM = gUOM.strUnitMeasure,
	strGrossUPC = GrossUOM.strUpcCode,
	strGrossLongUPC = GrossUOM.strLongUPCCode,
	dblGrossSalePrice = ISNULL(ItemPricing.dblSalePrice, 0) * GrossUOM.dblUnitQty,
	dblGrossMSRPPrice = ISNULL(ItemPricing.dblMSRPPrice, 0) * GrossUOM.dblUnitQty,
	dblGrossLastCost = ISNULL(ItemPricing.dblLastCost, 0) * GrossUOM.dblUnitQty,
	dblGrossStandardCost = ISNULL(ItemPricing.dblStandardCost, 0) * GrossUOM.dblUnitQty,
	dblGrossAverageCost = ISNULL(ItemPricing.dblAverageCost, 0) * GrossUOM.dblUnitQty,
	dblGrossEndMonthCost = ISNULL(ItemPricing.dblEndMonthCost, 0) * GrossUOM.dblUnitQty,
	ysnGrossUOMAllowPurchase = GrossUOM.ysnAllowPurchase, 
	ysnGrossUOMAllowSale = GrossUOM.ysnAllowSale, 

	dblMinOrder = ISNULL(ItemLocation.dblMinOrder, 0),
	dblReorderPoint = ISNULL(ItemLocation.dblReorderPoint, 0),
	ItemLocation.intAllowNegativeInventory,
	strAllowNegativeInventory = (CASE WHEN ItemLocation.intAllowNegativeInventory = 1 THEN 'Yes'
							 WHEN ItemLocation.intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
							 WHEN ItemLocation.intAllowNegativeInventory = 3 THEN 'No' END) COLLATE Latin1_General_CI_AS,
	intCostingMethod = 
		CASE 
			WHEN ISNULL(Item.strLotTracking, 'No') <> 'No' THEN 
				4 -- 4 is for Lot Costing
			ELSE
				ItemLocation.intCostingMethod
		END,

	strCostingMethod = 
		CASE 
			WHEN ISNULL(Item.strLotTracking, 'No') <> 'No' THEN 
				'LOT'
			ELSE
				CostingMethod.strCostingMethod
		END COLLATE Latin1_General_CI_AS,

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
	dblUnitOnHand = CAST(ISNULL(ItemStock.dblUnitOnHand, 0) AS NUMERIC(38, 7)),
	dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0),
	dblBackOrder =	dbo.fnMaxNumeric(ISNULL(ItemStock.dblOrderCommitted, 0.00) - (ISNULL(ItemStock.dblUnitOnHand, 0.00) - (ISNULL(ItemStock.dblUnitReserved, 0.00) + ISNULL(ItemStock.dblConsignedSale, 0.00))), 0),
	dblOrderCommitted = ISNULL(ItemStock.dblOrderCommitted, 0),
	dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0),
	dblConsignedPurchase = ISNULL(ItemStock.dblConsignedPurchase, 0),
	dblConsignedSale = ISNULL(ItemStock.dblConsignedSale, 0),
	dblUnitReserved = ISNULL(ItemStock.dblUnitReserved, 0),
	dblOpenPurchaseContract = ISNULL(ItemStock.dblOpenPurchaseContract, 0),
	dblOpenSalesContract = ISNULL(ItemStock.dblOpenSalesContract, 0),
	dblLastCountRetail = ISNULL(ItemStock.dblLastCountRetail, 0),
	dblAvailable = 
				ISNULL(ItemStock.dblUnitOnHand, 0)  
				- (
						ISNULL(ItemStock.dblUnitReserved, 0) 
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
	dblExtendedCost = ISNULL(ItemStock.dblUnitOnHand, 0) * ISNULL(ItemPricing.dblAverageCost, 0),
	Item.strRequired,
	Item.intTonnageTaxUOMId,
	strTonnageTaxUOM = TonnageUOM.strUnitMeasure,
	Item.intModuleId,
	m.strModule,
	Item.ysn1099Box3,
	Item.ysnUseWeighScales,
	Item.ysnLotWeightsRequired,
	ysnHasAddOn = CAST(ISNULL(ItemAddOn.ysnHasAddOn, 0) AS BIT),
	ysnHasSubstitute = CAST(ISNULL(ItemSubstitute.ysnHasSubstitute, 0) AS BIT),
	ysnHasAddOnOtherCharge = CAST(ISNULL(AddOnOtherCharge.ysnHasAddOnOtherCharge, 0) AS BIT),
	dblStandardWeight = StockUOM.dblStandardWeight,
	dblReceiveStandardWeight = ReceiveUOM.dblStandardWeight,
	Item.ysnTankRequired,
	Item.intBrandId,
	strVendorProduct = VendorXref.strVendorProduct,
	strProductDescription = VendorXref.strProductDescription,
	intVendorId = VendorXref.intVendorId,
	strVendorId = v.strVendorId,
	intVendorXRefItemUOMId = VendorXref.intItemUnitMeasureId,
	intItemVendorXrefId  = VendorXref.intItemVendorXrefId
FROM	
	tblICItemVendorXref VendorXref		
	INNER JOIN tblICItem Item ON Item.intItemId = VendorXref.intItemId
	INNER JOIN tblAPVendor v ON v.intEntityId = VendorXref.intVendorId

	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	)
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId IS NOT NULL
		
	OUTER APPLY (
		SELECT TOP 1 
			stockUOM.* 
			,stockUnitMeasure.strUnitMeasure
			,stockUnitMeasure.strUnitType
		FROM 
			tblICItemUOM stockUOM INNER JOIN tblICUnitMeasure stockUnitMeasure
				ON stockUOM.intUnitMeasureId = stockUnitMeasure.intUnitMeasureId
		WHERE
			stockUOM.intItemId = Item.intItemId 
			AND stockUOM.ysnStockUnit = 1
	) StockUOM		

	OUTER APPLY (
		SELECT TOP 1 
			defaultReceiveItemUOM.*
			,defaultReceiveUOM.strUnitMeasure
			,defaultReceiveUOM.strUnitType
		FROM 
			tblICItemUOM defaultReceiveItemUOM INNER JOIN tblICUnitMeasure defaultReceiveUOM 
				ON defaultReceiveItemUOM.intUnitMeasureId = defaultReceiveUOM.intUnitMeasureId
			LEFT JOIN tblICItemLocation locationReceiveUOM 
				ON locationReceiveUOM.intItemId = Item.intItemId				
				AND locationReceiveUOM.intItemLocationId = ItemLocation.intItemLocationId
				AND locationReceiveUOM.intReceiveUOMId = defaultReceiveItemUOM.intItemUOMId				
		WHERE
			defaultReceiveItemUOM.intItemId = Item.intItemId			
			AND defaultReceiveItemUOM.ysnAllowPurchase = 1
		ORDER BY
			locationReceiveUOM.intItemLocationId DESC 
			,defaultReceiveItemUOM.ysnStockUnit DESC 
	) ReceiveUOM

	OUTER APPLY (
		SELECT TOP 1 
			defaultIssueItemUOM.*
			,defaultIssueUOM.strUnitMeasure
			,defaultIssueUOM.strUnitType
		FROM 
			tblICItemUOM defaultIssueItemUOM INNER JOIN tblICUnitMeasure defaultIssueUOM 
				ON defaultIssueItemUOM.intUnitMeasureId = defaultIssueUOM.intUnitMeasureId
			LEFT JOIN tblICItemLocation locationIssueUOM 
				ON locationIssueUOM.intItemId = Item.intItemId				
				AND locationIssueUOM.intItemLocationId = ItemLocation.intItemLocationId
				AND locationIssueUOM.intIssueUOMId = defaultIssueItemUOM.intItemUOMId
		WHERE
			defaultIssueItemUOM.intItemId = Item.intItemId			
			AND defaultIssueItemUOM.ysnAllowSale = 1
		ORDER BY
			locationIssueUOM.intItemLocationId DESC 
			,defaultIssueItemUOM.ysnStockUnit DESC 
	) IssueUOM
	
	LEFT JOIN (
		tblICItemUOM GrossUOM INNER JOIN tblICUnitMeasure gUOM 
			ON gUOM.intUnitMeasureId = GrossUOM.intUnitMeasureId
			AND gUOM.strUnitType IN ('Volume', 'Weight')
	)
		ON GrossUOM.intItemUOMId = ItemLocation.intGrossUOMId

	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemLocation.intItemId = ItemPricing.intItemId 
		AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId

	LEFT JOIN tblICStorageLocation StorageLocation 
		ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId

	LEFT JOIN tblICItemStock ItemStock 
		ON ItemStock.intItemId = Item.intItemId 
		AND ItemLocation.intItemLocationId = ItemStock.intItemLocationId

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId

	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId

	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId

	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = Item.intGradeId

	LEFT JOIN tblICUnitMeasure TonnageUOM 
		ON TonnageUOM.intUnitMeasureId = Item.intTonnageTaxUOMId

	LEFT JOIN tblSMModule m
		ON m.intModuleId = Item.intModuleId

	LEFT JOIN tblICCostingMethod CostingMethod
		ON CostingMethod.intCostingMethodId = ItemLocation.intCostingMethod

	OUTER APPLY (
		SELECT TOP 1 1 as ysnHasAddOn FROM tblICItemAddOn ItemAddOn 
		WHERE ItemAddOn.intItemId = Item.intItemId
	) ItemAddOn

	OUTER APPLY(
		SELECT TOP 1 1 as ysnHasSubstitute FROM tblICItemSubstitute ItemSubstitute
		WHERE ItemSubstitute.intItemId = Item.intItemId
	) ItemSubstitute

	OUTER APPLY(
		SELECT TOP 1 1 as ysnHasAddOnOtherCharge FROM tblICItemAddOn ItemAddOn
		INNER JOIN tblICItem ChargeItem ON ChargeItem.intItemId = ItemAddOn.intItemId
		WHERE ItemAddOn.intItemId = Item.intItemId
		AND ChargeItem.strType = 'Other Charge'
	) AddOnOtherCharge

	LEFT JOIN tblICTally row_no
		ON row_no.intId1 = VendorXref.intItemVendorXrefId
		AND (
			row_no.intId2 = ItemLocation.intLocationId 
			OR (row_no.intId2 IS NULL AND ItemLocation.intLocationId IS NULL) 
		)