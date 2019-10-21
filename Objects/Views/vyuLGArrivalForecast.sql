CREATE VIEW vyuLGArrivalForecast
AS
SELECT E.strName AS strVendor
       ,CH.strContractNumber
       ,I.strItemNo
       ,I.strDescription
       ,LD.dblNet
       ,WM.strUnitMeasure AS strWeightUOM
       ,LD.dblQuantity
       ,U.strUnitMeasure AS strQtyUOM
	   ,L.strMVessel
	   ,L.strMVoyageNumber
	   ,L.strFVessel
	   ,L.strFVoyageNumber
       ,L.dtmETAPOD
FROM tblLGLoad L
INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
INNER JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
INNER JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
INNER JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
INNER JOIN tblICUnitMeasure WM ON WM.intUnitMeasureId = WU.intUnitMeasureId
WHERE L.dtmETAPOD BETWEEN GETDATE()
              AND (GETDATE() + 42) 
			  AND L.intShipmentType = 1