CREATE PROCEDURE uspMFGetSourceStorageLocationCount (
	@intProcessId INT
	,@intLocationId INT
	,@strName nvarchar(50)='%'
	)
AS
BEGIN
	--SELECT SL.intStorageLocationId
	--	,SL.strName
	--FROM dbo.tblMFManufacturingProcess P
	--JOIN dbo.tblMFManufacturingProcessMachineMap PM ON PM.intManufacturingProcessId = P.intManufacturingProcessId
	--JOIN dbo.tblMFFloorMovement FM ON FM.intDestinationId = PM.intMachineId
	--	AND FM.ysnAllowed = 1
	--JOIN dbo.tblMFFloorMovementType FMT ON FMT.intFloorMovementTypeId = FM.intDestinationTypeId
	--JOIN dbo.tblMFStationType ST ON ST.intStationTypeId = FM.intStationTypeId
	--JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = FM.intSourceId
	--WHERE ST.strStationTypeName = 'Storage Location'
	--	AND FMT.strFloorMovementTypeName = 'Machine'
	--	AND P.intManufacturingProcessId = @intProcessId
	--	AND PM.intLocationId = @intLocationId
	SELECT Count(*) As StorageLocationCount
	FROM dbo.tblICStorageLocation SL
	WHERE intLocationId = @intLocationId 
	and SL.ysnAllowConsume =1
	AND SL.strName LIKE @strName+'%'
END