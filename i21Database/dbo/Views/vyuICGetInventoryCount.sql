CREATE VIEW [dbo].[vyuICGetInventoryCount]
	AS

SELECT InventoryCount.intInventoryCountId,
	InventoryCount.intLocationId,
	Location.strLocationName,
	InventoryCount.intCategoryId,
	strCategory = Category.strCategoryCode,
	InventoryCount.intCommodityId,
	strCommodity = Commodity.strCommodityCode,
	InventoryCount.intCountGroupId,
	CountGroup.strCountGroup,
	InventoryCount.dtmCountDate,
	InventoryCount.strCountNo,
	InventoryCount.intSubLocationId,
	SubLocation.strSubLocationName,
	InventoryCount.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
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
	strRecountReferenceNo = ReferenceCount.strCountNo,
	strStatus = (CASE WHEN InventoryCount.intStatus = 1 THEN 'Open'
					WHEN InventoryCount.intStatus = 2 THEN 'Count Sheet Printed'
					WHEN InventoryCount.intStatus = 3 THEN 'Inventory Locked'
					WHEN InventoryCount.intStatus = 4 THEN 'Closed'
				END),
	strShiftNo = InventoryCount.strShiftNo,
	InventoryCount.intSort
FROM tblICInventoryCount InventoryCount
	LEFT JOIN tblICInventoryCount ReferenceCount ON ReferenceCount.intInventoryCountId = InventoryCount.intRecountReferenceId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = InventoryCount.intLocationId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = InventoryCount.intCategoryId
	LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = InventoryCount.intCommodityId
	LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = InventoryCount.intCountGroupId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = InventoryCount.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = InventoryCount.intStorageLocationId