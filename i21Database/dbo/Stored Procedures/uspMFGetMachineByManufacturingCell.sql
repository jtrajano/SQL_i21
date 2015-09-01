CREATE PROCEDURE uspMFGetMachineByManufacturingCell (
	@intManufacturingCellId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT M.intMachineId
		,M.strName
	FROM tblMFMachine M
	JOIN tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
	JOIN tblMFManufacturingCellPackType LP ON LP.intPackTypeId = MP.intPackTypeId
		AND LP.intManufacturingCellId = @intManufacturingCellId
	WHERE M.intLocationId = @intLocationId
	ORDER BY M.strName
END