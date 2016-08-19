CREATE VIEW vyuMFShiftActivityProductionSummaryWithWastage
AS
SELECT SA.intShiftActivityId
	,MC.intLocationId
	,MC.strCellName
	,SA.dtmShiftDate
	,S.strShiftName
	,SA.dtmShiftStartTime
	,SA.dtmShiftEndTime
	,ISNULL((SA.intScheduledRuntime / 60), 0) AS intTotalRuntime
	,(
		SELECT COUNT(DISTINCT SAM.intMachineId)
		FROM dbo.tblMFShiftActivityMachines SAM
		WHERE SAM.intShiftActivityId = SA.intShiftActivityId
		) AS intNoOfMachines
	,ISNULL((SA.intTotalDowntime / 60), 0) AS intTotalDowntime
	,SA.intReduceAvailableTime
	,ISNULL(SA.dblTotalSKUProduced, 0) AS dblTotalSKUProduced
	,UOM.strUnitMeasure
	,SA.dblTotalProducedQty AS dblTotalProducedQty
	,ISNULL(((SA.intScheduledRuntime / 60) * SA.dblStdCapacity), 0) AS dblTargetQty
	,SA.dblTargetEfficiency
	,CASE -- Setting NULL then only average exclude the count
		WHEN ((((ISNULL(SA.intScheduledRuntime, 0) - ISNULL((SA.intReduceAvailableTime * 60), 0)) / 60) * ISNULL(SA.dblStdCapacity, 0))) = 0
			THEN NULL
		ELSE CASE 
				WHEN (ROUND((ISNULL(SA.dblTotalProducedQty, 0) / (((ISNULL(SA.intScheduledRuntime, 0) - ISNULL((SA.intReduceAvailableTime * 60), 0)) / 60) * ISNULL(SA.dblStdCapacity, 0))) * 100, 4)) = 0
					THEN NULL
				ELSE ROUND((ISNULL(SA.dblTotalProducedQty, 0) / (((ISNULL(SA.intScheduledRuntime, 0) - ISNULL((SA.intReduceAvailableTime * 60), 0)) / 60) * ISNULL(SA.dblStdCapacity, 0))) * 100, 4)
				END
		END AS dblEfficiencyPercentage
	,CASE -- Setting NULL then only average exclude the count
		WHEN ((ISNULL(SA.intScheduledRuntime, 0) / 60) * ISNULL(SA.dblStdCapacity, 0)) = 0
			THEN NULL
		ELSE CASE 
				WHEN (ROUND((ISNULL(SA.dblTotalProducedQty, 0) / ((ISNULL(SA.intScheduledRuntime, 0) / 60) * ISNULL(SA.dblStdCapacity, 0))) * 100, 4)) = 0
					THEN NULL
				ELSE ROUND((ISNULL(SA.dblTotalProducedQty, 0) / ((ISNULL(SA.intScheduledRuntime, 0) / 60) * ISNULL(SA.dblStdCapacity, 0))) * 100, 4)
				END
		END AS dblEfficiencyWithOutDowntimePercentage
	,ROUND(ISNULL((WT.dblTotalNetWeight * MC.dblWastageCost), 0), 2) AS dblTotalWasteCost
	,ISNULL(WT.dblTotalNetWeight, 0) AS dblTotalWasteWeight
	,ISNULL(SA.dblTotalSKUProduced, 0) AS dblTotalCasesProduced
	,ROUND((WT.dblTotalNetWeight * MC.dblWastageFactor) / CASE 
			WHEN ISNULL(SA.dblTotalWeightofProducedQty, 0) = 0
				THEN 1
			ELSE SA.dblTotalWeightofProducedQty
			END, 4) AS dblWastePercentage
	,ROUND(ISNULL((WT1.dblTotalNetWeight * MC.dblWastageCost), 0), 2) AS dblTotalReClaimCost
	,ISNULL(WT1.dblTotalNetWeight, 0) AS dblTotalReClaimWeight
	,ROUND((WT1.dblTotalNetWeight * MC.dblWastageFactor) / CASE 
			WHEN ISNULL(SA.dblTotalWeightofProducedQty, 0) = 0
				THEN 1
			ELSE SA.dblTotalWeightofProducedQty
			END, 4) AS dblReClaimPercentage
FROM dbo.tblMFShiftActivity SA
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
	AND SA.intShiftActivityStatusId = 3
JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId
LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SA.intSKUUnitMeasureId
LEFT JOIN dbo.vyuMFShiftActivityWastageTotal WT ON WT.intShiftActivityId = SA.intShiftActivityId
	AND WT.intWastageTypeId = 2 -- Waste
LEFT JOIN dbo.vyuMFShiftActivityWastageTotal WT1 ON WT1.intShiftActivityId = SA.intShiftActivityId
	AND WT1.intWastageTypeId = 1 -- ReClaim
