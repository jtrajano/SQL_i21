CREATE PROCEDURE uspMFGetManufacturingCellCountByPackType (
	@intLocationId INT
	,@intPackTypeId INT
	,@intManufacturingCellId INT = 0
	,@strCellName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) AS ManufacturingCellCount
	FROM dbo.tblMFManufacturingCell MC
	JOIN dbo.tblMFManufacturingCellPackType MCP ON MCP.intManufacturingCellId = MC.intManufacturingCellId
	WHERE intLocationId = @intLocationId
		AND ysnActive = 1
		AND ysnIncludeSchedule = 1
		AND intPackTypeId = @intPackTypeId
		AND MC.strCellName LIKE @strCellName + '%'
		AND MC.intManufacturingCellId = (
			CASE 
				WHEN @intManufacturingCellId > 0
					THEN @intManufacturingCellId
				ELSE MC.intManufacturingCellId
				END
			)
END