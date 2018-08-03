CREATE PROCEDURE uspMFGetManufacturingProcessDetail (
	@strProcessName NVARCHAR(50) = ''
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@intShiftId INT
		,@strShiftName NVARCHAR(50)
		,@dtmCurrentDate DATETIME
		,@intEndOffset INT
		,@dtmShiftEndTime DATETIME
		,@ysnWorkOrderPlannedDateByBusinessDate BIT

	SELECT @ysnWorkOrderPlannedDateByBusinessDate = ysnWorkOrderPlannedDateByBusinessDate
	FROM tblMFCompanyPreference

	SELECT @dtmCurrentDate = Getdate()

	SELECT @intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intCompanyLocationId)

	SELECT @intShiftId = intShiftId
		,@strShiftName = strShiftName
		,@intEndOffset = intEndOffset
		,@dtmShiftEndTime = dtmShiftEndTime
	FROM dbo.tblMFShift
	WHERE intLocationId = @intCompanyLocationId
		AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intShiftId IS NULL
	BEGIN
		SELECT @intShiftId = intShiftId
			,@strShiftName = strShiftName
			,@intEndOffset = intEndOffset
			,@dtmShiftEndTime = dtmShiftEndTime
		FROM dbo.tblMFShift
		WHERE intLocationId = @intCompanyLocationId
			AND intShiftSequence = 1
	END

	IF @strProcessName = ''
	BEGIN
		SELECT 0 AS intManufacturingProcessId
			,'' strProcessName
			,'' strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@dtmBusinessDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,@strShiftName AS strShiftName
			,@intEndOffset AS intEndOffset
			,@dtmShiftEndTime AS dtmShiftEndTime
			,@dtmCurrentDate AS dtmCurrentDate
			,0 AS intMachineId
			,'' AS strMachineName
			,0 AS intSubLocationId
			,CASE 
				WHEN @ysnWorkOrderPlannedDateByBusinessDate = 1
					THEN @dtmBusinessDate
				ELSE Convert(NVARCHAR, Convert(DATETIME, @dtmCurrentDate, 101), 101)
				END AS dtmPlannedDate
	END
	ELSE
	BEGIN
		SELECT P.intManufacturingProcessId
			,P.strProcessName
			,P.strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@dtmBusinessDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,@strShiftName AS strShiftName
			,@intEndOffset AS intEndOffset
			,@dtmShiftEndTime AS dtmShiftEndTime
			,@dtmCurrentDate AS dtmCurrentDate
			,ISNULL(M.intMachineId, 0) AS intMachineId
			,ISNULL(M.strName, '') AS strMachineName
			,ISNULL(M.intSubLocationId, 0) AS intSubLocationId
			,CASE 
				WHEN @ysnWorkOrderPlannedDateByBusinessDate = 1
					THEN @dtmBusinessDate
				ELSE Convert(NVARCHAR, Convert(DATETIME, @dtmCurrentDate, 101), 101)
				END AS dtmPlannedDate
		FROM dbo.tblMFManufacturingProcess P
		LEFT JOIN tblMFManufacturingProcessMachine PM ON P.intManufacturingProcessId = PM.intManufacturingProcessId
			AND PM.ysnDefault = 1
		LEFT JOIN tblMFMachine M ON M.intMachineId = PM.intMachineId
		WHERE strProcessName = @strProcessName
	END
END
