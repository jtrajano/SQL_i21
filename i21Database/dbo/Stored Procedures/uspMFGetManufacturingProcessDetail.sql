CREATE PROCEDURE uspMFGetManufacturingProcessDetail (@strProcessName NVARCHAR(50))
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@CurrentDate DATETIME
		,@CurrentTime DATETIME
		,@intShiftId INT

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation

	SELECT @CurrentDate = Convert(CHAR, Getdate(), 101)

	SELECT @CurrentTime = Convert(CHAR, Getdate(), 108)

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intCompanyLocationId
		AND @CurrentTime BETWEEN dtmShiftStartTime
			AND dtmShiftEndTime + intEndOffset

	SELECT intManufacturingProcessId
		,strProcessName
		,strDescription
		,@intCompanyLocationId AS intCompanyLocationId
		,@strLocationName AS strLocationName
		,@CurrentDate AS dtmBusinessDate
		,@intShiftId AS intRunningShift
	FROM dbo.tblMFManufacturingProcess
	WHERE strProcessName = @strProcessName
END