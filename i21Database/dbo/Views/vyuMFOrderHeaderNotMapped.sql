CREATE VIEW vyuMFOrderHeaderNotMapped
AS
SELECT SW.intOrderHeaderId
	,W.dtmPlannedDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
	,I.strItemNo + ' - ' + I.strDescription AS strItemDescription
	,W.dblQuantity
	,UOM.strUnitMeasure
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblMFStageWorkOrder SW ON SW.intOrderHeaderId = OH.intOrderHeaderId
JOIN tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
JOIN tblICItem I ON I.intItemId = W.intItemId
JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = W.intItemUOMId
JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId

UNION ALL

SELECT OH.intOrderHeaderId
	,S.dtmShipDate AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
	,'' AS strItemDescription
	,NULL AS dblQuantity
	,'' AS strUnitMeasure
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo

UNION ALL

SELECT OH.intOrderHeaderId
	,NULL AS dtmRequiredDate
	,OT.strOrderType
	,OS.strOrderStatus
	,'' AS strItemDescription
	,NULL AS dblQuantity
	,'' AS strUnitMeasure
FROM tblMFOrderHeader OH
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	AND OT.intOrderTypeId = 2
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
