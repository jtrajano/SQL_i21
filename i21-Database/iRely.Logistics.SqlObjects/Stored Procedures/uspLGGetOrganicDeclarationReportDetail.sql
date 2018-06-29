CREATE PROCEDURE uspLGGetOrganicDeclarationReportDetail
	@intLoadId INT
AS
SELECT L.strLoadNumber
	,L.intLoadId
	,LD.intLoadDetailId
	,CD.intContractDetailId
	,CH.strContractNumber AS strSContractNumber
	,CH.strContractNumber + '/' + LTRIM(CD.intContractSeq) AS strSContractNumberSeq
	,CH.intContractHeaderId
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,LD.dblQuantity
	,UM.strUnitMeasure AS strItemUOM
	,LD.dblGross
	,LD.dblNet
	,WUM.strUnitMeasure AS strWeightUOM
	,WUM.strSymbol AS strWeightSymbol
	,'Gross Weight in ' + ISNULL(WUM.strSymbol, '') AS strGrossWeightColumn
	,'Net Weight in ' + ISNULL(WUM.strSymbol, '') AS strNetWeightColumn
	,PCH.strContractNumber AS strPContractNumber
	,PCH.strContractNumber + '/' + LTRIM(PCD.intContractSeq) AS strPContractNumberSeq
	,IRIL.strMarkings AS strMarks
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LDL.intLotId
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = IRI.intLineNo
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = L.intWeightUnitMeasureId
WHERE L.intLoadId = @intLoadId