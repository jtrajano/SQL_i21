CREATE PROCEDURE uspMFGetDestinationStorageLocationCount (
	@intProcessId INT
	,@intLocationId INT
	)
AS
BEGIN
	--SELECT SL.intStorageLocationId
	--	,SL.strName
	--FROM dbo.tblMFManufacturingProcess P
	--JOIN dbo.tblMFManufacturingProcessMachineMap PM ON PM.intManufacturingProcessId = P.intManufacturingProcessId
	--JOIN dbo.tblMFFloorMovement FM ON FM.intSourceId = PM.intMachineId
	--	AND FM.ysnAllowed = 1
	--JOIN dbo.tblMFFloorMovementType FMT ON FMT.intFloorMovementTypeId = FM.intDestinationTypeId
	--JOIN dbo.tblMFStationType ST ON ST.intStationTypeId = FM.intStationTypeId
	--JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = FM.intDestinationId
	--WHERE ST.strStationTypeName = 'Storage Location'
	--	AND FMT.strFloorMovementTypeName = 'Storage Location'
	--	AND P.intManufacturingProcessId = @intProcessId
	--	AND PM.intLocationId = @intLocationId
	SELECT Count(*) as StorageLocationCount
	FROM dbo.tblICStorageLocation SL
	WHERE intLocationId = @intLocationId
END