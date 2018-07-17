CREATE PROCEDURE uspMFGetLotLocation @strLotNo NVARCHAR(50)
	,@intCompanyLocationId INT
AS
BEGIN
	DECLARE @intCount INT

	SELECT @intCount = COUNT(*)
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	WHERE L.strLotNumber = @strLotNo
		AND L.dblQty > 0
		AND L.intLocationId = @intCompanyLocationId

	SELECT TOP 1 L.intLotId
		,L.strLotNumber
		,L.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,L.intSubLocationId
		,CSL.strSubLocationName
		,@intCount AS intLotCount
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	WHERE L.strLotNumber = @strLotNo
		AND L.dblQty > 0
		AND L.intLocationId = @intCompanyLocationId
END
