CREATE PROCEDURE uspMFGetShiftCount (
	@intLocationId INT
	,@strShiftName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) AS ShiftCount
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND strShiftName LIKE @strShiftName + '%'
END
