CREATE PROCEDURE uspMFGetLotLocationDetail @strLotNo NVARCHAR(50)
	,@strStorageLocation NVARCHAR(50)
	,@intLocationId INT
AS
BEGIN
	SELECT TOP 1 L.intLotId
		,L.strLotNumber
		,L.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,L.intSubLocationId
		,CSL.strSubLocationName
		,COUNT(L.intLotId) OVER () AS intLotCount
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
		AND L.strLotNumber = @strLotNo
		AND L.dblQty > 0
		AND L.intLocationId = @intLocationId
		AND SL.strName = @strStorageLocation
END
