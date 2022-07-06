CREATE PROCEDURE uspMFGetLotByStorageUnit @intStorageLocationId INT
	,@intSubLocationId INT
	,@intLocationId INT
AS
BEGIN
	DECLARE @ysnEnableItemMenuOnHandheld BIT

	SELECT TOP 1 @ysnEnableItemMenuOnHandheld = ISNULL(ysnEnableItemMenuOnHandheld, 0) FROM tblMFCompanyPreference

	IF @ysnEnableItemMenuOnHandheld = 1
	BEGIN
		SELECT I.intItemId AS intLotId
			,SL.strName AS strStorageLocationName
			,CSL.strSubLocationName
			,I.strItemNo AS strLotNumber
			,SUOM.dblOnHand AS dblQty
			,SUOM.dblUnitReserved AS dblReservedQty
			,(SUOM.dblOnHand - SUOM.dblUnitReserved) AS dblAvailableQty
			,UOM.strUnitMeasure
			,SUOM.intStorageLocationId
			,SUOM.intSubLocationId
			,'ITEM : ' + I.strItemNo + ' - ' + I.strDescription + '<br />' + 'QTY : ' + dbo.fnRemoveTrailingZeroes(CONVERT(NUMERIC(38, 2), SUOM.dblOnHand)) + ' ' + UOM.strUnitMeasure  + '<br />' + 'RES.QTY : ' + dbo.fnRemoveTrailingZeroes(CONVERT(NUMERIC(38, 2), SUOM.dblUnitReserved)) + ' ' + UOM.strUnitMeasure + '<br />' + 'AVL.QTY : ' + dbo.fnRemoveTrailingZeroes(CONVERT(NUMERIC(38, 2), (SUOM.dblOnHand - SUOM.dblUnitReserved))) + ' ' + UOM.strUnitMeasure AS strLotDetail
		FROM tblICItemStockUOM SUOM
		JOIN tblICItem I ON I.intItemId = SUOM.intItemId
		JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = SUOM.intItemUOMId
		JOIN tblICItemLocation IL ON IL.intItemLocationId = SUOM.intItemLocationId
		JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SUOM.intSubLocationId
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = SUOM.intStorageLocationId
			AND IUOM.ysnStockUnit = 1
			AND SUOM.dblOnHand > 0
			AND IL.intLocationId = @intLocationId
			AND SUOM.intStorageLocationId = @intStorageLocationId
			AND SUOM.intSubLocationId = @intSubLocationId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	END
	ELSE
	BEGIN
		SELECT L.intLotId
			,SL.strName AS strStorageLocationName
			,CSL.strSubLocationName
			,L.strLotNumber
			,L.dblQty
			,U.strUnitMeasure
			,L.intStorageLocationId
			,L.intSubLocationId
			,'ITEM : ' + I.strItemNo + ' - ' + I.strDescription + '<br />' + 'LOT # : ' + L.strLotNumber + '<br />' + 'QTY : ' + dbo.fnRemoveTrailingZeroes(CONVERT(NUMERIC(38, 2), L.dblQty)) + ' ' + U.strUnitMeasure AS strLotDetail
		FROM tblICLot L
		JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
		JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICItem I ON I.intItemId = L.intItemId
			AND L.dblQty > 0
			AND L.dtmExpiryDate > GETDATE()
			AND LS.strPrimaryStatus = 'Active'
			AND L.intLocationId = @intLocationId
			AND L.intStorageLocationId = @intStorageLocationId
			AND L.intSubLocationId = @intSubLocationId
	END
END
