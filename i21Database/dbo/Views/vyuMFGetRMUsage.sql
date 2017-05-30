CREATE VIEW vyuMFGetRMUsage
AS
SELECT DISTINCT Convert(CHAR, WI.dtmProductionDate, 101) [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,PL.strParentLotNumber AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,IL.strLotNumber AS [Pallet Id]
	,IPL.strParentLotNumber AS [Lot #]
	,WI.dblQuantity / IsNULL((
			SELECT TOP 1 L1.dblWeightPerQty
			FROM tblICLot L1
			WHERE L1.strLotNumber = IL.strLotNumber
				AND L1.dblWeightPerQty > 1
			), 1) AS [Quantity in Unit]
	,WI.dblQuantity AS [Weight]
	,UM.strUnitMeasure [Weight UOM]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
	AND WI.ysnConsumptionReversed = 0
	AND W.intStatusId = 13
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = WI.intWorkOrderId
	AND WP.ysnProductionReversed = 0
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICLot IL ON IL.intLotId = WI.intLotId
JOIN dbo.tblICParentLot IPL ON IPL.intParentLotId = IL.intParentLotId
JOIN dbo.tblICItem I1 ON I1.intItemId = IL.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
WHERE C.strCategoryCode NOT IN (
		SELECT PA.strAttributeValue
		FROM tblMFManufacturingProcessAttribute PA
		WHERE PA.intManufacturingProcessId = W.intManufacturingProcessId
			AND PA.intLocationId = W.intLocationId
			AND PA.intAttributeId = 46
		)
