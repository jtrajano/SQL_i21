CREATE VIEW vyuMFGetOverAndUnderWeight
AS
SELECT Convert(CHAR, W.dtmPlannedDate, 101) AS [Production Date]
	,I.strItemNo AS Item
	,I.strDescription AS Description
	,W.strWorkOrderNo AS [Job #]
	,PL.strParentLotNumber AS [Production Lot]
	,IsNULL(SUM(WP.dblPhysicalCount * I.intInnerUnits), 0) AS [Good produced Pouches]
	,IsNULL((
			SELECT SUM(Convert(DECIMAL(24, 10), TR.strPropertyValue))
			FROM dbo.tblQMTestResult TR
			JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			WHERE P.strPropertyName = 'Number of bags that pass'
				AND TR.intProductTypeId = 12
				AND TR.intProductValueId = W.intWorkOrderId
				AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Total Pouches passed through counter]
	,IsNULL((
			SELECT SUM(Convert(DECIMAL(24, 10), TR.strPropertyValue))
			FROM dbo.tblQMTestResult TR
			JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			WHERE P.strPropertyName = 'Record underweight units'
				AND TR.intProductTypeId = 12
				AND TR.intProductValueId = W.intWorkOrderId
				AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Underweight Pouches]
	,IsNULL((
			SELECT SUM(Convert(DECIMAL(24, 10), TR.strPropertyValue))
			FROM dbo.tblQMTestResult TR
			JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			WHERE P.strPropertyName = 'Record over-weight units'
				AND TR.intProductTypeId = 12
				AND TR.intProductValueId = W.intWorkOrderId
				AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Overweight Pouches]
	,IsNULL((
			SELECT SUM(WP.dblPhysicalCount)
			FROM tblMFWorkOrderProducedLot WP
			WHERE WP.intWorkOrderId = W.intWorkOrderId
				AND WP.intItemId <> W.intItemId
			), 0) [Total sweeps (lb)]
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId
	AND W.intStatusId = 13
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
