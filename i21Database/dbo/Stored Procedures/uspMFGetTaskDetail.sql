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
		,ISNULL((
				SELECT SUM(ISNULL(T1.dblQty, 0))
				FROM tblMFTask T1
				WHERE T1.intLotId = T.intLotId
					AND T1.intTaskId <> T.intTaskId
				), 0) AS dblReservedQty
		,(
			(L.dblQty) - ISNULL((
					SELECT SUM(ISNULL(T1.dblQty, 0))
					FROM tblMFTask T1
					WHERE T1.intLotId = T.intLotId
						AND T1.intTaskId <> T.intTaskId
					), 0)
			) AS dblAvailableQty
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
	WHERE T.intTaskId = @intTaskId
END
