CREATE VIEW vyuIPPriceFixation
AS
SELECT intPriceFixationId
	,intPriceContractId
	,intContractHeaderId
	,intContractDetailId
	,intOriginalFutureMarketId
	,intOriginalFutureMonthId
	,dblOriginalBasis
	,dblTotalLots
	,dblLotsFixed
	,intLotsHedged
	,dblPolResult
	,dblPremiumPoints
	,ysnAAPrice
	,ysnSettlementPrice
	,ysnToBeAgreed
	,dblSettlementPrice
	,dblAgreedAmount
	,intAgreedItemUOMId
	,dblPolPct
	,dblPriceWORollArb
	,dblRollArb
	,dblPolSummary
	,dblAdditionalCost
	,dblFinalPrice
	,intFinalPriceUOMId
	,ysnSplit
	,intPriceFixationRefId
	,UM.strUnitMeasure AS strFinalPriceUOM
	,UM1.strUnitMeasure AS strAgreedItemUOM
	,C.strCommodityCode
FROM tblCTPriceFixation PF
JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = PF.intFinalPriceUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
LEFT JOIN tblICCommodity C ON C.intCommodityId = CUM.intCommodityId
JOIN tblICCommodityUnitMeasure CUM1 ON CUM1.intCommodityUnitMeasureId = PF.intAgreedItemUOMId
LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = CUM1.intUnitMeasureId

