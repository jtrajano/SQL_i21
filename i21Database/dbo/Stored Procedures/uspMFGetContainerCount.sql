CREATE PROCEDURE uspMFGetContainerCount (
	@intLocationId INT
	,@intContainerTypeId INT
	)
AS
BEGIN
	SELECT Count(*) AS ContainerCount
	FROM dbo.tblICContainer C
	JOIN dbo.tblICStorageLocation L ON L.intStorageLocationId = C.intStorageLocationId
	WHERE C.intContainerTypeId = @intContainerTypeId
		AND L.intLocationId = @intLocationId
END