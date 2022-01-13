CREATE VIEW dbo.vyuICGetItemStockForShipment
AS

SELECT
v.intKey
, v.intItemId
, v.strItemNo
, v.strShortName
, v.strType
, v.strManufactureType
, v.strBundleType
, v.strDescription
, v.strLotTracking
, v.strInventoryTracking
, v.strStatus
, v.intLocationId
, v.ysnStorageUnitRequired
, v.intItemLocationId
, v.intSubLocationId
, v.intCategoryId
, v.strCategoryCode
, v.ysnRetailValuation
, v.intCommodityId
, v.strCommodityCode
, v.ysnExchangeTraded
, v.strStorageLocationName
, v.strSubLocationName
, v.intStorageLocationId
, v.strLocationName
, v.strLocationType
, v.intVendorId
, v.strVendorId
, v.intStockUOMId
, v.strStockUOM
, v.strStockUOMType
, v.dblStockUnitQty
, v.intReceiveUOMId
, v.intReceiveUnitMeasureId
, v.dblReceiveUOMConvFactor
, v.intIssueUOMId
, v.intIssueUnitMeasureId
, v.dblIssueUOMConvFactor
, v.strReceiveUOMType
, v.strIssueUOMType
, v.strReceiveUOM
, v.strReceiveUPC
, v.strReceieveLongUPC
, COALESCE(EffectivePrice.dblRetailPrice, v.dblReceiveSalePrice) dblReceiveSalePrice
, v.dblReceiveMSRPPrice
, COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(v.intItemId, v.intItemLocationId, intReceiveUOMId, tsession.dtmTransactionDate), EffectiveCost.dblCost, v.dblReceiveLastCost) dblReceiveLastCost
, v.dblReceiveStandardCost
, v.dblReceiveAverageCost
, v.dblReceiveEndMonthCost
, v.ysnReceiveUOMAllowPurchase
, v.ysnReceiveUOMAllowSale
, v.strIssueUOM
, v.strIssueUPC
, v.strIssueLongUPC
, COALESCE(EffectivePrice.dblRetailPrice, v.dblIssueSalePrice) dblIssueSalePrice
, v.dblIssueMSRPPrice
, COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(v.intItemId, v.intItemLocationId, intIssueUOMId, tsession.dtmTransactionDate), EffectiveCost.dblCost, v.dblIssueLastCost) dblIssueLastCost
, v.dblIssueStandardCost
, v.dblIssueAverageCost
, v.dblIssueEndMonthCost
, v.ysnIssueUOMAllowPurchase
, v.ysnIssueUOMAllowSale
, v.intGrossUOMId
, v.intGrossUnitMeasureId
, v.dblGrossUOMConvFactor
, v.strGrossUOMType
, v.strGrossUOM
, v.strGrossUPC
, v.strGrossLongUPC
, v.dblGrossSalePrice
, v.dblGrossMSRPPrice
, v.dblGrossLastCost
, v.dblGrossStandardCost
, v.dblGrossAverageCost
, v.dblGrossEndMonthCost
, v.ysnGrossUOMAllowPurchase
, v.ysnGrossUOMAllowSale
, v.dblMinOrder
, v.dblReorderPoint
, v.intAllowNegativeInventory
, v.strAllowNegativeInventory
, v.intCostingMethod
, v.strCostingMethod
, v.dblAmountPercent
, COALESCE(EffectivePrice.dblRetailPrice, v.dblSalePrice) dblSalePrice
, v.dblMSRPPrice
, v.strPricingMethod
, COALESCE(dbo.fnICGetPromotionalCostByEffectiveDate(v.intItemId, v.intItemLocationId, intStockUOMId, tsession.dtmTransactionDate), EffectiveCost.dblCost, v.dblLastCost) dblLastCost
, v.dblStandardCost
, v.dblAverageCost
, v.dblEndMonthCost
, v.dblOnOrder
, v.dblInTransitInbound
, v.dblUnitOnHand
, v.dblInTransitOutbound
, v.dblBackOrder
, v.dblOrderCommitted
, v.dblUnitStorage
, v.dblConsignedPurchase
, v.dblConsignedSale
, v.dblUnitReserved
, v.dblOpenPurchaseContract
, v.dblOpenSalesContract
, v.dblLastCountRetail
, v.dblAvailable
, v.dblDefaultFull
, v.ysnAvailableTM
, v.dblMaintenanceRate
, v.strMaintenanceCalculationMethod
, v.dblOverReceiveTolerance
, v.dblWeightTolerance
, v.intGradeId
, v.strGrade
, v.intLifeTime
, v.strLifeTimeType
, v.ysnListBundleSeparately
, v.dblExtendedCost
, v.strRequired
, v.intTonnageTaxUOMId
, v.strTonnageTaxUOM
, v.intModuleId
, v.strModule
, v.ysn1099Box3
, v.ysnUseWeighScales
, v.ysnLotWeightsRequired
, v.ysnHasAddOn
, v.ysnHasSubstitute
, v.ysnHasAddOnOtherCharge
, v.dblReceiveStandardWeight
, guiSessionId = tsession.guiSessionId
, dtmSessionDate = tsession.dtmTransactionDate
, v.dblStandardWeight
FROM vyuICGetItemStock v
OUTER APPLY tblICTransactionSession tsession
OUTER APPLY dbo.fnICGetItemCostByEffectiveDate(tsession.dtmTransactionDate, v.intItemId, v.intItemLocationId, DEFAULT) EffectiveCost
OUTER APPLY dbo.fnICGetItemPriceByEffectiveDate(tsession.dtmTransactionDate, v.intItemId, v.intItemLocationId, COALESCE(v.intStockUOMId, v.intReceiveUOMId, v.intIssueUOMId, v.intGrossUOMId), DEFAULT) EffectivePrice