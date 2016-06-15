CREATE View vyuLGLoadDetailLotsView
AS
SELECT L.strLoadNumber
	  ,L.intLoadId
	  ,LD.intLoadDetailId
	  ,LDL.intLoadDetailLotId
	  ,LDL.intLotId
	  ,LDL.dblLotQuantity
	  ,LDL.intItemUOMId
	  ,LDL.dblGross
	  ,LDL.dblTare
	  ,LDL.dblNet
	  ,LDL.intWeightUOMId
	  ,LDL.strWarehouseCargoNumber
	  ,UM.strUnitMeasure AS strItemUnitMeasure
	  ,WUM.strUnitMeasure AS strWeightUnitMeasure
	  ,LOT.strLotNumber 
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LOT.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICItemUOM WU ON WU.intItemUOMId = LOT.intWeightUOMId
JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId