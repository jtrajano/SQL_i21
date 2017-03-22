CREATE VIEW vyuMFGetWorkOrderSummaryView
AS
SELECT W.strWorkOrderNo
	,W.dtmOrderDate
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,Max(W.dblQuantity) AS dblPlannedQty
	,UM.strUnitMeasure AS strTargetUnitMeasure
	,W.dtmPlannedDate
	,PS.strShiftName AS strPlannedShiftName
	,WS.strName AS strStatusName
	,MC.strCellName
	,MP.strProcessName
	,W.strComment
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,PL.strParentLotNumber
	,SUM(WI.dblQuantity) AS dblQuantity
	,IUM.strUnitMeasure
	,0 AS strAttain
	,Convert(DECIMAL(18, 2), (
			CASE 
				WHEN Max(dblProducedQuantity) > 0
					THEN (MAX(W.dblProducedQuantity) * I.dblWeight) / (
							CASE 
								WHEN (
										SELECT SUM(dblConsumedQuantity+(dblYieldQuantity*-1))
										FROM tblMFProductionSummary PS
										JOIN dbo.tblICItem II1 ON II1.intItemId = PS.intItemId
										JOIN dbo.tblICCategory C1 ON C1.intCategoryId = II1.intCategoryId
										WHERE PS.intWorkOrderId = W.intWorkOrderId
											AND C1.strCategoryCode NOT IN (
												SELECT TOP 1 strAttributeValue
												FROM tblMFManufacturingProcessAttribute
												WHERE intAttributeId = 46
													AND strAttributeValue <> ''
												)
										) = 0
									THEN 1
								ELSE (
										SELECT SUM(dblConsumedQuantity+(dblYieldQuantity*-1))
										FROM tblMFProductionSummary PS
										JOIN dbo.tblICItem II1 ON II1.intItemId = PS.intItemId
										JOIN dbo.tblICCategory C1 ON C1.intCategoryId = II1.intCategoryId
										WHERE PS.intWorkOrderId = W.intWorkOrderId
											AND C1.strCategoryCode NOT IN (
												SELECT TOP 1 strAttributeValue
												FROM tblMFManufacturingProcessAttribute
												WHERE intAttributeId = 46
													AND strAttributeValue <> ''
												)
										)
								END
							)
				ELSE 0
				END
			) * 100) AS dblYield
	,'CONSUME' AS strTransactionName
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderConsumedLot WI ON WI.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
JOIN dbo.tblICItem II ON II.intItemId = WI.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = II.intCategoryId
JOIN dbo.tblICLot L ON L.intLotId = WI.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WI.intItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
WHERE C.strCategoryCode NOT IN (
		SELECT TOP 1 strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intAttributeId = 46
			AND strAttributeValue <> ''
		)
GROUP BY W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmOrderDate
	,I.strType
	,I.strItemNo
	,I.strDescription
	,I.strShortName
	,UM.strUnitMeasure
	,WS.strName
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.strShiftName
	,MP.strProcessName
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName
	,IUM.strUnitMeasure
	,W.strComment
	,PL.strParentLotNumber
	,I.dblWeight

UNION

SELECT DISTINCT W.strWorkOrderNo
	,ISNULL(W.dtmOrderDate, W.dtmCreated) AS dtmOrderDate
	,I.strType AS strTargetItemType
	,I.strItemNo AS strTargetItemNo
	,I.strDescription AS strTargetItemDesc
	,I.strShortName AS strTargetItemShortDesc
	,Max(W.dblQuantity)
	,UM.strUnitMeasure
	,W.dtmPlannedDate
	,PS.strShiftName AS strPlannedShiftName
	,WS.strName AS strStatusName
	,MC.strCellName
	,MP.strProcessName
	,W.strComment
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName AS strShortDesc
	,WP.strParentLotNumber
	,SUM(WP.dblPhysicalCount)
	,IUM.strUnitMeasure
	,Convert(DECIMAL(18, 2), (
			CASE 
				WHEN Max(W.dblQuantity) > 0
					AND MAX(W.dblProducedQuantity) > 0
					AND MAX(W.dblProducedQuantity) / Max(W.dblQuantity) < 2
					THEN (1 - (Abs(Max(W.dblQuantity) - MAX(W.dblProducedQuantity)) / Max(W.dblQuantity)))
				ELSE 0
				END * 100
			)) AS strAttain
	,0 AS dblYield
	,'PRODUCE' AS strTransactionName
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
JOIN dbo.tblICItem II ON II.intItemId = WP.intItemId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
JOIN dbo.tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN dbo.tblMFShift PS ON PS.intShiftId = W.intPlannedShiftId
WHERE WP.ysnProductionReversed = 0
GROUP BY W.strWorkOrderNo
	,ISNULL(W.dtmOrderDate, W.dtmCreated)
	,I.strType
	,I.strItemNo
	,I.strDescription
	,I.strShortName
	,UM.strUnitMeasure
	,WS.strName
	,MC.strCellName
	,W.dtmPlannedDate
	,PS.strShiftName
	,MP.strProcessName
	,II.strType
	,II.strItemNo
	,II.strDescription
	,II.strShortName
	,IUM.strUnitMeasure
	,W.strComment
	,WP.strParentLotNumber

