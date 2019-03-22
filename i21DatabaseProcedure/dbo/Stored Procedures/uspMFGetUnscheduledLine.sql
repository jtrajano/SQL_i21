CREATE PROCEDURE uspMFGetUnscheduledLine (
	@dtmShiftDate DATETIME
	,@intShiftId INT
	,@intLocationId INT
	,@strCellName NVARCHAR(50) = '%'
	,@intManufacturingCellId INT = 0
	)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	SELECT DISTINCT (MC.intManufacturingCellId)
		,MC.strCellName
		,MC.strDescription
	FROM tblMFManufacturingCell MC
	WHERE MC.intLocationId = @intLocationId
		AND MC.ysnActive = 1
		AND MC.ysnIncludeEfficiency = 1
		AND NOT EXISTS (
			SELECT *
			FROM tblMFShiftActivity SA
			WHERE CONVERT(CHAR, SA.dtmShiftDate, 101) = CONVERT(CHAR, @dtmShiftDate, 101)
				AND SA.intShiftId = @intShiftId
				AND SA.intManufacturingCellId = MC.intManufacturingCellId
			)
		AND MC.strCellName LIKE @strCellName + '%'
		AND MC.intManufacturingCellId = (
			CASE 
				WHEN @intManufacturingCellId > 0
					THEN @intManufacturingCellId
				ELSE MC.intManufacturingCellId
				END
			)
	ORDER BY MC.strCellName
END
