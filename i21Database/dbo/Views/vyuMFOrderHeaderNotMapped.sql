CREATE VIEW vyuMFOrderHeaderNotMapped
AS
SELECT SW.intOrderHeaderId
	,W.dtmPlannedDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId

UNION ALL

SELECT OH.intOrderHeaderId
	,S.dtmShipDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
