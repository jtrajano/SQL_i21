CREATE VIEW vyuLGUnAllocatedContracts
AS
SELECT *
FROM (
	SELECT CD.intContractDetailId
		,CD.intContractSeq
		,CD.intCompanyLocationId
		,CD.dtmStartDate
		,CD.intItemId
		,CD.dtmEndDate
		,CD.intFreightTermId
		,CD.intShipViaId
		,CD.dblQuantity AS dblDetailQuantity
		,CD.dblFutures
		,CD.dblBasis
		,CD.dblCashPrice
		,CD.strBuyerSeller
		,CD.strFobBasis
		,CD.dblBalance
		,CD.dblIntransitQty
		,CD.dblScheduleQty
		,CD.strPackingDescription
		,CD.intPriceItemUOMId
		,CD.intLoadingPortId
		,CD.intDestinationPortId
		,CD.strShippingTerm
		,CD.intShippingLineId
		,CD.strVessel
		,IM.strItemNo
		,IM.strDescription AS strItemDescription
		,U1.strUnitMeasure AS strItemUOM
		,CL.strLocationName
		,CS.strContractStatus
		,(SELECT SUM(dblReservedQuantity) FROM tblLGReservation RES WHERE RES.intContractDetailId = CD.intContractDetailId) AS dblReservedQuantity
		,ISNULL(CD.dblQuantity, 0) - ISNULL((SELECT SUM(dblReservedQuantity) FROM tblLGReservation RES WHERE RES.intContractDetailId = CD.intContractDetailId),0) AS dblUnReservedQuantity
		,ISNULL(CD.dblAllocatedQty, 0) AS dblAllocatedQty
		,ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblAllocatedQty, 0)  AS dblUnAllocatedQty
		,CH.intContractHeaderId
		,CH.intContractTypeId
		,CT.strContractType
		,CH.intCommodityId
		,CY.strCommodityCode
		,CY.strDescription AS strCommodityDescription
		,CH.strContractNumber
		,CH.dtmContractDate
		,CH.strCustomerContract
		,EY.strEntityName
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
	FROM tblCTContractDetail CD
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	JOIN vyuCTEntity EY ON EY.intEntityId =	CH.intEntityId AND EY.strEntityType	= (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	LEFT JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblLGReservation LR ON LR.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGAllocationDetail PAL ON PAL.intPContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGAllocationDetail SAL ON SAL.intSContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICUnitMeasure U5 ON U5.intUnitMeasureId = PAL.intPUnitMeasureId
	LEFT JOIN tblICUnitMeasure U6 ON U6.intUnitMeasureId = SAL.intSUnitMeasureId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	GROUP BY CD.intContractDetailId
		,CD.intContractSeq
		,CD.intCompanyLocationId
		,CD.dtmStartDate
		,CD.intItemId
		,CD.dtmEndDate
		,CD.intFreightTermId
		,CD.intShipViaId
		,CD.dblQuantity
		,CD.dblFutures
		,CD.dblBasis
		,CD.dblCashPrice
		,CD.strBuyerSeller
		,CD.strFobBasis
		,CD.dblBalance
		,CD.dblAllocatedQty
		,CD.dblIntransitQty
		,CD.dblScheduleQty
		,CD.strPackingDescription
		,CD.intPriceItemUOMId
		,CD.intLoadingPortId
		,CD.intDestinationPortId
		,CD.strShippingTerm
		,CD.intShippingLineId
		,CD.strVessel
		,IM.strItemNo
		,IM.strDescription
		,U1.strUnitMeasure
		,CL.strLocationName
		,CS.strContractStatus
		,CH.intContractHeaderId
		,CH.intContractTypeId
		,CT.strContractType
		,CH.intCommodityId
		,CY.strCommodityCode
		,CY.strDescription
		,CH.strContractNumber
		,CH.dtmContractDate
		,CH.strCustomerContract
		,EY.strEntityName
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
	) tbl
WHERE dblUnAllocatedQty > 0