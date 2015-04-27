CREATE PROCEDURE uspMFGetShift (@intLocationId INT)
AS
BEGIN
	DECLARE @CurrentDate DATETIME

	SELECT @CurrentDate = Convert(CHAR, Getdate(), 101)

	SELECT intShiftId
		,strShiftName
		,CASE 
			WHEN Getdate() BETWEEN @CurrentDate+dtmShiftStartTime+intStartOffset
					AND @CurrentDate+dtmShiftEndTime + intEndOffset
				THEN 1
			ELSE 0
			END AS intRunningShift
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
END