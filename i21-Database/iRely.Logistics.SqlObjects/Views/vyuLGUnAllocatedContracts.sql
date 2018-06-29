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
		,CD.dblNetWeight
		,WUM.strUnitMeasure AS strWeightUOM
		,CD.dblQuantity AS dblDetailQuantity
		,U1.strUnitMeasure AS strItemUOM
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
		,CL.strLocationName
		,CS.strContractStatus
		,(
			SELECT SUM(dblReservedQuantity)
			FROM tblLGReservation RES
			WHERE RES.intContractDetailId = CD.intContractDetailId
			) AS dblReservedQuantity
		,ISNULL(CD.dblQuantity, 0) - ISNULL((
				SELECT SUM(dblReservedQuantity)
				FROM tblLGReservation RES
				WHERE RES.intContractDetailId = CD.intContractDetailId
				), 0) AS dblUnReservedQuantity
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
		,CH.strCustomerContract AS strEntityContract
		,EY.strName AS strEntityName
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
		,CASE 
			WHEN CD.intPricingTypeId = 1
				THEN 'Priced'
			WHEN ISNULL(CD.dblNoOfLots, 0) - ISNULL([dblLotsFixed], 0) = 0
				THEN 'Fully Priced'
			WHEN ISNULL([dblLotsFixed], 0) = 0
				THEN 'Unpriced'
			ELSE 'Partially Priced'
			END AS strPriceFixStatus
		,CB.strContractBasis AS strIncoTerms
		,CO.strCountry AS strOrigin
		,FMA.strFutMarketName
		,FMO.strFutureMonth
		,ISNULL(AD.strSeqCurrency, '') + '/' + ISNULL(AD.strSeqPriceUOM, '') strPriceBasis
		,PT.strDescription AS strProductType
		,CR.strCropYear
		,W1.strWeightGradeDesc AS strGrade
		,W2.strWeightGradeDesc AS strWeight
		,TM.strTerm
		,CD.strItemSpecification
		,dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GETDATE()) AS dblLatestClosingPrice
	FROM tblCTContractDetail CD
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
	LEFT JOIN tblICItemContract ICI ON ICI.intItemId = IM.intItemId
		AND CD.intItemContractId = ICI.intItemContractId
	LEFT JOIN tblSMCountry CO ON CO.intCountryID = (
			CASE 
				WHEN ISNULL(ICI.intCountryId, 0) = 0
					THEN ISNULL(CA.intCountryID, 0)
				ELSE ICI.intCountryId
				END
			)
	LEFT JOIN tblRKFutureMarket FMA ON FMA.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = IM.intProductTypeId
		AND PT.strType = 'ProductType'
	LEFT JOIN tblCTCropYear CR ON CR.intCropYearId = CH.intCropYearId
	LEFT JOIN tblCTWeightGrade W1 ON W1.intWeightGradeId = CH.intGradeId
	LEFT JOIN tblCTWeightGrade W2 ON W2.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblSMTerm TM ON TM.intTermID = CH.intTermId
	LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = CD.intNetWeightUOMId
	LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
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
		,CD.dblNetWeight
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
		,EY.strName
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
		,PF.dblTotalLots
		,PF.dblLotsFixed
		,CB.strContractBasis
		,CO.strCountry
		,FMA.strFutMarketName
		,FMO.strFutureMonth
		,AD.strSeqCurrency
		,AD.strSeqPriceUOM
		,PT.strDescription
		,CR.strCropYear
		,W1.strWeightGradeDesc
		,W2.strWeightGradeDesc
		,TM.strTerm
		,CD.strItemSpecification
		,WUM.strUnitMeasure 
		,CD.intFutureMarketId
		,CD.intFutureMonthId
		,CD.dblNoOfLots
		,CD.intPricingTypeId
	) tbl
WHERE dblUnAllocatedQty > 0