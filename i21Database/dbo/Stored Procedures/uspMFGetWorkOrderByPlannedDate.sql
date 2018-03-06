CREATE PROCEDURE dbo.uspMFGetWorkOrderByPlannedDate @dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
	,@intWorkOrderId INT = 0
	,@strWorkOrderNo NVARCHAR(50) = '%'
AS
BEGIN
	SELECT @dtmStartDate = convert(DATETIME, Convert(CHAR, @dtmStartDate, 101))

	SELECT @dtmEndDate = convert(DATETIME, Convert(CHAR, @dtmEndDate, 101)) + 1

	IF EXISTS (
			SELECT *
			FROM tblMFSchedule
			WHERE ysnStandard = 1
			)
	BEGIN
		SELECT W.intWorkOrderId
			,W.strWorkOrderNo
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND S.ysnStandard = 1
			AND S.intLocationId = @intLocationId
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
			AND W.intStatusId <> 13
		WHERE (
				(
					SW.dtmPlannedStartDate >= @dtmStartDate
					AND SW.dtmPlannedEndDate <= @dtmEndDate
					)
				OR (
					@dtmStartDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					)
				)
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
			AND W.strWorkOrderNo LIKE @strWorkOrderNo + '%'
			AND W.intWorkOrderId = (
				CASE 
					WHEN @intWorkOrderId > 0
						THEN @intWorkOrderId
					ELSE W.intWorkOrderId
					END
				)
	END
	ELSE
	BEGIN
		SELECT W.intWorkOrderId
			,W.strWorkOrderNo
		FROM tblMFWorkOrder W
		WHERE W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
			AND W.dtmPlannedDate >= @dtmStartDate
			AND W.dtmPlannedDate <= @dtmEndDate
			AND W.strWorkOrderNo LIKE @strWorkOrderNo + '%'
			AND W.intWorkOrderId = (
				CASE 
					WHEN @intWorkOrderId > 0
						THEN @intWorkOrderId
					ELSE W.intWorkOrderId
					END
				)
	END
END
