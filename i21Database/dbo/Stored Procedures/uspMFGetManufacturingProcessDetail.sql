CREATE PROCEDURE uspMFGetManufacturingProcessDetail (@strProcessName NVARCHAR(50)='')
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@intShiftId INT
		,@dtmCurrentDate DateTime
		,@intEndOffset int
		,@dtmShiftEndTime DateTime

	Select @dtmCurrentDate=Getdate()

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate,@intCompanyLocationId) 

	SELECT @intShiftId = intShiftId,@intEndOffset=intEndOffset,@dtmShiftEndTime=dtmShiftEndTime
	FROM dbo.tblMFShift
	WHERE intLocationId = @intCompanyLocationId
		AND @dtmCurrentDate BETWEEN @dtmBusinessDate+dtmShiftStartTime+intStartOffset
					AND @dtmBusinessDate+dtmShiftEndTime + intEndOffset

	If @strProcessName=''
	Begin
		SELECT 0 As intManufacturingProcessId
			,'' strProcessName
			,'' strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@dtmBusinessDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,@intEndOffset as intEndOffset
			,@dtmShiftEndTime as dtmShiftEndTime
			,@dtmCurrentDate as dtmCurrentDate
			,0 as intMachineId
			,'' as strMachineName
	End
	Else
	Begin
		SELECT P.intManufacturingProcessId
			,P.strProcessName
			,P.strDescription
			,@intCompanyLocationId AS intCompanyLocationId
			,@strLocationName AS strLocationName
			,@dtmBusinessDate AS dtmBusinessDate
			,@intShiftId AS intRunningShift
			,@intEndOffset as intEndOffset
			,@dtmShiftEndTime as dtmShiftEndTime
			,@dtmCurrentDate as dtmCurrentDate
			,ISNULL(M.intMachineId,0) as intMachineId
			,ISNULL(M.strName,'') as strMachineName
		FROM dbo.tblMFManufacturingProcess P
		Left JOIN tblMFManufacturingProcessMachine PM on P.intManufacturingProcessId=PM.intManufacturingProcessId and PM.ysnDefault=1
		Left JOIN tblMFMachine M on M.intMachineId=PM.intMachineId
		WHERE strProcessName = @strProcessName
	End
END