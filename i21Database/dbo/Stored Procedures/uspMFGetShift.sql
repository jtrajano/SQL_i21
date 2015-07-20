﻿CREATE PROCEDURE uspMFGetShift (@intLocationId INT,@strShiftName nvarchar(50)='%',@intShiftId int=0)
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
	AND strShiftName  LIKE @strShiftName+'%'
	AND intShiftId =(Case When @intShiftId >0 then @intShiftId else intShiftId end)
	Order by intShiftId
END