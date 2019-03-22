CREATE PROCEDURE uspMFGetLotByItem @intItemId INT
	,@intLocationId INT
AS
BEGIN
	SELECT L.intLotId
		,SL.strName AS strStorageLocationName
		,CSL.strSubLocationName
		,L.strLotNumber
		,L.dblQty
		,U.strUnitMeasure
		,L.intStorageLocationId
		,L.intSubLocationId
		,'LOC : ' + CSL.strSubLocationName + '<br />' + 'UNIT : ' + SL.strName + '<br />' + 'LOT # : ' + L.strLotNumber + '<br />' + 'QTY : ' + dbo.fnRemoveTrailingZeroes(CONVERT(NUMERIC(38, 2), L.dblQty)) + ' ' + U.strUnitMeasure AS strLotDetail
	FROM tblICLot L
	JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		AND L.dblQty > 0
		AND L.dtmExpiryDate > GETDATE()
		AND LS.strPrimaryStatus = 'Active'
		AND L.intLocationId = @intLocationId
		AND L.intItemId = @intItemId
END
