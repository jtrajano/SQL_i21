CREATE VIEW vyuMFGetPMUsage
AS
SELECT DISTINCT Convert(CHAR, W.dtmPlannedDate, 101) [Dump Date]
	,I.strItemNo [Product]
	,I.strDescription [Product Description]
	,(
		SELECT TOP 1 strParentLotNumber
		FROM dbo.tblMFWorkOrderProducedLot WP
		WHERE WP.intWorkOrderId = W.intWorkOrderId
		) AS [Production Lot]
	,MC.strCellName AS Line
	,W.strWorkOrderNo AS [Job #]
	,I1.strItemNo AS [WSI Item]
	,I1.strDescription [WSI Item Description]
	,SUM(WC.dblIssuedQuantity) + SUM(IsNULL(WC1.dblIssuedQuantity, 0)) AS [Total Consumed Quantity]
	,SUM(WC.dblIssuedQuantity) AS [Used in Packaging]
	,UM1.strUnitMeasure AS [UOM]
	,SUM(IsNULL(WC1.dblIssuedQuantity, 0)) AS [Damaged]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderId = W.intWorkOrderId
	AND intSequenceNo <> 9999
	AND W.intStatusId = 13
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = WC.intItemIssuedUOMId
JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICItem I1 ON I1.intItemId = WC.intItemId
JOIN dbo.tblICCategory C ON C.intCategoryId = I1.intCategoryId
LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC1 ON WC1.intWorkOrderId = W.intWorkOrderId
	AND WC1.intSequenceNo = 9999
	AND WC1.intItemId = WC.intItemId
WHERE C.strCategoryCode IN (
		SELECT PA.strAttributeValue
		FROM tblMFManufacturingProcessAttribute PA
		WHERE PA.intManufacturingProcessId = W.intManufacturingProcessId
			AND PA.intLocationId = W.intLocationId
			AND PA.intAttributeId = 46
		)
GROUP BY W.dtmPlannedDate
	,I.strItemNo
	,I.strDescription
	,MC.strCellName
	,W.strWorkOrderNo
	,I1.strItemNo
	,I1.strDescription
	,UM1.strUnitMeasure
	,W.intWorkOrderId
	,WC.intItemId
