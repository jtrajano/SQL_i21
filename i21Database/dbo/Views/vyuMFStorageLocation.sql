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
	,SubLocation.strSubLocationName
	,sl.intSequence
	,sl.ysnDefaultWHStagingUnit
	,sl.ysnCycleCounted
	,sl.ysnMergeOnMove
	,sl.ysnAllowMultipleLot
	,sl.ysnAllowMultipleItem
	,sl.ysnAllowConsume
	,ut.strInternalCode
FROM tblICStorageLocation sl
JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = sl.intStorageUnitTypeId
JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = sl.intSubLocationId
LEFT JOIN tblICRestriction r ON r.intRestrictionId = sl.intRestrictionId
