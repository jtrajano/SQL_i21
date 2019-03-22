CREATE VIEW vyuMFWastageLotStorageLocation
AS
-- Storage Location
SELECT DISTINCT 1 AS intTypeId
	,SL.intStorageLocationId AS intId
	,SL.intStorageLocationId
	,SL.strName
	,SL.intLocationId
	,NULL AS intLotId
	,NULL AS strLotNumber
	,NULL AS strLotAlias
	,NULL AS intItemId
FROM tblICStorageLocation SL
JOIN tblICStorageUnitType SUT ON SUT.intStorageUnitTypeId = SL.intStorageUnitTypeId
	AND strInternalCode = 'STORAGE'

UNION

-- Lot
SELECT DISTINCT 2 AS intTypeId
	,MAX(L.intLotId) AS intId
	,L.intStorageLocationId
	,NULL AS strName
	,L.intLocationId
	,MAX(L.intLotId) AS intLotId
	,L.strLotNumber
	,L.strLotAlias
	,L.intItemId
FROM tblICLot L
GROUP BY L.strLotNumber
	,L.strLotAlias
	,L.intItemId
	,L.intStorageLocationId
	,L.intLocationId
