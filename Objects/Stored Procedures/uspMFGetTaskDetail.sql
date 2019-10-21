CREATE PROCEDURE uspMFGetTaskDetail (@intTaskId INT)
AS
BEGIN
	SELECT T.intTaskId
		,I.intItemId
		,I.strItemNo
		,I.strDescription AS strItemDescription
		,L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,PL.strParentLotNumber
		,SL.strName
		,L.dblQty
		,T.dblPickQty AS dblTaskQty
		,IUM.strUnitMeasure AS strQtyUOM
		,T.intItemUOMId AS intQtyUOMId
		,SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)) AS dblReservedQty
		,(L.dblQty - SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0))) AS dblAvailableQty
		,0.0 AS dblReservedWeight -- Not used in client
		,0.0 AS dblAvailableWeight -- Not used in client
		,T.intToStorageLocationId
		,SL1.strName AS strToStorageLocationName
	FROM tblMFTask T
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
	JOIN tblICItem I ON I.intItemId = T.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICLot L ON L.intLotId = T.intLotId
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = T.intToStorageLocationId
	LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
		AND SR.ysnPosted = 0
		AND SR.intTransactionId <> T.intOrderHeaderId
	WHERE T.intTaskId = @intTaskId
	GROUP BY T.intTaskId
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,L.intLotId
		,L.strLotNumber
		,L.strLotAlias
		,PL.strParentLotNumber
		,SL.strName
		,L.dblQty
		,T.dblPickQty
		,IUM.strUnitMeasure
		,T.intItemUOMId
		,T.intToStorageLocationId
		,SL1.strName
END
