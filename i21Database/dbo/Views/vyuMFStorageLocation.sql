CREATE VIEW vyuMFStorageLocation
AS
SELECT sl.intStorageLocationId
	,sl.strName AS strStorageLocationName
	,sl.strDescription
	,ut.intStorageUnitTypeId
	,ut.strStorageUnitType
	,r.intRestrictionId
	,r.strDisplayMember AS strStorageLocationRestriction
	,sl.intLocationId AS intCompanyLocationId
	,sl.intSubLocationId AS intCompanyLocationSubLocationId
	,sl.intSequence
	,sl.ysnDefaultWHStagingUnit
	,sl.ysnCycleCounted
	,sl.ysnMergeOnMove
	,sl.ysnAllowMultipleLot
	,sl.ysnAllowMultipleItem
	,sl.ysnAllowConsume
FROM tblICStorageLocation sl
LEFT JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = sl.intStorageUnitTypeId
LEFT JOIN tblICRestriction r ON r.intRestrictionId = sl.intRestrictionId