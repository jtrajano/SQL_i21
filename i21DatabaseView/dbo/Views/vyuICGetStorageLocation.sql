CREATE VIEW [dbo].[vyuICGetStorageLocation]
	AS 

SELECT StorageLocation.intStorageLocationId
	, StorageLocation.strName
	, StorageLocation.strDescription
	, StorageLocation.intStorageUnitTypeId
	, strStorageUnitType
	, StorageLocation.intLocationId
	, strLocationName
	, StorageLocation.intSubLocationId
	, strSubLocationName
	, StorageLocation.intParentStorageLocationId
	, strParentStorageLocationName = ParentStorageLocation.strName
	, StorageLocation.ysnAllowConsume
	, StorageLocation.ysnAllowMultipleItem
	, StorageLocation.ysnAllowMultipleLot
	, StorageLocation.ysnMergeOnMove
	, StorageLocation.ysnCycleCounted
	, StorageLocation.ysnDefaultWHStagingUnit
	, StorageLocation.intRestrictionId
	, strRestrictionCode = Restriction.strInternalCode
	, strRestrictionDesc = Restriction.strDisplayMember
	, StorageLocation.strUnitGroup
	, StorageLocation.dblMinBatchSize
	, StorageLocation.dblBatchSize
	, StorageLocation.intBatchSizeUOMId
	, StorageLocation.intSequence
	, StorageLocation.ysnActive
	, StorageLocation.intRelativeX
	, StorageLocation.intRelativeY
	, StorageLocation.intRelativeZ
	, StorageLocation.intCommodityId
	, StorageLocation.dblPackFactor
	, StorageLocation.dblEffectiveDepth
	, StorageLocation.dblUnitPerFoot
	, StorageLocation.dblResidualUnit
	, strBatchSizeUOM = UnitMeasure.strUnitMeasure
	, StorageUnitType.strInternalCode
	, intItemId = StorageLocation.intItemId
	, strItemNo = Item.strItemNo
FROM tblICStorageLocation StorageLocation
	LEFT JOIN tblICStorageUnitType StorageUnitType ON StorageUnitType.intStorageUnitTypeId = StorageLocation.intStorageUnitTypeId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = StorageLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = StorageLocation.intSubLocationId
	LEFT JOIN tblICStorageLocation ParentStorageLocation ON ParentStorageLocation.intStorageLocationId = StorageLocation.intParentStorageLocationId
	LEFT JOIN tblICRestriction Restriction ON Restriction.intRestrictionId = StorageLocation.intRestrictionId
LEFT JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId = StorageLocation.intBatchSizeUOMId
LEFT JOIN tblICItem Item ON Item.intItemId = StorageLocation.intItemId