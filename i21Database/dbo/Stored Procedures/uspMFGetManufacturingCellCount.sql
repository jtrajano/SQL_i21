CREATE PROCEDURE uspMFGetManufacturingCellCount (
	@intCalendarId INT
	,@intLocationId INT
	,@intManufacturingCellId INT = 0
	,@strCellName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) AS intManufacturingCellCount
	FROM dbo.tblMFManufacturingCell M
	WHERE M.intLocationId = @intLocationId
		AND M.ysnActive = 1
		AND M.ysnIncludeSchedule = 1
		AND M.strCellName LIKE @strCellName + '%'
		AND M.intManufacturingCellId = (
			CASE 
				WHEN @intManufacturingCellId > 0
					THEN @intManufacturingCellId
				ELSE M.intManufacturingCellId
				END
			)
END