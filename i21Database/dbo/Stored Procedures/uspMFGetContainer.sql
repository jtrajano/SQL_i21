CREATE PROCEDURE uspMFGetContainer (
	@intLocationId INT
	,@intContainerTypeId INT
	,@strContainerId NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT C.intContainerId
		,C.strContainerId
	FROM dbo.tblICContainer C
	JOIN dbo.tblICStorageLocation L ON L.intStorageLocationId = C.intStorageLocationId
	WHERE C.intContainerTypeId = @intContainerTypeId
		AND L.intLocationId = @intLocationId
		AND C.strContainerId LIKE @strContainerId + '%'
END
