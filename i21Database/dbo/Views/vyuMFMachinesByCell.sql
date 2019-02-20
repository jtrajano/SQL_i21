CREATE VIEW vyuMFMachinesByCell
AS
SELECT DISTINCT M.intMachineId
	,M.strName
	,C.intManufacturingCellId
FROM tblMFMachine M
JOIN tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
JOIN tblMFManufacturingCellPackType CP ON CP.intPackTypeId = MP.intPackTypeId
JOIN tblMFManufacturingCell C ON C.intManufacturingCellId = CP.intManufacturingCellId
