CREATE VIEW vyuLGContainerReceiptView
AS
SELECT strContractNumber,
  intContractSeq ,
  strEntityName,
  strItemNo,
  strDescription,
  strFutureMonth,
  dblBasis ,
  dblFixationPrice,
  dtmFixationDate,
  dblFinalPrice,
  strContainerNumber,
  strMarks,
  strIntegrationOrderNumber,
  strSubLocationDescription,
  intNoOfContainers,
  dblReceivedQty,
  dblReceivedUom,
  dblNet,
  dblWeightUom,
  min(strCupRating) strCupRating,
  dtmReceiptDate,
  strRemarks,
  strContainerStatus
  FROM
  (
 SELECT
  strContractNumber	=	CH.strContractNumber,
  intContractSeq	=	CD.intContractSeq ,
  strEntityName		=	E.strName ,
  strItemNo			=	I.strItemNo ,
  strDescription	=	I.strDescription,
  strFutureMonth	=	MO.strFutureMonth ,
  dblBasis			=	dbo.fnRemoveTrailingZeroes (ROUND(CD.dblBasis,2)) ,
  dblFixationPrice	=	dbo.fnRemoveTrailingZeroes (ROUND(PfixDt.dblFixationPrice,2)) ,
  dtmFixationDate	=	PfixDt.dtmFixationDate ,
  dblFinalPrice		=	dbo.fnRemoveTrailingZeroes (ROUND(PfixDt.dblFinalPrice,2)) ,
  strContainerNumber=	Cont.strContainerNumber ,
  strMarks			=	Cont.strMarks ,
  strIntegrationOrderNumber	=	lk.strIntegrationOrderNumber ,
  strSubLocationDescription	=	SL.strSubLocationDescription ,
  intNoOfContainers			=	CASE ISNULL(Lot.dblOrderQty, 0) WHEN 0 THEN 0 ELSE 1 END ,
  dblReceivedQty			=	dbo.fnRemoveTrailingZeroes (ROUND(Lot.dblOrderQty,2) ) ,
  dblReceivedUom			=	Um.strUnitMeasure ,
  dblNet					=	dbo.fnRemoveTrailingZeroes(ROUND(Lot.dblNet, 2)) ,
  dblWeightUom				=	Wm.strUnitMeasure ,
  strCupRating				=	Result_cup.strPropertyValue ,
  dtmReceiptDate			=	Rc.dtmReceiptDate ,
  strRemarks				=	Cont.strComments ,
  strContainerStatus		=	CASE ISNULL(Lot.dblOrderQty, 0) WHEN 0 THEN 'Containers Not Received' ELSE 'Containers  Received' END
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
INNER JOIN tblICItem AS I ON I.intItemId = CD.intItemId
LEFT JOIN tblEMEntity AS E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblCTPriceFixation AS Pfix ON Pfix.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblCTPriceFixationDetail AS PfixDt ON PfixDt.intPriceFixationId = Pfix.intPriceFixationId
LEFT JOIN tblLGLoadDetail ld ON ld.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblLGLoadDetailContainerLink lk ON lk.intLoadDetailId = ld.intLoadDetailId
LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = lk.intLoadContainerId
LEFT JOIN tblICInventoryReceiptItem AS Lot ON Lot.intContainerId = Cont.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse lw ON lw.intLoadId = ld.intLoadId
LEFT JOIN tblQMReportCuppingPropertyMapping AS Property_cup_map ON UPPER(Property_cup_map.strPropertyName) = 'OVERALL CUP ANALYSIS'
LEFT JOIN tblQMProperty AS Property_cup ON UPPER(Property_cup.strPropertyName) = UPPER(Property_cup_map.strActualPropertyName)
LEFT JOIN vyuQMCuppingTestResult AS Result_cup ON Result_cup.intPropertyId = Property_cup.intPropertyId
JOIN tblQMSample AS smp ON smp.intSampleId = Result_cup.intSampleId AND smp.intLoadContainerId = Cont.intLoadContainerId
LEFT JOIN tblQMSampleStatus st ON st.strStatus = 'Approved' AND st.intSampleStatusId = smp.intSampleStatusId
LEFT JOIN tblSMCompanyLocationSubLocation AS SL ON SL.intCompanyLocationSubLocationId = lw.intSubLocationId
LEFT JOIN tblICItemUOM AS Lotuom ON Lotuom.intItemId = Lot.intItemId AND Lotuom.intItemUOMId = Lot.intUnitMeasureId
LEFT JOIN tblICUnitMeasure AS Um ON Um.intUnitMeasureId = Lotuom.intUnitMeasureId
LEFT JOIN tblICItemUOM AS Lotwuom ON Lotwuom.intItemId = Lot.intItemId AND Lotwuom.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure AS Wm ON Wm.intUnitMeasureId = Lotwuom.intUnitMeasureId
LEFT JOIN tblICInventoryReceipt AS Rc ON Rc.intInventoryReceiptId = Lot.intInventoryReceiptId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblICInventoryReceiptItemLot AS Lt ON Lt.intInventoryReceiptItemId = Lot.intInventoryReceiptItemId
) rec
group by strContractNumber,intContractSeq ,strEntityName,strItemNo,strDescription,strFutureMonth,
dblBasis,dblFixationPrice,dtmFixationDate,dblFinalPrice,strContainerNumber,strMarks,strIntegrationOrderNumber,strSubLocationDescription,intNoOfContainers,
dblReceivedQty,dblReceivedUom,dblNet,dblWeightUom,dtmReceiptDate,strRemarks,strContainerStatus
