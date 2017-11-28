CREATE VIEW vyuMFCompanyPreference
AS
SELECT CP.*
	,CP.strDefaultStatusForSanitizedLot AS strSanitizedLotStatus
	,SL.strName AS strShipmentStagingLocation
	,SL1.strName AS strShipmentDockDoorLocation
	,LS.strSecondaryStatus AS strBondLotStatus
	,LS1.strSecondaryStatus AS strDamagedLotStatus
	,CASE 
		WHEN ISNULL(CP.intIRParentLotNumberPatternId, 0) = 1
			THEN 'By Item'
		ELSE 'None'
		END AS strIRParentLotNoPattern
FROM tblMFCompanyPreference CP
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CP.intDefaultShipmentStagingLocation
LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = CP.intDefaultShipmentDockDoorLocation
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intBondStatusId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intDamagedStatusId
