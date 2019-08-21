CREATE VIEW vyuMFCompanyPreference
AS
SELECT CP.*
	,SL.strName AS strShipmentStagingLocation
	,SL1.strName AS strShipmentDockDoorLocation
	,LS.strSecondaryStatus AS strBondLotStatus
	,LS1.strSecondaryStatus AS strDamagedLotStatus
	,LS2.strSecondaryStatus AS strSanitizedLotStatus
	,C.strControlPointName AS strPreProductionControlPointName
	,CT.strContainerType
FROM tblMFCompanyPreference CP
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CP.intDefaultShipmentStagingLocation
LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = CP.intDefaultShipmentDockDoorLocation
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intBondStatusId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intDamagedStatusId
LEFT JOIN tblICLotStatus LS2 ON LS2.intLotStatusId = CP.intDefaultStatusForSanitizedLot
LEFT JOIN tblQMControlPoint C ON C.intControlPointId = CP.intPreProductionControlPointId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CP.intContainerTypeId
