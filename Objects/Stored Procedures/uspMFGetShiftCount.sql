CREATE PROCEDURE uspMFGetShiftCount (
	@intLocationId INT
	,@strShiftName NVARCHAR(50) = '%'
	,@intShiftId int=0
	)
AS
BEGIN
	SELECT Count(*) AS ShiftCount
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND strShiftName LIKE @strShiftName + '%'
		AND intShiftId =(Case When @intShiftId >0 then @intShiftId else intShiftId end)
END
