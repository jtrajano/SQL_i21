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
		,(
			(L.dblQty + T.dblPickQty) - ISNULL((
					SELECT SUM(ISNULL(T1.dblQty, 0))
					FROM tblMFTask T1
					WHERE T1.intLotId = T.intLotId
					), 0)
			) AS dblQty
		,T.dblPickQty AS dblTaskQty
		,IUM.strUnitMeasure AS strQtyUOM
		,T.intItemUOMId AS intQtyUOMId
	FROM tblMFTask T
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
	JOIN tblICItem I ON I.intItemId = T.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICLot L ON L.intLotId = T.intLotId
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	WHERE T.intTaskId = @intTaskId
END
