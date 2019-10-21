CREATE VIEW vyuMFDowntimeMachines
AS
SELECT DM.intDowntimeMachineId
	,D.intDowntimeId
	,D.intShiftActivityId
	,M.strName
	,RC.strReasonCode
	,RC.strDescription
	,CONVERT(INT, D.intDowntime / 60) AS intDowntime
	,D.strExplanation
FROM tblMFDowntime D
JOIN tblMFDowntimeMachines DM ON DM.intDowntimeId = D.intDowntimeId
JOIN tblMFReasonCode RC ON RC.intReasonCodeId = D.intReasonCodeId
JOIN tblMFMachine M ON M.intMachineId = DM.intMachineId
