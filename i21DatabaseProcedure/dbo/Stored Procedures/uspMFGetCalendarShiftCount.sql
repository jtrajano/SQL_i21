CREATE PROCEDURE uspMFGetCalendarShiftCount (
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCalendarId INT
	,@intLocationId INT
	,@strShiftName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) AS intShiftCount
	FROM dbo.tblMFShift S
	WHERE S.intLocationId = @intLocationId
		AND S.strShiftName LIKE @strShiftName + '%'
END
