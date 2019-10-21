﻿CREATE VIEW vyuMFGetRMUsageByLot
AS
SELECT [Dump Date]
	,[Product]
	,[Product Description]
	,[Production Lot]
	,Line
	,[Work Order #]
	,[Job #]
	,[WSI Item]
	,[WSI Item Description]
	,[Lot #]
	,Ceiling(SUM([Quantity] / dblWeightPerQty)) AS Quantity
	,ISNULL(UM1.strUnitMeasure, [Weight UOM]) [Quantity UOM]
	,SUM([Weight]) AS Weight
	,[Weight UOM]
	,intWorkOrderId
	,dtmPlannedDate
FROM (
	SELECT Rtrim(Convert(CHAR, W.dtmPlannedDate, 101)) COLLATE Latin1_General_CI_AS AS [Dump Date]
		,I.strItemNo [Product]
		,I.strDescription [Product Description]
		,(
			SELECT TOP 1 strParentLotNumber
			FROM dbo.tblMFWorkOrderProducedLot WP
			WHERE WP.intWorkOrderId = W.intWorkOrderId
				AND WP.intShiftId = WI.intShiftId
			) AS [Production Lot]
		,MC.strCellName AS Line
		,W.strWorkOrderNo AS [Work Order #]
		,W.strReferenceNo AS [Job #]
		,I1.strItemNo AS [WSI Item]
		,I1.strDescription [WSI Item Description]
		,IPL.strParentLotNumber AS [Lot #]
		,(WI.dblIssuedQuantity) AS [Quantity]
		,(WI.dblQuantity) AS [Weight]
		,UM.strUnitMeasure [Weight UOM]
		,IsNULL((
				SELECT TOP 1 L1.dblWeightPerQty
				FROM tblICLot L1
				WHERE L1.strLotNumber = IL.strLotNumber
					AND L1.dblWeightPerQty > 1
				), 1) AS dblWeightPerQty
		,(
			SELECT TOP 1 L1.intItemUOMId
			FROM tblICLot L1
			WHERE L1.strLotNumber = IL.strLotNumber
				AND L1.dblWeightPerQty > 1
			) AS intItemUOMId
		,W.intWorkOrderId
		,W.dtmPlannedDate
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intWorkOrderId = W.intWorkOrderId
		AND WI.ysnConsumptionReversed = 0
		AND W.intStatusId = 13
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WI.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN dbo.tblICLot IL ON IL.intLotId = WI.intLotId
	JOIN dbo.tblICParentLot IPL ON IPL.intParentLotId = IL.intParentLotId
	JOIN dbo.tblICItem I1 ON I1.intItemId = IL.intItemId
	WHERE I1.intCategoryId NOT IN (
			SELECT PA.strAttributeValue
			FROM tblMFManufacturingProcessAttribute PA
			WHERE PA.intManufacturingProcessId = W.intManufacturingProcessId
				AND PA.intLocationId = W.intLocationId
				AND PA.intAttributeId = 46
			)
	) AS DT
LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = DT.intItemUOMId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
GROUP BY [Dump Date]
	,[Product]
	,[Product Description]
	,[Production Lot]
	,Line
	,[Work Order #]
	,[Job #]
	,[WSI Item]
	,[WSI Item Description]
	,[Lot #]
	,UM1.strUnitMeasure
	,[Weight UOM]
	,intWorkOrderId
	,dtmPlannedDate
