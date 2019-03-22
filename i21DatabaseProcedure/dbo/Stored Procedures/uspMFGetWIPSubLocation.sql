CREATE PROCEDURE uspMFGetWIPSubLocation (
	@intLocationId INT
	,@strSubLocationName NVARCHAR(50) = '%'
	,@intSubLocationId INT = 0
	,@intManufacturingProcessId INT = 0
	)
AS
BEGIN
	SELECT Distinct SL.intCompanyLocationSubLocationId
		,SL.intCompanyLocationId
		,SL.strSubLocationName
		,SL.strSubLocationDescription
		,SL.strClassification
		,SL.intConcurrencyId
	FROM dbo.tblSMCompanyLocationSubLocation SL
	JOIN tblMFMachine M ON M.intSubLocationId = SL.intCompanyLocationSubLocationId
	JOIN tblMFManufacturingProcessMachine PM ON PM.intMachineId = M.intMachineId
	WHERE SL.intCompanyLocationId = @intLocationId
		AND SL.strSubLocationName LIKE @strSubLocationName + '%'
		AND SL.intCompanyLocationSubLocationId = (
			CASE 
				WHEN @intSubLocationId > 0
					THEN @intSubLocationId
				ELSE SL.intCompanyLocationSubLocationId
				END
			)
		AND PM.intManufacturingProcessId = (
			CASE 
				WHEN @intManufacturingProcessId > 0
					THEN @intManufacturingProcessId
				ELSE PM.intManufacturingProcessId
				END
			) and SL.strClassification='WIP'
	ORDER BY SL.strSubLocationName
END