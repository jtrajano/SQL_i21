CREATE PROCEDURE uspMFGetManufacturingProcessDetail (@strProcessName NVARCHAR(50)='')
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@CurrentDate DATETIME
		,@intShiftId INT

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation

	SELECT @CurrentDate = dbo.fnGetBusinessDate(Getdate(),@intCompanyLocationId) 

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intCompanyLocationId
		AND Getdate() BETWEEN @CurrentDate+dtmShiftStartTime+intStartOffset
					AND @CurrentDate+dtmShiftEndTime + intEndOffset

	If @strProcessName=''
	Begin
		SELECT 0 As intManufacturingProcessId
			,'' strProcessName
			,'' strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@CurrentDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,GetDate() as dtmCurrentDate
	End
	Else
	Begin
		SELECT intManufacturingProcessId
			,strProcessName
			,strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@CurrentDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,GetDate() as dtmCurrentDate
		FROM dbo.tblMFManufacturingProcess
		WHERE strProcessName = @strProcessName
	End
END