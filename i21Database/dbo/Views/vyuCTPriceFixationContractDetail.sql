CREATE VIEW [dbo].[vyuCTPriceFixationContractDetail]
AS
SELECT a.intPriceFixationId
,a.intPriceContractId
,a.intConcurrencyId
,a.intContractHeaderId
,intContractDetailId = ISNULL(a.intContractDetailId, b.intContractDetailId)
,a.intOriginalFutureMarketId
,a.intOriginalFutureMonthId
,a.dblOriginalBasis
,a.dblTotalLots
,a.dblLotsFixed
,a.intLotsHedged
,a.dblPolResult
,a.dblPremiumPoints
,a.ysnAAPrice
,a.ysnSettlementPrice
,a.ysnToBeAgreed
,a.dblSettlementPrice
,a.dblAgreedAmount
,a.intAgreedItemUOMId
,a.dblPolPct
,a.dblPriceWORollArb
,a.dblRollArb
,a.dblPolSummary
,a.dblAdditionalCost
,a.dblFinalPrice
,a.intFinalPriceUOMId
,a.ysnSplit
,a.intPriceFixationRefId
FROM tblCTPriceFixation a
INNER JOIN tblCTContractDetail b ON a.intContractHeaderId = b.intContractHeaderId
