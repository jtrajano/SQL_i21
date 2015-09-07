CREATE PROCEDURE uspMFGetCalendarMachineCountByManufacturingCell (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCalendarId INT
	,@intManufacturingCellId INT
	,@intLocationId INT
	,@strName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) AS intMachineCount
	FROM dbo.tblMFMachine M
	JOIN dbo.tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
	JOIN dbo.tblMFManufacturingCellPackType LP ON LP.intPackTypeId = MP.intPackTypeId
		AND LP.intManufacturingCellId = @intManufacturingCellId
	WHERE M.intLocationId = @intLocationId
		AND M.strName LIKE @strName + '%'
END
