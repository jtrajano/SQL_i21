CREATE VIEW vyuQMLotStorageLocation
AS
SELECT L.intLotId
	,L.strLotNumber
	,SL.intStorageLocationId
	,SL.strName
FROM tblICStorageLocation SL
JOIN tblICLot L ON L.intStorageLocationId = SL.intStorageLocationId
