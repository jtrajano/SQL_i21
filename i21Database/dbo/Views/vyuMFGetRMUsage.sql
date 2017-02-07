﻿CREATE VIEW vyuMFGetRMUsage
AS
SELECT DISTINCT WI.dtmProductionDate [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,PL.strParentLotNumber AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,IL.strLotNumber AS [Pallet Id]
	,IPL.strParentLotNumber AS [Lot #]
	,WI.dblIssuedQuantity AS [Quantity]
	,UM1.strUnitMeasure AS [Quantity UOM]
	,WI.dblQuantity AS [Weight]
	,UM.strUnitMeasure [Weight UOM]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = WI.intWorkOrderId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WI.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICLot IL ON IL.intLotId = WI.intLotId
JOIN dbo.tblICParentLot IPL ON IPL.intParentLotId = IL.intParentLotId
JOIN dbo.tblICItem I1 ON I1.intItemId = IL.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
WHERE C.strCategoryCode Not IN (
		SELECT PA.strAttributeValue
		FROM tblMFManufacturingProcessAttribute PA
		WHERE PA.intManufacturingProcessId = W.intManufacturingProcessId
			AND PA.intLocationId = W.intLocationId
			AND PA.intAttributeId = 46
		)
