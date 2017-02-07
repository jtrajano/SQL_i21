CREATE VIEW vyuMFGetOverAndUnderWeight
AS
SELECT W.dtmPlannedDate AS [Production Date]
	,I.strItemNo AS Item
	,I.strDescription AS Description
	,W.strWorkOrderNo AS [Job #]
	,PL.strParentLotNumber AS [Production Lot]
	,SUM(WP.dblPhysicalCount * I.intInnerUnits) AS [Good produced Pouches]
	,IsNULL((
			SELECT SUM(WP.dblPhysicalCount)
			FROM tblMFWorkOrderProducedLot WP
			WHERE WP.intWorkOrderId = W.intWorkOrderId
				AND WP.intItemId <> W.intItemId
			), 0) [Total sweeps]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
WHERE WP.ysnProductionReversed = 0
GROUP BY W.dtmPlannedDate
	,W.intItemId
	,I.strItemNo
	,I.strDescription
	,W.strWorkOrderNo
	,PL.strParentLotNumber
	,W.intWorkOrderId
