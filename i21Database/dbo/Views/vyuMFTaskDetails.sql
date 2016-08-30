CREATE VIEW vyuMFTaskDetails
AS
SELECT OH.intOrderHeaderId
	  ,OH.strOrderNo
	  ,T.intTaskId
	  ,T.intConcurrencyId
	  ,TT.strTaskType
	  ,TS.strTaskState
	  ,L.strLotNumber
	  ,L.strLotAlias
	  ,I.strItemNo
	  ,I.strDescription AS strItemDescription
	  ,T.intFromStorageLocationId
	  ,FSL.strName AS strFromStorageLocationName
	  ,T.intToStorageLocationId
	  ,TSL.strName AS strToStorageLocationName
	  ,T.dblQty
	  ,IUM.strUnitMeasure AS strQtyUnitMeasure
	  ,T.dblWeight
	  ,WUM.strUnitMeasure AS strWeightUnitMeasure
	  ,TP.strTaskPriority
	  ,T.dtmReleaseDate
	  ,L.dblQty AS dblLotQty
	  ,LIUM.strUnitMeasure AS strLotQtyUOM
	  ,L.dblWeight AS dblLotWeight
	  ,LWUM.strUnitMeasure AS strLotWeightUOM
FROM tblMFOrderHeader OH
JOIN tblMFTask T ON T.intOrderHeaderId = OH.intOrderHeaderId
JOIN tblMFTaskType TT ON TT.intTaskTypeId = T.intTaskTypeId
JOIN tblMFTaskState TS ON TS.intTaskStateId = T.intTaskStateId
JOIN tblMFTaskPriority TP ON TP.intTaskPriorityId = T.intTaskPriorityId
JOIN tblICLot L ON L.intLotId = T.intLotId
JOIN tblICItem I ON I.intItemId = T.intItemId
JOIN tblICStorageLocation FSL ON FSL.intStorageLocationId = T.intFromStorageLocationId
JOIN tblICStorageLocation TSL ON TSL.intStorageLocationId = T.intToStorageLocationId
JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM LIU ON LIU.intItemUOMId = L.intItemUOMId
LEFT JOIN tblICUnitMeasure LIUM ON LIUM.intUnitMeasureId = LIU.intUnitMeasureId
LEFT JOIN tblICItemUOM LWU ON LWU.intItemUOMId = L.intWeightUOMId
LEFT JOIN tblICUnitMeasure LWUM ON LWUM.intUnitMeasureId = LWU.intUnitMeasureId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = T.intWeightUOMId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId