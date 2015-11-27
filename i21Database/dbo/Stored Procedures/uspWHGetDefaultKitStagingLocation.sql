CREATE PROCEDURE uspWHGetDefaultKitStagingLocation 
				@intLocationId INT
AS
BEGIN
	DECLARE @intKitStagingLocationId INT
	DECLARE @intManufacturingProcessId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFManufacturingProcess
	WHERE intAttributeTypeId = 2

	SELECT @intKitStagingLocationId = pa.strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Kit Staging Location'

	SELECT intStorageLocationId, strName AS strStorageLocationName
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intKitStagingLocationId
END