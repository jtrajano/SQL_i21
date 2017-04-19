CREATE VIEW vyuMFGetMachinesByCell
AS
SELECT DISTINCT PM.intManufacturingProcessMachineId
	,PM.intManufacturingProcessId
	,PM.intMachineId
	,M.strName AS strMachineName
	,MPT1.intManufacturingCellId
	,PM.intLocationId
FROM dbo.tblMFManufacturingProcessMachine AS PM
JOIN dbo.tblMFMachine AS M ON PM.intMachineId = M.intMachineId
JOIN dbo.tblMFMachinePackType MPT ON MPT.intMachineId = M.intMachineId
JOIN dbo.tblMFManufacturingCellPackType MPT1 ON MPT1.intPackTypeId = MPT.intPackTypeId
