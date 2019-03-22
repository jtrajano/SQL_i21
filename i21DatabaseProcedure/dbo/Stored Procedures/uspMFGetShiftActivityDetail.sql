CREATE PROCEDURE uspMFGetShiftActivityDetail @intShiftActivityId INT
	,@intLocationId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	-- Shift Activity
	SELECT SA.*
		,MC.strCellName
		,S.strShiftName
		,UOM.strUnitMeasure AS strSKUUnitMeasure
		,UOM1.strUnitMeasure AS strWeightUnitMeasure
	FROM tblMFShiftActivity SA
	JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
	JOIN tblMFShift S ON S.intShiftId = SA.intShiftId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SA.intSKUUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = SA.intWeightUnitMeasureId
	WHERE SA.intShiftActivityId = @intShiftActivityId

	-- Downtime
	SELECT DM.intDowntimeMachineId
		,M.intMachineId
		,M.strName
		,RC.intReasonCodeId
		,RC.strReasonCode
		,RC.strDescription
		,RC.ysnExplanationrequired
		,CONVERT(INT, D.intDowntime / 60) AS intDowntime
		,D.strExplanation
		,D.dtmShiftStartTime
		,D.dtmShiftEndTime
		,D.intDowntimeId
		,SA.intShiftActivityId
	FROM dbo.tblMFShiftActivity SA
	JOIN dbo.tblMFDowntime D ON D.intShiftActivityId = SA.intShiftActivityId
	JOIN dbo.tblMFDowntimeMachines DM ON DM.intDowntimeId = D.intDowntimeId
	JOIN dbo.tblMFReasonCode RC ON RC.intReasonCodeId = D.intReasonCodeId
	JOIN dbo.tblMFMachine M ON M.intMachineId = DM.intMachineId
		AND M.intLocationId = @intLocationId
	WHERE SA.intShiftActivityId = @intShiftActivityId
	ORDER BY DM.intDowntimeMachineId DESC

	-- Wastage
	SELECT W.intWastageId
		,W.intShiftActivityId
		,WT.intWastageTypeId
		,WT.strWastageTypeName
		,B.intBinTypeId
		,B.strBinTypeName
		,W.dblGrossWeight
		,B.dblTareWeight
		,W.dblNetWeight
		,W.intWeightUnitMeasureId
		,U.strUnitMeasure
	FROM dbo.tblMFWastage W
	JOIN dbo.tblMFBinType B ON B.intBinTypeId = W.intBinTypeId
	JOIN dbo.tblMFWastageType WT ON WT.intWastageTypeId = W.intWastageTypeId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = W.intWeightUnitMeasureId
	WHERE W.intShiftActivityId = @intShiftActivityId
	ORDER BY W.intWastageId DESC

	-- Wastage Total and Percentage
	SELECT @intShiftActivityId AS intShiftActivityId
		,ISNULL(S.dblTotalWeightofProducedQty, 0) AS dblTotalWeightofProducedQty
		,ISNULL(S.dblTotalSKUProduced, 0) AS dblTotalSKUProduced
		,ISNULL(SUM(WD.dblNetWeight), 0) AS dblTotalNetWeight
		,ISNULL(((SUM(WD.dblNetWeight) * MC.dblWastageFactor) / SUM(WD.dblGrossWeight)), 0) AS dblWastagePercentage
	FROM dbo.tblMFShiftActivity S
	LEFT JOIN dbo.tblMFWastage WD ON WD.intShiftActivityId = S.intShiftActivityId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
	WHERE S.intShiftActivityId = @intShiftActivityId
	GROUP BY S.dblTotalWeightofProducedQty
		,MC.dblWastageFactor
		,S.dblTotalSKUProduced
END
