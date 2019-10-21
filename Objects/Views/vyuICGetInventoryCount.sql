CREATE VIEW [dbo].[vyuICGetInventoryCount]
	AS

SELECT InventoryCount.intInventoryCountId,
	InventoryCount.intLocationId,
	Location.strLocationName,
	InventoryCount.intCategoryId,
	InventoryCount.intCategoryToId,
	strCategory = Category.strCategoryCode,
	strCategoryTo = CategoryTo.strCategoryCode,
	InventoryCount.intCommodityId,
	InventoryCount.intCommodityToId,
	strCommodity = Commodity.strCommodityCode,
	strCommodityTo = CommodityTo.strCommodityCode,
	InventoryCount.intCountGroupId,
	CountGroup.strCountGroup,
	InventoryCount.dtmCountDate,
	InventoryCount.strCountNo,
	InventoryCount.intSubLocationId,
	InventoryCount.intSubLocationToId,
	SubLocation.strSubLocationName,
	strSubLocationNameTo = SubLocationTo.strSubLocationName,
	InventoryCount.intStorageLocationId,
	InventoryCount.intStorageLocationToId,
	strStorageLocationName = StorageLocation.strName,
	strStorageLocationNameTo = StorageLocationTo.strName,
	InventoryCount.strDescription,
	InventoryCount.ysnIncludeZeroOnHand,
	InventoryCount.ysnIncludeOnHand,
	InventoryCount.ysnScannedCountEntry,
	InventoryCount.ysnCountByLots,
	InventoryCount.strCountBy,
	InventoryCount.ysnCountByPallets,
	InventoryCount.ysnRecountMismatch,
	InventoryCount.ysnExternal,
	InventoryCount.ysnRecount,
	InventoryCount.intRecountReferenceId,
	InventoryCount.intStatus,
	InventoryCount.[strStorageLocationsFilter],
	InventoryCount.[strStorageUnitsFilter],
	InventoryCount.[strCommoditiesFilter],
	InventoryCount.[strCategoriesFilter],
	InventoryCount.[ysnIsMultiFilter],
	strRecountReferenceNo = ReferenceCount.strCountNo,
	strStatus = (CASE WHEN InventoryCount.intStatus = 1 THEN 'Open'
					WHEN InventoryCount.intStatus = 2 THEN 'Count Sheet Printed'
					WHEN InventoryCount.intStatus = 3 THEN 'Inventory Locked'
					WHEN InventoryCount.intStatus = 4 THEN 'Closed'
				END) COLLATE Latin1_General_CI_AS,
	strShiftNo = InventoryCount.strShiftNo,
	InventoryCount.intSort
FROM tblICInventoryCount InventoryCount
	LEFT JOIN tblICInventoryCount ReferenceCount ON ReferenceCount.intInventoryCountId = InventoryCount.intRecountReferenceId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = InventoryCount.intLocationId
	LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = InventoryCount.intCountGroupId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = InventoryCount.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = InventoryCount.intCommodityId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = InventoryCount.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = InventoryCount.intStorageLocationId
	LEFT JOIN tblICCategory CategoryTo ON CategoryTo.intCategoryId = InventoryCount.intCategoryToId
	LEFT JOIN tblICCommodity CommodityTo ON CommodityTo.intCommodityId = InventoryCount.intCommodityToId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocationTo ON SubLocationTo.intCompanyLocationSubLocationId = InventoryCount.intSubLocationToId
	LEFT JOIN tblICStorageLocation StorageLocationTo ON StorageLocationTo.intStorageLocationId = InventoryCount.intStorageLocationToId