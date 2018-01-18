CREATE VIEW vyuLGLoadStorageCostLots
AS
SELECT L.intLoadId,
	   L.strLoadNumber,
	   LD.intLoadDetailId,
	   CH.strContractNumber,
	   CD.intContractSeq,
	   CD.dtmUpdatedAvailabilityDate,
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
	   CT.strItemNo AS strCostType

FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
JOIN tblICItem I ON I.intItemId = LOT.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LOT.intItemUOMId
JOIN tblICUnitMeasure IUM ON IU.intUnitMeasureId = IUM.intUnitMeasureId
JOIN tblICItemUOM WU ON WU.intItemUOMId = LOT.intWeightUOMId
JOIN tblICUnitMeasure WUM ON WU.intUnitMeasureId = WUM.intUnitMeasureId
LEFT JOIN tblLGLoadStorageCost LSC ON LSC.intLoadId = L.intLoadId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LSC.intCurrency
LEFT JOIN vyuCTCostType CT ON CT.intItemId = LSC.intCostType