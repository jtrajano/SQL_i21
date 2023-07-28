--liquibase formatted sql

-- changeset Von:vyuICGetItemStockForReceipt.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetItemStockForReceipt]
AS
SELECT
	stock.intKey,
	COALESCE(vref.strVendorProduct, novref.strVendorProduct) AS strVendorProduct,
	COALESCE(vref.strProductDescription, novref.strProductDescription) AS strProductDescription,
	vref.intVendorId AS intXrefVendorId,
	COALESCE(upc.strUpcCode, upcs.strUpcCode) AS strShortUpc,
	stock.intItemId,
	stock.strItemNo,
	stock.strShortName,
	stock.strType,
	stock.strManufactureType,
	stock.strBundleType,
	stock.strLotTracking,
	stock.strInventoryTracking,
	stock.strStatus,
	stock.intLocationId,
	stock.ysnStorageUnitRequired,
	stock.intItemLocationId,
	stock.intSubLocationId,
	stock.intCategoryId,
	stock.strCategoryCode,
	stock.ysnRetailValuation,
	stock.intCommodityId,
	stock.strCommodityCode,
	stock.ysnExchangeTraded,
	stock.strStorageLocationName,
	stock.strSubLocationName,
	stock.intStorageLocationId,
	stock.strLocationName,
	stock.strLocationType,
	stock.intVendorId,
	stock.strVendorId,
	stock.intStockUOMId,
	stock.strStockUOM,
	stock.strStockUOMType,
	stock.dblStockUnitQty,
	stock.intReceiveUOMId,
	stock.intReceiveUnitMeasureId,
	stock.dblReceiveUOMConvFactor,
	stock.intIssueUOMId,
	stock.intIssueUnitMeasureId,
	stock.dblIssueUOMConvFactor,
	stock.strReceiveUOMType,
	stock.strIssueUOMType,
	stock.strReceiveUOM,
	stock.strReceiveUPC,
	stock.strReceiveLongUPC,
	COALESCE(EffectivePrice.dblRetailPrice, stock.dblReceiveSalePrice) dblReceiveSalePrice,
	stock.dblReceiveMSRPPrice,
	COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(stock.intItemId, stock.intItemLocationId, COALESCE(stock.intStockUOMId, stock.intReceiveUOMId, stock.intIssueUOMId, stock.intGrossUOMId), tsession.dtmTransactionDate), EffectiveCost.dblCost, stock.dblReceiveLastCost) dblReceiveLastCost,
	stock.dblReceiveStandardCost,
	stock.dblReceiveAverageCost,
	stock.dblReceiveEndMonthCost,
	stock.ysnReceiveUOMAllowPurchase, 
	stock.ysnReceiveUOMAllowSale, 
	stock.strIssueUOM,
	stock.strIssueUPC,
	stock.strIssueLongUPC,
	stock.dblIssueSalePrice,
	stock.dblIssueMSRPPrice,
	COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(stock.intItemId, stock.intItemLocationId, COALESCE(stock.intStockUOMId, stock.intReceiveUOMId, stock.intIssueUOMId, stock.intGrossUOMId), tsession.dtmTransactionDate), EffectiveCost.dblCost, stock.dblIssueLastCost) dblIssueLastCost,
	stock.dblIssueStandardCost,
	stock.dblIssueAverageCost,
	stock.dblIssueEndMonthCost,
	stock.ysnIssueUOMAllowPurchase, 
	stock.ysnIssueUOMAllowSale, 
	stock.intGrossUOMId,
	stock.intGrossUnitMeasureId,
	stock.dblGrossUOMConvFactor,
	stock.strGrossUOMType,
	stock.strGrossUOM,
	stock.strGrossUPC,
	stock.strGrossLongUPC,
	stock.dblGrossSalePrice,
	stock.dblGrossMSRPPrice,
	stock.dblGrossLastCost,
	stock.dblGrossStandardCost,
	stock.dblGrossAverageCost,
	stock.dblGrossEndMonthCost,
	stock.ysnGrossUOMAllowPurchase, 
	stock.ysnGrossUOMAllowSale,
	stock.dblMinOrder,
	stock.dblReorderPoint,
	stock.intAllowNegativeInventory,
	stock.strAllowNegativeInventory,
	stock.intCostingMethod,
	stock.strCostingMethod,
	stock.dblAmountPercent,
	COALESCE(EffectivePrice.dblRetailPrice, stock.dblSalePrice) dblSalePrice,
	stock.dblMSRPPrice,
	stock.strPricingMethod,
	COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(stock.intItemId, stock.intItemLocationId, COALESCE(stock.intStockUOMId, stock.intReceiveUOMId, stock.intIssueUOMId, stock.intGrossUOMId), tsession.dtmTransactionDate), EffectiveCost.dblCost, stock.dblLastCost) dblLastCost,
	stock.dblStandardCost,
	stock.dblAverageCost,
	stock.dblEndMonthCost,
	stock.dblOnOrder,
	stock.dblInTransitInbound,
	stock.dblUnitOnHand,
	stock.dblInTransitOutbound,
	stock.dblBackOrder,
	stock.dblOrderCommitted,
	stock.dblUnitStorage,
	stock.dblConsignedPurchase,
	stock.dblConsignedSale,
	stock.dblUnitReserved,
	stock.dblOpenPurchaseContract,
	stock.dblOpenSalesContract,
	stock.dblLastCountRetail,
	stock.dblAvailable,	
	stock.dblDefaultFull,
	stock.ysnAvailableTM,
	stock.dblMaintenanceRate,
	stock.strMaintenanceCalculationMethod,
	stock.dblOverReceiveTolerance,
	stock.dblWeightTolerance,
	stock.intGradeId,
	stock.strDescription,
	stock.intLifeTime,
	stock.strLifeTimeType,
	stock.ysnListBundleSeparately,
	stock.dblExtendedCost,
	stock.strRequired,
	stock.intTonnageTaxUOMId,
	stock.strTonnageTaxUOM,
	stock.intModuleId,
	stock.strModule,
	stock.ysn1099Box3,
	stock.ysnUseWeighScales,
	stock.ysnLotWeightsRequired,
	stock.ysnHasAddOn,
	stock.ysnHasSubstitute,
	stock.ysnHasAddOnOtherCharge,
	stock.dblReceiveStandardWeight,
	guiSessionId = tsession.guiSessionId,
	dtmSessionDate = tsession.dtmTransactionDate
FROM vyuICGetItemStock stock
	OUTER APPLY tblICTransactionSession tsession
	OUTER APPLY dbo.fnICGetItemCostByEffectiveDate(tsession.dtmTransactionDate, stock.intItemId, stock.intItemLocationId, DEFAULT) EffectiveCost
	OUTER APPLY dbo.fnICGetItemPriceByEffectiveDate(tsession.dtmTransactionDate, stock.intItemId, stock.intItemLocationId, COALESCE(stock.intStockUOMId, stock.intReceiveUOMId, stock.intIssueUOMId, stock.intGrossUOMId), DEFAULT) EffectivePrice
	OUTER APPLY (
		SELECT TOP 1 xref.intVendorId, xref.strProductDescription, xref.strVendorProduct
		FROM tblICItemVendorXref xref
		WHERE xref.intItemId = stock.intItemId
			AND (stock.intItemLocationId = xref.intItemLocationId)
		ORDER BY xref.intItemVendorXrefId DESC
	) vref
	OUTER APPLY (
		SELECT TOP 1 xref.intVendorId, xref.strProductDescription, xref.strVendorProduct
		FROM tblICItemVendorXref xref
		WHERE xref.intItemId = stock.intItemId
			AND xref.intItemLocationId IS NULL
		ORDER BY xref.intItemVendorXrefId DESC
	) novref
	LEFT JOIN tblICItemUOM upc ON upc.intItemUOMId = stock.intReceiveUOMId
	LEFT JOIN tblICItemUOM upcs ON upcs.intItemUOMId = stock.intStockUOMId
WHERE stock.ysnActive = 1



