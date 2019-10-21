CREATE VIEW vyuMFWastageNotMapped
AS
SELECT W.intWastageId
	,WT.strWastageTypeName
	,BT.strBinTypeName
	,UOM.strUnitMeasure AS strWeightUnitMeasure
	,GUOM.strUnitMeasure AS strGrossWeightUnitMeasure
	,WO.strWorkOrderNo
	,I.strItemNo
	,I.strDescription
	,SL.strName AS strStorageLocationName
	,L.strLotNumber
FROM tblMFWastage W
JOIN tblMFWastageType WT ON WT.intWastageTypeId = W.intWastageTypeId
JOIN tblMFBinType BT ON BT.intBinTypeId = W.intBinTypeId
LEFT JOIN tblICItem I ON I.intItemId = W.intItemId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = W.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure GUOM ON GUOM.intUnitMeasureId = W.intGrossWeightUnitMeasureId
LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = W.intWorkOrderId
LEFT JOIN tblICLot L ON L.intLotId = W.intLotId
