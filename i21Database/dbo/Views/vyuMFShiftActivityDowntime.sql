CREATE VIEW vyuMFShiftActivityDowntime
AS
SELECT DM.intDowntimeMachineId
	,SA.strShiftActivityNumber
	,MC.strCellName
	,SA.dtmShiftDate
	,S.strShiftName
	,M.strName
	,RC.strReasonCode
	,RC.strDescription
	,D.strExplanation
	,(D.intDowntime / 60) AS intDownTime
	,MC.intLocationId
FROM dbo.tblMFDowntime D
JOIN dbo.tblMFDowntimeMachines DM ON DM.intDowntimeId = D.intDowntimeId
JOIN dbo.tblMFReasonCode RC ON RC.intReasonCodeId = D.intReasonCodeId
JOIN dbo.tblMFMachine M ON M.intMachineId = DM.intMachineId
JOIN dbo.tblMFShiftActivity SA ON SA.intShiftActivityId = D.intShiftActivityId
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = SA.intManufacturingCellId
JOIN dbo.tblMFShift S ON S.intShiftId = SA.intShiftId
