CREATE VIEW vyuRKGetAssignPhysicalTransaction

AS

SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intContractDetailId))
	, *
FROM (
	SELECT *
		, dblToBeHedgedLots = dblNoOfLots - dblHedgedLots
		, dblToBeAssignedLots = dblNoOfLots - dblAssignedLots
	FROM (
		SELECT intContractDetailId
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
		WHERE ISNULL(CH.ysnMultiplePriceFixation, 0) = 1
			AND CH.intContractHeaderId <> (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail CCD WHERE CCD.intContractStatusId <> 3)
			AND ISNULL(CH.ysnEnableFutures,0) = CASE WHEN (SELECT ysnAllowDerivativeAssignToMultipleContracts FROM tblRKCompanyPreference) = 1 AND CT.strContractType = 'Sale' THEN 1 ELSE ISNULL(CH.ysnEnableFutures,0) END
	) t
)t1
WHERE intContractStatusId NOT IN (3, 5, 6)