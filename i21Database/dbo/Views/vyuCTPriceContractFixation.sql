CREATE VIEW [dbo].[vyuCTPriceContractFixation]

AS 

	SELECT	PF.intPriceFixationId,
			PF.intPriceContractId,
			PF.intConcurrencyId,
			PF.intContractHeaderId,
			PF.intContractDetailId,
			PF.intOriginalFutureMarketId,
			PF.intOriginalFutureMonthId,
			PF.dblOriginalBasis,
			PF.dblTotalLots,
			PF.dblLotsFixed,
			PF.intLotsHedged,
			PF.dblPolResult,
			PF.dblPremiumPoints,
			PF.ysnAAPrice,
			PF.ysnSettlementPrice,
			PF.ysnToBeAgreed,
			PF.dblSettlementPrice,
			PF.dblAgreedAmount,
			PF.intAgreedItemUOMId,
			PF.dblPolPct,
			PF.dblPriceWORollArb,
			PF.dblRollArb,
			PF.dblPolSummary,
			PF.dblAdditionalCost,
			PF.dblFinalPrice,
			PF.intFinalPriceUOMId,
			PF.ysnSplit,

			CD.dblQuantity,
			CD.strItemUOM,
			CD.strFutMarketName AS strFutureMarket,
			CD.strFutureMonth,
			CD.intContractSeq,
			CD.strContractType,
			CD.strEntityName,
			CD.strContractNumber,
			CY.strCurrency	AS strMarketCurrency,
			UM.strUnitMeasure AS strMarketUOM

	FROM	tblCTPriceFixation	PF
	JOIN	vyuCTContractSequence		CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
