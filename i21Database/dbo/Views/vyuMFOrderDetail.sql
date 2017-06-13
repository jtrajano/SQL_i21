CREATE VIEW vyuMFOrderDetail
AS
SELECT OD.intOrderDetailId
,OD.intOrderHeaderId
,OD.intItemId
,OD.dblQty
,OD.intItemUOMId
,OD.dblWeight
,OD.intWeightUOMId
,OD.dblWeightPerQty
,OD.dblRequiredQty
,OD.intLotId
,OD.strLotAlias
,OD.intUnitsPerLayer
,OD.intLayersPerPallet
,OD.intPreferenceId
,OD.dtmProductionDate
,OD.intLineNo
,OD.intSanitizationOrderDetailsId
,OD.strLineItemNote
,OD.intStagingLocationId
,OD.intCreatedById
,OD.dtmCreatedOn
,OD.intLastUpdateById
,OD.dtmLastUpdateOn
,OH.strOrderNo
,I.strItemNo
,IUM.strUnitMeasure AS strItemUOM
,WUM.strUnitMeasure	AS strWeightUOM
,WUM.strUnitMeasure	AS strUOM
,PP.strPickPreference
,PL.strParentLotNumber
,I.strRotationType
FROM tblMFOrderDetail OD
JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OD.intOrderHeaderId
JOIN tblICItem I ON I.intItemId = OD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = OD.intItemUOMId
LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = OD.intWeightUOMId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblMFPickPreference PP ON PP.intPickPreferenceId = OD.intPreferenceId
LEFT JOIN tblICParentLot PL ON PL.intParentLotId = OD.intParentLotId
