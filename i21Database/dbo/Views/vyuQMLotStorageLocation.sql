CREATE VIEW vyuQMLotStorageLocation
AS
SELECT L.intLotId
	,L.strLotNumber
	,SL.intStorageLocationId
	,SL.strName
	,CL.intCompanyLocationSubLocationId
	,CL.strSubLocationName
	,CL.intCompanyLocationId
FROM tblICStorageLocation SL
JOIN tblICLot L ON L.intStorageLocationId = SL.intStorageLocationId
JOIN tblSMCompanyLocationSubLocation CL ON CL.intCompanyLocationSubLocationId = L.intSubLocationId