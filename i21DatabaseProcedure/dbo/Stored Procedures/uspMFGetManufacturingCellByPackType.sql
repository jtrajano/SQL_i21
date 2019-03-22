CREATE PROCEDURE uspMFGetManufacturingCellByPackType (
	@intLocationId INT
	,@intPackTypeId INT
	,@intManufacturingCellId INT = 0
	,@strCellName NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT MC.intManufacturingCellId
		,MC.strCellName
		,MC.strDescription
		,MC.intSubLocationId
		,CL.strSubLocationName
		,CL.strSubLocationDescription
		,CL.strClassification
	FROM dbo.tblMFManufacturingCell MC
	JOIN dbo.tblMFManufacturingCellPackType MCP ON MCP.intManufacturingCellId = MC.intManufacturingCellId
	JOIN dbo.tblSMCompanyLocationSubLocation CL ON CL.intCompanyLocationSubLocationId = MC.intSubLocationId
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
	ORDER BY MC.strCellName
END