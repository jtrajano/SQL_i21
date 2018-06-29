CREATE VIEW vyuMFTask
AS
SELECT T.intTaskId
	,OH.intOrderHeaderId
	,OH.strOrderNo
	,OH.dtmOrderDate
	,OH.strReferenceNo
	,OS.strOrderStatus
	,OT.strOrderType
	,SL.strName AS strStagingLocationName
	,OH.strComment
	,TT.strTaskType
	,TS.strTaskState
	,L.strLotNumber
	,PL.strParentLotNumber
	,L.strLotAlias
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,T.dblQty
	,IUM.strUnitMeasure AS strQtyUnitMeasure
	--,T.dblWeight
	--,WUM.strUnitMeasure AS strWeightUnitMeasure
	--,L.dblQty AS dblLotQty
	--,LIUM.strUnitMeasure AS strLotQtyUOM
FROM tblMFTask T
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = T.intOrderHeaderId
JOIN tblMFOrderStatus OS ON OS.intOrderStatusId = OH.intOrderStatusId
JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
JOIN tblICStorageLocation SL ON SL.intStorageLocationId = OH.intStagingLocationId
JOIN tblMFTaskType TT ON TT.intTaskTypeId = T.intTaskTypeId
JOIN tblMFTaskState TS ON TS.intTaskStateId = T.intTaskStateId
JOIN tblICItem I ON I.intItemId = T.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICLot L ON L.intLotId = T.intLotId
JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
--LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = T.intWeightUOMId
--LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
--LEFT JOIN tblICItemUOM LIU ON LIU.intItemUOMId = L.intItemUOMId
--LEFT JOIN tblICUnitMeasure LIUM ON LIUM.intUnitMeasureId = LIU.intUnitMeasureId
