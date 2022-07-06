CREATE VIEW [dbo].[vyuCTCombinePriceFixation]
	AS
	SELECT
		pf.intPriceFixationId
		,pf.intPriceContractId
		,pf.intConcurrencyId
		,pf.intContractHeaderId
		,pf.intContractDetailId
		,pf.intOriginalFutureMarketId
		,pf.intOriginalFutureMonthId
		,pf.dblOriginalBasis
		,pf.dblTotalLots
		,pf.dblLotsFixed
		,pf.intLotsHedged
		,pf.dblPolResult
		,pf.dblPremiumPoints
		,pf.ysnAAPrice
		,pf.ysnSettlementPrice
		,pf.ysnToBeAgreed
		,pf.dblSettlementPrice
		,pf.dblAgreedAmount
		,pf.intAgreedItemUOMId
		,pf.dblPolPct
		,pf.dblPriceWORollArb
		,pf.dblRollArb
		,pf.dblPolSummary
		,pf.dblAdditionalCost
		,pf.dblFinalPrice
		,pf.intFinalPriceUOMId
		,pf.ysnSplit
		,pf.intPriceFixationRefId
		,ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	FROM
		tblCTContractHeader ch
		join tblCTPriceFixation pf
			on pf.intContractHeaderId = ch.intContractHeaderId
	where
		isnull(ch.ysnMultiplePriceFixation,0) = 0

	union all

	SELECT
		intPriceFixationId = pf.intPriceFixationMultiplePriceId
		,pf.intPriceContractId
		,pf.intConcurrencyId
		,pf.intContractHeaderId
		,pf.intContractDetailId
		,pf.intOriginalFutureMarketId
		,pf.intOriginalFutureMonthId
		,pf.dblOriginalBasis
		,pf.dblTotalLots
		,pf.dblLotsFixed
		,pf.intLotsHedged
		,pf.dblPolResult
		,pf.dblPremiumPoints
		,pf.ysnAAPrice
		,pf.ysnSettlementPrice
		,pf.ysnToBeAgreed
		,pf.dblSettlementPrice
		,pf.dblAgreedAmount
		,pf.intAgreedItemUOMId
		,pf.dblPolPct
		,pf.dblPriceWORollArb
		,pf.dblRollArb
		,pf.dblPolSummary
		,pf.dblAdditionalCost
		,pf.dblFinalPrice
		,pf.intFinalPriceUOMId
		,pf.ysnSplit
		,pf.intPriceFixationRefId
		,ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	FROM
		tblCTContractHeader ch
		join tblCTPriceFixationMultiplePrice pf
			on pf.intContractHeaderId = ch.intContractHeaderId
	where
		isnull(ch.ysnMultiplePriceFixation,0) = 1
