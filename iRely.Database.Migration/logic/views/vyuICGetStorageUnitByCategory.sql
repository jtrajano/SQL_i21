--liquibase formatted sql

-- changeset Von:vyuICGetStorageUnitByCategory.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetStorageUnitByCategory]
AS 

SELECT 
	StorageLocation.intStorageLocationId
	, Category.strCategoryCode
	, Category.intCategoryId
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
	, intCount = ISNULL(cnt.intCount, 0) 
FROM tblICStorageLocation StorageLocation
	LEFT JOIN (
		tblICStorageLocationCategory StorageLocationCategory INNER JOIN tblICCategory Category
			ON Category.intCategoryId = StorageLocationCategory.intCategoryId
	)
		ON StorageLocationCategory.intStorageLocationId = StorageLocation.intStorageLocationId
	LEFT JOIN tblICStorageUnitType StorageUnitType 
		ON StorageUnitType.intStorageUnitTypeId = StorageLocation.intStorageUnitTypeId
	LEFT JOIN tblSMCompanyLocation [Location] 
		ON [Location].intCompanyLocationId = StorageLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = StorageLocation.intSubLocationId
	LEFT JOIN tblICStorageLocation ParentStorageLocation 
		ON ParentStorageLocation.intStorageLocationId = StorageLocation.intParentStorageLocationId
	LEFT JOIN tblICRestriction Restriction 
		ON Restriction.intRestrictionId = StorageLocation.intRestrictionId
	LEFT JOIN tblICUnitMeasure UnitMeasure 
		ON UnitMeasure.intUnitMeasureId = StorageLocation.intBatchSizeUOMId
	LEFT JOIN tblICItem Item 
		ON Item.intItemId = StorageLocation.intItemId
	OUTER APPLY (
		SELECT	intCount = COUNT(1) 
		FROM	tblICStorageLocationCategory StorageLocationCategory INNER JOIN tblICCategory Category
					ON Category.intCategoryId = StorageLocationCategory.intCategoryId
		WHERE	StorageLocationCategory.intStorageLocationId = StorageLocation.intStorageLocationId	
	) cnt



