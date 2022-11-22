CREATE VIEW vyuRKGetAssignPhysicalTransaction

AS

SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY t1.intContractDetailId))
	, *
FROM (
	SELECT *
		, dblToBeHedgedLots = dblNoOfLots - dblHedgedLots
		, dblToBeAssignedLots = dblNoOfLots - dblAssignedLots
	FROM (
		SELECT CD.intContractDetailId
			, CH.intContractHeaderId
			, CH.dtmContractDate
			, CT.strContractType
			, CH.strContractNumber
			, CD.intContractSeq
			, strCustomer = E.strName
			, dblQuantity = CD.dblQuantity
			, UC.strUnitMeasure
			, dblWeights = ISNULL(CD.dblNetWeight, 0.00)
			, M.strFutMarketName
			, MO.strFutureMonth
			, dblNoOfLots = ISNULL(CD.dblNoOfLots, 0)
			, dblHedgedLots = ISNULL((SELECT SUM(AD.dblHedgedLots)
									FROM tblRKAssignFuturesToContractSummary AD
									GROUP BY AD.intContractDetailId
									HAVING CD.intContractDetailId = AD.intContractDetailId), 0)
			, dblAssignedLots = ISNULL((SELECT SUM(AD.dblAssignedLots)
										FROM tblRKAssignFuturesToContractSummary AD
										GROUP BY AD.intContractDetailId
										HAVING CD.intContractDetailId = AD.intContractDetailId), 0)
			, COM.strCommodityCode
			, CL.strLocationName
			, MO.ysnExpired
			, B.strBook
			, SB.strSubBook
			, CD.intContractStatusId
			, CD.intPricingTypeId
			, strPricingStatus = CASE WHEN CD.intPricingTypeId = 2
									  THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0  THEN 'Unpriced'
										ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0)-ISNULL(dblLotsFixed, 0) = 0 THEN 'Fully Priced' 
												  WHEN ISNULL(dblLotsFixed, 0) = 0  THEN 'Unpriced'
												  ELSE 'Partially Priced' END END
									  WHEN CD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END	
			, dblLotsPriced = ISNULL(PF.dblLotsFixed, 0)
			, dblLotsUnpriced = ISNULL(ISNULL(PF.dblTotalLots - ISNULL(PF.dblLotsFixed, 0), CD.dblNoOfLots), 0)
			, compactItem.strOrigin
			, compactItem.strProductType
			, compactItem.strGrade
			, compactItem.strRegion
			, compactItem.strSeason
			, compactItem.strClass
			, compactItem.strProductLine
		FROM tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CD.intContractStatusId <> 3
		JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblICCommodity COM ON COM.intCommodityId = CH.intCommodityId
		JOIN tblRKFutureMarket M ON CD.intFutureMarketId = M.intFutureMarketId
		JOIN tblRKFuturesMonth MO ON CD.intFutureMonthId = MO.intFutureMonthId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		JOIN tblICUnitMeasure UC ON CD.intUnitMeasureId = UC.intUnitMeasureId
		LEFT JOIN tblCTBook B ON CD.intBookId = B.intBookId
		LEFT JOIN tblCTSubBook SB ON CD.intSubBookId = SB.intSubBookId 
		OUTER APPLY (
			SELECT dblQuantity = SUM(PFD.dblQuantity)
			FROM tblCTPriceFixation PF
			LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
			WHERE PF.intContractDetailId = CD.intContractDetailId
		) priceFixation
		LEFT JOIN tblICItem item ON item.intItemId = CD.intItemId
		LEFT JOIN vyuICGetCompactItem compactItem ON item.intItemId = compactItem.intItemId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId	
		WHERE ISNULL(CH.ysnMultiplePriceFixation, 0) = 0
		AND ISNULL(CH.ysnEnableFutures,0) = CASE WHEN (SELECT ysnAllowDerivativeAssignToMultipleContracts FROM tblRKCompanyPreference) = 1 AND CT.strContractType = 'Sale' THEN 1 ELSE ISNULL(CH.ysnEnableFutures,0) END
	) t
	
	UNION ALL SELECT *
		, dblToBeHedgedLots = dblNoOfLots - dblHedgedLots
		, dblToBeAssignedLots = dblNoOfLots - dblAssignedLots
	FROM (
		SELECT intContractDetailId = (SELECT TOP 1 intContractDetailId FROM tblCTContractDetail WHERE intContractHeaderId = CH.intContractHeaderId)
			, CH.intContractHeaderId
			, CH.dtmContractDate
			, CT.strContractType
			, CH.strContractNumber
			, intContractSeq = NULL
			, strCustomer = E.strName
			, dblQuantity = CH.dblQuantity
			, UC.strUnitMeasure
			, dblWeights = 0.00
			, M.strFutMarketName
			, MO.strFutureMonth
			, dblNoOfLots = ISNULL(CH.dblNoOfLots, 0)
			, dblHedgedLots = ISNULL((SELECT SUM(AD.dblHedgedLots)
									FROM tblRKAssignFuturesToContractSummary AD
									GROUP BY AD.intContractHeaderId
									HAVING CH.intContractHeaderId = AD.intContractHeaderId), 0)
			, dblAssignedLots = ISNULL((SELECT SUM(AD.dblAssignedLots)
										FROM tblRKAssignFuturesToContractSummary AD
										GROUP BY AD.intContractHeaderId
										HAVING CH.intContractHeaderId = AD.intContractHeaderId), 0)
			, COM.strCommodityCode
			, CL.strLocationName
			, MO.ysnExpired
			, B.strBook
			, SB.strSubBook
			, CD.intContractStatusId
			, CH.intPricingTypeId
			, strPricingStatus = CASE WHEN CDD.intPricingTypeId = 2
									  THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0  THEN 'Unpriced'
										ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0)-ISNULL(dblLotsFixed, 0) = 0 THEN 'Fully Priced' 
												  WHEN ISNULL(dblLotsFixed, 0) = 0  THEN 'Unpriced'
												  ELSE 'Partially Priced' END END
									  WHEN CDD.intPricingTypeId = 1 THEN 'Priced' ELSE '' END	
			, dblLotsPriced = ISNULL(PF.dblLotsFixed, 0)
			, dblLotsUnpriced = ISNULL(ISNULL(PF.dblTotalLots - ISNULL(PF.dblLotsFixed, 0), CH.dblNoOfLots), 0)
			, compactItem.strOrigin
			, compactItem.strProductType
			, compactItem.strGrade
			, compactItem.strRegion
			, compactItem.strSeason
			, compactItem.strClass
			, compactItem.strProductLine
		FROM tblCTContractHeader CH
		INNER JOIN (SELECT DISTINCT intContractHeaderId, intContractStatusId FROM tblCTContractDetail) CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblICCommodity COM ON COM.intCommodityId = CH.intCommodityId
		JOIN tblRKFutureMarket M ON CH.intFutureMarketId = M.intFutureMarketId
		JOIN tblRKFuturesMonth MO ON CH.intFutureMonthId = MO.intFutureMonthId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblCTContractDetail CD WHERE CD.intContractHeaderId = CH.intContractHeaderId)
		JOIN tblICUnitMeasure UC ON UC.intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblCTContractDetail CD WHERE CD.intContractHeaderId = CH.intContractHeaderId)
		LEFT JOIN tblCTBook B ON B.intBookId = (SELECT TOP 1 intBookId FROM tblCTContractDetail CD WHERE CD.intContractHeaderId = CH.intContractHeaderId)
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = (SELECT TOP 1 intSubBookId FROM tblCTContractDetail CD WHERE CD.intContractHeaderId = CH.intContractHeaderId)
		LEFT JOIN tblCTContractDetail CDD ON CDD.intContractHeaderId = CH.intContractHeaderId
		OUTER APPLY (
			SELECT dblQuantity = SUM(PFD.dblQuantity)
			FROM tblCTPriceFixation PF
			LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
			WHERE PF.intContractDetailId = CDD.intContractDetailId
		) priceFixation
		LEFT JOIN tblICItem item ON item.intItemId = CDD.intItemId
		LEFT JOIN vyuICGetCompactItem compactItem ON item.intItemId = compactItem.intItemId
		LEFT JOIN tblCTPriceFixation PF ON CDD.intContractDetailId = PF.intContractDetailId	
		WHERE ISNULL(CH.ysnMultiplePriceFixation, 0) = 1
			AND CH.intContractHeaderId <> (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail CCD WHERE CCD.intContractStatusId <> 3)
			AND ISNULL(CH.ysnEnableFutures,0) = CASE WHEN (SELECT ysnAllowDerivativeAssignToMultipleContracts FROM tblRKCompanyPreference) = 1 AND CT.strContractType = 'Sale' THEN 1 ELSE ISNULL(CH.ysnEnableFutures,0) END
	) t
)t1
WHERE intContractStatusId NOT IN (3, 5, 6)