CREATE PROCEDURE uspMFGetManufacturingProcessDetail (@strProcessName NVARCHAR(50))
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@CurrentDate DATETIME
		,@intShiftId INT

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation

	SELECT @CurrentDate = Convert(CHAR, Getdate(), 101)

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intCompanyLocationId
		AND Getdate() BETWEEN @CurrentDate+dtmShiftStartTime+intStartOffset
					AND @CurrentDate+dtmShiftEndTime + intEndOffset

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