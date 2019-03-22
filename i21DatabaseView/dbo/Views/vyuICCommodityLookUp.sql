CREATE VIEW [dbo].[vyuICCommodityLookUp]
	AS

SELECT 
	Commodity.intCommodityId
	,FutureMarket.strFutMarketName
	,StorageSchedule.strScheduleId
	,Discount.strDiscountId
	,StorageType.strStorageTypeCode
	,strAdjustInventorySales = AdjustInventorySales.strTerms
	,strAdjustInventoryTransfer = AdjustInventoryTransfer.strTerms
	,strLineOfBusiness = LineOfBusiness.strLineOfBusiness
FROM tblICCommodity Commodity
	LEFT JOIN tblRKFutureMarket FutureMarket ON FutureMarket.intFutureMarketId = Commodity.intFutureMarketId
	LEFT JOIN tblGRStorageScheduleRule StorageSchedule ON StorageSchedule.intStorageScheduleRuleId = Commodity.intScheduleStoreId
	LEFT JOIN tblGRDiscountId Discount ON Discount.intDiscountId = Commodity.intScheduleDiscountId
	LEFT JOIN tblGRStorageType StorageType ON StorageType.intStorageScheduleTypeId = Commodity.intScaleAutoDistId
	LEFT JOIN tblICAdjustInventoryTerms AdjustInventorySales ON AdjustInventorySales.intAdjustInventoryTermsId = Commodity.intAdjustInventorySales
	LEFT JOIN tblICAdjustInventoryTerms AdjustInventoryTransfer ON AdjustInventoryTransfer.intAdjustInventoryTermsId = Commodity.intAdjustInventoryTransfer
	LEFT JOIN tblSMLineOfBusiness LineOfBusiness ON LineOfBusiness.intLineOfBusinessId = Commodity.intLineOfBusinessId