CREATE VIEW vyuMFShiftActivityWastage
AS
SELECT CONVERT(INT,ROW_NUMBER() OVER (
		ORDER BY intLocationId
			,dtmShiftDate
			,strCellName
			,strShiftName
			,strWastageTypeName
		)) AS intRowNo
	,dtmShiftDate
	,strShiftActivityNumber
	,strShiftName
	,strCellName
	,dblTotalWeightofProducedQty
	,dblTotalSKUProduced
	,ISNULL(SUM(dblNetWeight), 0) AS dblTotalNetWeight
	,ISNULL(SUM(dblNetWeight * dblWastageCost), 0) AS dblTotalWastageCost
	,ROUND(ISNULL(SUM((dblNetWeight * dblWastageFactor) / CASE 
					WHEN ISNULL(dblTotalWeightofProducedQty, 0) = 0
						THEN 1
					ELSE dblTotalWeightofProducedQty
					END), 0), 2) AS dblWastagePercent
	,strWastageTypeName
	,intLocationId
FROM (
	SELECT DISTINCT SA.dtmShiftDate
		,SA.strShiftActivityNumber
		,SH.strShiftName
		,MC.strCellName
		,ISNULL(SA.dblTotalWeightofProducedQty, 0) AS dblTotalWeightofProducedQty
		,ISNULL(WD.dblNetWeight, 0) AS dblNetWeight
		,ISNULL(SA.dblTotalSKUProduced, 0) AS dblTotalSKUProduced
		,ISNULL(WT.strWastageTypeName, '') AS strWastageTypeName
		,ISNULL(MC.dblWastageFactor, 0) AS dblWastageFactor
		,ISNULL(MC.dblWastageCost, 0) AS dblWastageCost
		,MC.intLocationId
	FROM dbo.tblMFWastage WD
	JOIN dbo.tblMFShiftActivity SA ON SA.intShiftActivityId = WD.intShiftActivityId
	JOIN dbo.tblMFWastageType WT ON WT.intWastageTypeId = WD.intWastageTypeId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
		AND SA.intShiftActivityStatusId = 3
		AND SA.dblTotalWeightofProducedQty > 0
	JOIN dbo.tblMFWorkOrderProducedLot wpq ON wpq.intShiftActivityId = SA.intShiftActivityId -- To get only the allocated shifts
	JOIN dbo.tblMFShift SH ON SH.intShiftId = SA.intShiftId
	) t
GROUP BY dtmShiftDate
	,strShiftActivityNumber
	,strCellName
	,strShiftName
	,dblTotalSKUProduced
	,dblTotalWeightofProducedQty
	,strWastageTypeName
	,intLocationId
