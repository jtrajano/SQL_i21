﻿CREATE VIEW vyuLGLoadStorageCostView
AS
SELECT L.intLoadId,
	   L.strLoadNumber,
	   LD.intLoadDetailId,
	   LDL.intLoadDetailLotId,
	   LOT.intLotId,
	   LOT.strLotNumber,
	   LOT.dblQty,
	   LOT.dblWeight,
	   LDL.dblLotQuantity,
	   LDL.dblNet,
	   I.intItemId,
	   I.strItemNo,
	   I.strDescription,
	   IU.intItemUOMId AS intItemUOMId,
	   IUM.strUnitMeasure AS strQtyUOM,
	   WU.intItemUOMId AS intWeightUOMId,
	   WUM.strUnitMeasure AS strWeightUnitMeasure,
	   LSC.intLoadStorageCostId,
	   C.strCurrency,
	   LSC.intCurrency,
	   LSC.dblPrice,
	   LSC.dblAmount,
	   LSC.intPriceUOMId,
	   UM.strUnitMeasure AS strUOM,
	   LSC.intCostType,
	   CT.strItemNo AS strCostType
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
JOIN tblICItem I ON I.intItemId = LOT.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LOT.intItemUOMId
JOIN tblICUnitMeasure IUM ON IU.intUnitMeasureId = IUM.intUnitMeasureId
JOIN tblICItemUOM WU ON WU.intItemUOMId = LOT.intWeightUOMId
JOIN tblICUnitMeasure WUM ON WU.intUnitMeasureId = WUM.intUnitMeasureId
JOIN tblLGLoadStorageCost LSC ON LSC.intLoadId = L.intLoadId
LEFT JOIN tblICItemUOM PIU ON PIU.intItemUOMId = LSC.intPriceUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = PIU.intUnitMeasureId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LSC.intCurrency
LEFT JOIN vyuCTCostType CT ON CT.intItemId = LSC.intCostType