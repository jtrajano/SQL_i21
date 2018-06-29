CREATE PROCEDURE uspMFGetCalendarShift (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCalendarId INT
	,@intLocationId INT
	,@strShiftName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT S.intShiftId
		,S.strShiftName
		,CONVERT(BIT, CASE 
				WHEN EXISTS (
						SELECT *
						FROM tblMFScheduleCalendarDetail CD
						WHERE CD.intShiftId = S.intShiftId
							AND dtmCalendarDate BETWEEN @dtmFromDate
								AND @dtmToDate
							AND CD.intCalendarId = @intCalendarId
						)
					THEN 1
				ELSE 0
				END) AS ysnSelect
	FROM dbo.tblMFShift S
	WHERE S.intLocationId = @intLocationId
	AND S.strShiftName LIKE @strShiftName + '%'
	ORDER BY S.intShiftSequence
END
