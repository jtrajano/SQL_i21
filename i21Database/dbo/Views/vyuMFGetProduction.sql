CREATE VIEW vyuMFGetProduction
AS
SELECT Rtrim(Convert(CHAR, W.dtmPlannedDate, 101)) AS [Production Date]
	,I.strItemNo AS Item
	,I.strDescription AS Description
	,W.strWorkOrderNo AS [Work Order #]
	,W.strReferenceNo AS [Job #]
	,WP.strParentLotNumber AS [Production Lot]
	,L.strLotNumber [Pallet No]
	,SUM(WP.dblPhysicalCount) AS [Quantity]
	,IUM.strUnitMeasure AS [Quantity UOM]
	,SUM(WP.dblQuantity) AS [Weight]
	,UM.strUnitMeasure AS [Weight UOM]
	,MFC.strCellName AS [Line]
	,W.intWorkOrderId
	,W.dtmPlannedDate
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
	AND W.intStatusId = 13
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MFC ON MFC.intManufacturingCellId = W.intManufacturingCellId
WHERE WP.ysnProductionReversed = 0
GROUP BY W.dtmPlannedDate
	,I.strItemNo
	,I.strDescription
	,W.strWorkOrderNo
	,W.strReferenceNo
	,WP.strParentLotNumber
	,L.strLotNumber
	,IUM.strUnitMeasure
	,UM.strUnitMeasure
	,MFC.strCellName
	,W.intWorkOrderId
