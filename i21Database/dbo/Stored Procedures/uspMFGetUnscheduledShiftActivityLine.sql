CREATE PROCEDURE uspMFGetUnscheduledShiftActivityLine
	@dtmShiftDate DATETIME
	,@intShiftId INT
	,@intLocationId INT
	,@strCellName NVARCHAR(50) = ''
	,@intManufacturingCellId INT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT DISTINCT MC.intManufacturingCellId
		,MC.strCellName
		,MC.strDescription
		,@dtmShiftDate AS dtmShiftDate
		,@intShiftId AS intShiftId
		,SH.dtmShiftStartTime
		,SH.dtmShiftEndTime
		,1 AS intShiftActivityStatusId
	FROM dbo.tblMFManufacturingCell MC
	JOIN dbo.tblMFShift SH ON SH.intLocationId = MC.intLocationId
	WHERE MC.intLocationId = @intLocationId
		AND SH.intShiftId = @intShiftId
		AND MC.ysnActive = 1
		AND MC.ysnIncludeEfficiency = 1
		AND MC.ysnIncludeSchedule = 0
		AND MC.intManufacturingCellId NOT IN (
			SELECT DISTINCT (SA.intManufacturingCellId)
			FROM dbo.tblMFShiftActivity SA
			JOIN dbo.tblMFManufacturingCell MC1 ON MC1.intManufacturingCellId = SA.intManufacturingCellId
			WHERE SA.intShiftActivityStatusId IN (
					2
					,3
					)
				AND CONVERT(DATETIME, CONVERT(CHAR, SA.dtmShiftDate, 101)) = CONVERT(DATETIME, CONVERT(CHAR, @dtmShiftDate, 101))
				AND SA.intShiftId = @intShiftId
				AND MC1.intLocationId = @intLocationId
			)
		AND MC.strCellName LIKE '%' + @strCellName + '%'
		AND MC.intManufacturingCellId = (
			CASE 
				WHEN @intManufacturingCellId > 0
					THEN @intManufacturingCellId
				ELSE MC.intManufacturingCellId
				END
			)
	ORDER BY MC.strCellName
END
