CREATE PROCEDURE uspMFGetContainerCount (
	@intLocationId INT
	,@intContainerTypeId INT
	,@strContainerId NVARCHAR(50) = '%'
	,@intContainerId int=0
	)
AS
BEGIN
	SELECT Count(*) AS ContainerCount
	FROM dbo.tblICContainer C
	JOIN dbo.tblICStorageLocation L ON L.intStorageLocationId = C.intStorageLocationId
	WHERE C.intContainerTypeId = @intContainerTypeId
		AND L.intLocationId = @intLocationId
		AND C.strContainerId LIKE @strContainerId + '%'
	AND C.intContainerId =(CASE WHEN @intContainerId >0 THEN @intContainerId ELSE C.intContainerId END)
END