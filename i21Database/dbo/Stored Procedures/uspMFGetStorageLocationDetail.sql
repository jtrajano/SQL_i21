CREATE PROCEDURE uspMFGetStorageLocationDetail @strStorageLocation NVARCHAR(50)
	,@intLocationId INT
AS
BEGIN
	SELECT TOP 1 SL.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,SL.intSubLocationId
		,COUNT(SL.intStorageLocationId) OVER () AS intStorageLocationCount
	FROM tblICStorageLocation SL
	WHERE SL.intLocationId = @intLocationId
		AND SL.strName = @strStorageLocation
END
