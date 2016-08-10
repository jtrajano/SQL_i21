CREATE VIEW vyuLGContainerReceiptView
AS
SELECT
  strContractNumber	=	CH.strContractNumber,
  intContractSeq	=	CD.intContractSeq ,
  strEntityName		=	E.strName ,
  strItemNo			=	I.strItemNo ,
  strDescription	=	I.strDescription,
  strFutureMonth	=	MO.strFutureMonth ,
  dblBasis			=	dbo.fnRemoveTrailingZeroes (ROUND(CD.dblBasis,2)) ,
  dblFixationPrice	=	dbo.fnRemoveTrailingZeroes (ROUND(CD.dblFutures,2)) ,
  dtmFixationDate	=	(SELECT Top(1) PfixDt.dtmFixationDate FROM tblCTPriceFixationDetail PfixDt JOIN tblCTPriceFixation Pfix ON Pfix.intPriceFixationId = PfixDt.intPriceFixationId AND Pfix.intContractDetailId=CD.intContractDetailId),
  dblFinalPrice		=	dbo.fnRemoveTrailingZeroes (ROUND(CD.dblCashPrice,2)) ,
  strContainerNumber=	Cont.strContainerNumber ,
  strMarks			=	Cont.strMarks ,
  strIntegrationOrderNumber	=	lk.strIntegrationOrderNumber ,
  strSubLocationDescription	=	SL.strSubLocationDescription ,
  intNoOfContainers			=	CASE ISNULL(Lot.dblOrderQty, 0) WHEN 0 THEN 0 ELSE 1 END ,
  dblReceivedQty			=	dbo.fnRemoveTrailingZeroes (ROUND(Lot.dblOrderQty,2) ) ,
  dblReceivedUom			=	Um.strUnitMeasure ,
  dblNet					=	dbo.fnRemoveTrailingZeroes(ROUND(Lot.dblNet, 2)) ,
  dblWeightUom				=	Wm.strUnitMeasure ,
  --strCupRating				=	Result_cup.strPropertyValue,
  dtmReceiptDate			=	Rc.dtmReceiptDate ,
  strRemarks				=	Cont.strComments ,
  strContainerStatus		=	CASE ISNULL(Lot.dblOrderQty, 0) WHEN 0 THEN 'Containers Not Received' ELSE 'Containers  Received' END
FROM tblLGLoadDetailContainerLink lk
JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = lk.intLoadContainerId
JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = lk.intLoadDetailId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = ld.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem AS I ON I.intItemId = CD.intItemId
JOIN tblEMEntity AS E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblICInventoryReceiptItem AS Lot ON Lot.intContainerId = Cont.intLoadContainerId
LEFT JOIN tblICInventoryReceiptItemLot AS Lt ON Lt.intInventoryReceiptItemId = Lot.intInventoryReceiptItemId
LEFT JOIN tblSMCompanyLocationSubLocation AS SL ON SL.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICItemUOM AS Lotuom ON Lotuom.intItemId = Lot.intItemId AND Lotuom.intItemUOMId = Lot.intUnitMeasureId
LEFT JOIN tblICUnitMeasure AS Um ON Um.intUnitMeasureId = Lotuom.intUnitMeasureId
LEFT JOIN tblICItemUOM AS Lotwuom ON Lotwuom.intItemId = Lot.intItemId AND Lotwuom.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure AS Wm ON Wm.intUnitMeasureId = Lotwuom.intUnitMeasureId
LEFT JOIN tblICInventoryReceipt AS Rc ON Rc.intInventoryReceiptId = Lot.intInventoryReceiptId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
