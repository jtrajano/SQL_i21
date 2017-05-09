CREATE PROCEDURE uspMFGetManufacturingProcessDetail (@strProcessName NVARCHAR(50)='',@intLocationId int)
AS
BEGIN
	DECLARE @intCompanyLocationId INT
		,@strLocationName NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@intShiftId INT
		,@strShiftName NVARCHAR(50)
		,@dtmCurrentDate DateTime
		,@intEndOffset int
		,@dtmShiftEndTime DateTime

	Select @dtmCurrentDate=Getdate()

	SELECT @intCompanyLocationId = intCompanyLocationId
			,@strLocationName = strLocationName
	FROM dbo.tblSMCompanyLocation
	WHERE intCompanyLocationId=@intLocationId

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate,@intCompanyLocationId) 

	SELECT @intShiftId = intShiftId,@strShiftName=strShiftName,@intEndOffset=intEndOffset,@dtmShiftEndTime=dtmShiftEndTime
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
			,@strShiftName AS strShiftName
			,@intEndOffset as intEndOffset
			,@dtmShiftEndTime as dtmShiftEndTime
			,@dtmCurrentDate as dtmCurrentDate
			,0 as intMachineId
			,'' as strMachineName
			,0 as intSubLocationId
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
			,@strShiftName AS strShiftName
			,@intEndOffset as intEndOffset
			,@dtmShiftEndTime as dtmShiftEndTime
			,@dtmCurrentDate as dtmCurrentDate
			,ISNULL(M.intMachineId,0) as intMachineId
			,ISNULL(M.strName,'') as strMachineName
			,ISNULL(M.intSubLocationId,0) AS intSubLocationId
		FROM dbo.tblMFManufacturingProcess P
		Left JOIN tblMFManufacturingProcessMachine PM on P.intManufacturingProcessId=PM.intManufacturingProcessId and PM.ysnDefault=1
		Left JOIN tblMFMachine M on M.intMachineId=PM.intMachineId
		WHERE strProcessName = @strProcessName
	End
END