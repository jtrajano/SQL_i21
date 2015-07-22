CREATE PROCEDURE uspMFGetContainerByContainerType (
	@intLocationId INT
	,@strContainerType NVARCHAR(MAX)
	,@strContainerId NVARCHAR(50) = '%'
	,@intContainerId int=0
	)
AS
BEGIN
	SELECT C.intContainerId
		,C.strContainerId
	FROM dbo.tblICContainer C
	JOIN dbo.tblICStorageLocation L ON L.intStorageLocationId = C.intStorageLocationId
	JOIN dbo.tblICContainerType CT ON CT.intContainerTypeId = C.intContainerTypeId
	WHERE L.intLocationId = @intLocationId
		AND CT.strDisplayMember IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strContainerType, ',')
			)
		AND C.strContainerId LIKE @strContainerId + '%'
		AND C.intContainerId =(CASE WHEN @intContainerId >0 THEN @intContainerId ELSE C.intContainerId END)
	ORDER BY C.strContainerId
END
