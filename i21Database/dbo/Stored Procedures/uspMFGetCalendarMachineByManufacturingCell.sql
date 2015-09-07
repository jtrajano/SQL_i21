CREATE PROCEDURE uspMFGetCalendarMachineByManufacturingCell (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCalendarId INT
	,@intManufacturingCellId INT
	,@intLocationId INT
	,@strName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT M.intMachineId
		,M.strName
		,CONVERT(BIT, CASE 
				WHEN EXISTS (
						SELECT *
						FROM tblMFScheduleCalendarDetail CD
						JOIN tblMFScheduleCalendarMachineDetail MD ON MD.intCalendarDetailId = CD.intCalendarDetailId
						WHERE MD.intMachineId = M.intMachineId
							AND dtmCalendarDate BETWEEN @dtmFromDate
								AND @dtmToDate
							AND CD.intCalendarId = @intCalendarId
						)
					THEN 1
				ELSE 0
				END) AS ysnSelect
	FROM tblMFMachine M
	JOIN tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
	JOIN tblMFManufacturingCellPackType LP ON LP.intPackTypeId = MP.intPackTypeId
		AND LP.intManufacturingCellId = @intManufacturingCellId
	WHERE M.intLocationId = @intLocationId
	AND M.strName LIKE @strName + '%'
	ORDER BY M.strName
END
