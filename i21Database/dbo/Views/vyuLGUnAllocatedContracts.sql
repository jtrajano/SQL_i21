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
		,strWeightUOM = WUM.strUnitMeasure
		,dblDetailQuantity = CD.dblQuantity
		,strItemUOM = U1.strUnitMeasure
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
		,strItemDescription = IM.strDescription
		,strBundleItemNo = BI.strItemNo
		,CL.strLocationName
		,CS.strContractStatus
		,dblReservedQuantity = ISNULL(RSV.dblReservedQty, 0)
		,dblUnReservedQuantity = ISNULL(CD.dblQuantity, 0) - ISNULL(RSV.dblReservedQty, 0)
		,dblAllocatedQty = ISNULL(CD.dblAllocatedQty, 0)
		,dblUnAllocatedQty = ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblAllocatedQty, 0)
		,CH.intContractHeaderId
		,CH.intContractTypeId
		,CT.strContractType
		,CH.intCommodityId
		,CY.strCommodityCode
		,strCommodityDescription = CY.strDescription
		,CH.strContractNumber
		,CH.dtmContractDate
		,CH.strCustomerContract
		,strEntityContract = CH.strCustomerContract
		,strEntityName = EY.strName
		,CD.intBookId
		,BO.strBook
		,CD.intSubBookId
		,SB.strSubBook
		,strPriceFixStatus = CASE 
			WHEN CD.intPricingTypeId = 1
				THEN 'Priced'
			WHEN ISNULL(CD.dblNoOfLots, 0) - ISNULL([dblLotsFixed], 0) = 0
				THEN 'Fully Priced'
			WHEN ISNULL([dblLotsFixed], 0) = 0
				THEN 'Unpriced'
			ELSE 'Partially Priced'
			END COLLATE Latin1_General_CI_AS
		,strIncoTerms = CB.strContractBasis
		,FMA.strFutMarketName
		,FMO.strFutureMonth
		,strPriceBasis = ISNULL(AD.strSeqCurrency, '') + '/' + ISNULL(AD.strSeqPriceUOM, '')
		,CR.strCropYear
		,strGrade = W1.strWeightGradeDesc
		,strWeight = W2.strWeightGradeDesc
		,TM.strTerm
		,CD.strItemSpecification
		,dblLatestClosingPrice = dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId, CD.intFutureMonthId, GETDATE())
		,CD.dtmUpdatedAvailabilityDate
		,IM.dblGAShrinkFactor
		,strOrigin = ISNULL(CO.strCountry, GIC.strOrigin)
		,strProductType = GIC.strProductType
		,strRegion = GIC.strRegion 
		,strSeason = GIC.strSeason
		,strClass = GIC.strClassVariety
		,strProductLine = GIC.strProductLine
		,IM.strMarketValuation
	FROM tblCTContractDetail CD
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
	OUTER APPLY (SELECT dblReservedQty = SUM(dblReservedQuantity) FROM tblLGReservation RES WHERE RES.intContractDetailId = CD.intContractDetailId) RSV
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
	LEFT JOIN vyuICGetItemCommodity GIC ON GIC.intItemId = IM.intItemId
	LEFT JOIN tblICItemContract ICI ON ICI.intItemId = IM.intItemId AND CD.intItemContractId = ICI.intItemContractId
	LEFT JOIN tblICItem BI ON BI.intItemId = CD.intItemBundleId
	LEFT JOIN tblSMCountry CO ON CO.intCountryID = ICI.intCountryId
	LEFT JOIN tblRKFutureMarket FMA ON FMA.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
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
	) tbl
WHERE dblUnAllocatedQty > 0