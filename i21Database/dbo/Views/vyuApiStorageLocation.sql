CREATE VIEW [dbo].[vyuApiStorageLocation]
AS
SELECT
      sl.intStorageLocationId
    , sl.strName
    , sl.strDescription
    , t.strStorageUnitType
    , sl.ysnAllowConsume
    , sl.ysnAllowMultipleItem
    , sl.ysnAllowMultipleLot
    , sl.ysnCycleCounted
    , sl.ysnDefaultWHStagingUnit
    , sl.ysnMergeOnMove
    , sl.strUnitGroup
    , sl.dblMinBatchSize
    , sl.dblBatchSize
    , sl.ysnActive
    , sl.dblResidualUnit
    , sl.dblEffectiveDepth
    , sl.dblPackFactor
    , sl.dblUnitPerFoot
    , cl.strSubLocationName
    , sl.intSubLocationId
    , sl.intLocationId
    , l.strLocationName
    , l.strLocationNumber
FROM tblICStorageLocation sl
LEFT JOIN tblICStorageUnitType t ON t.intStorageUnitTypeId = sl.intStorageUnitTypeId
JOIN tblSMCompanyLocationSubLocation cl ON cl.intCompanyLocationSubLocationId = sl.intSubLocationId
JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = sl.intLocationId