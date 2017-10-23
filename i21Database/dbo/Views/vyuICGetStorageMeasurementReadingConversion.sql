CREATE VIEW [dbo].[vyuICGetStorageMeasurementReadingConversion]
	AS 

SELECT Detail.intStorageMeasurementReadingConversionId
	, Detail.intStorageMeasurementReadingId
	, Header.strReadingNo
	, Header.dtmDate
	, Detail.intCommodityId
	, strCommodity = Commodity.strCommodityCode
	, Detail.intItemId
	, Item.strItemNo
	, Detail.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, Detail.dblEffectiveDepth
	, StorageLocation.intSubLocationId
	, SubLocation.strSubLocationName
	, Detail.dblAirSpaceReading
	, Detail.dblCashPrice
	, Detail.intDiscountSchedule
	, strDiscountSchedule = DiscountSchedule.strDiscountId
	, UOM.strUnitMeasure
	, UOM.intUnitMeasureId
	, StorageLocation.dblPackFactor
	, StorageLocation.dblUnitPerFoot
	, StorageLocation.dblResidualUnit
	, Detail.dblOnHand
	, Detail.dblNewOnHand
	, Detail.dblValue
	, Detail.dblVariance
	, Detail.dblGainLoss
FROM tblICStorageMeasurementReadingConversion Detail
LEFT JOIN tblICStorageMeasurementReading Header ON Header.intStorageMeasurementReadingId = Detail.intStorageMeasurementReadingId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Detail.intCommodityId
LEFT JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Detail.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StorageLocation.intSubLocationId
LEFT JOIN tblGRDiscountId DiscountSchedule ON DiscountSchedule.intDiscountId = Detail.intDiscountSchedule
LEFT JOIN vyuICGetItemUOM UOM on UOM.intItemId = Item.intItemId
	AND UOM.ysnStockUnit = 1