CREATE PROCEDURE uspWHGetDefaultKitStagingLocation @intLocationId INT
AS
BEGIN
	DECLARE @intKitStagingLocationId INT
		,@intManufacturingProcessId INT
		,@intProductionStagingId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFManufacturingProcess
	WHERE intAttributeTypeId = 2

	SELECT @intKitStagingLocationId = pa.strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Kit Staging Location'

	IF @intKitStagingLocationId IS NULL
	BEGIN
		SELECT @intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFManufacturingProcess
		WHERE intAttributeTypeId = 3

		SELECT @intProductionStagingId = intAttributeId
		FROM tblMFAttribute
		WHERE strAttributeName = 'Production Staging Location'

		SELECT @intKitStagingLocationId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intProductionStagingId
	END

	SELECT intStorageLocationId
		,strName AS strStorageLocationName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intKitStagingLocationId
END
