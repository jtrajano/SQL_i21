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
	, StorageLocation.dblEffectiveDepth
	, StorageLocation.intSubLocationId
	, SubLocation.strSubLocationName
	, Detail.dblAirSpaceReading
	, Detail.dblCashPrice
	, Detail.intDiscountSchedule
	, strDiscountSchedule = ''
FROM tblICStorageMeasurementReadingConversion Detail
LEFT JOIN tblICStorageMeasurementReading Header ON Header.intStorageMeasurementReadingId = Detail.intStorageMeasurementReadingId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Detail.intCommodityId
LEFT JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Detail.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StorageLocation.intSubLocationId
