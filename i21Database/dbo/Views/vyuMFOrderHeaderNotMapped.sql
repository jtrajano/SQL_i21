CREATE VIEW vyuMFOrderHeaderNotMapped
AS
SELECT SW.intOrderHeaderId
	,W.dtmPlannedDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
	,(
		CASE 
			WHEN ISNULL(E.strEntityNo, '') = ''
				THEN ''
			ELSE E.strEntityNo + ' - ' + E.strName
			END
		) AS strCustomer
	,S1.strName AS strStagingLocationName
	,S2.strName AS strDockDoorLocationName
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
LEFT JOIN tblEMEntity E ON E.intEntityId = W.intCustomerId
LEFT JOIN tblICStorageLocation S1 ON S1.intStorageLocationId = OH.intStagingLocationId
LEFT JOIN tblICStorageLocation S2 ON S2.intStorageLocationId = OH.intDockDoorLocationId

UNION ALL

SELECT OH.intOrderHeaderId
	,S.dtmShipDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
	,(
		CASE 
			WHEN ISNULL(E.strEntityNo, '') = ''
				THEN ''
			ELSE E.strEntityNo + ' - ' + E.strName
			END
		) AS strCustomer
	,S1.strName AS strStagingLocationName
	,S2.strName AS strDockDoorLocationName
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityCustomerId
LEFT JOIN tblICStorageLocation S1 ON S1.intStorageLocationId = OH.intStagingLocationId
LEFT JOIN tblICStorageLocation S2 ON S2.intStorageLocationId = OH.intDockDoorLocationId
