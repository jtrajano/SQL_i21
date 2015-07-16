CREATE PROCEDURE uspMFGetContainerCountByContainerType (
	@intLocationId INT
	,@strContainerType NVARCHAR(MAX)
	,@strContainerId NVARCHAR(50) = '%'
	)
AS
BEGIN
	SELECT Count(*) As ContainerCount
	FROM dbo.tblICContainer C
	JOIN dbo.tblICStorageLocation L ON L.intStorageLocationId = C.intStorageLocationId
	JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
	WHERE L.intLocationId = @intLocationId
		AND CT.strDisplayMember IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strContainerType, ',')
			)
		AND C.strContainerId LIKE @strContainerId + '%'
END