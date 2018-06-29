CREATE VIEW [dbo].[vyuCTGridPriceContractSplitSeq]

AS 

	SELECT	CD.intContractDetailId,
			CD.intSplitFromId,
			PF.intPriceFixationId,

			CD.strItemNo,
			CD.dblQuantity,			
			CD.strItemUOM,
			CD.strFutMarketName AS strFutureMarket,
			CD.strFutureMonth,
			CD.intContractSeq,
			CD.dblNoOfLots,
			CD.dblBasis,
			CD.dblFutures,
			CD.dblCashPrice,
			CD.strPriceUOM

	FROM	tblCTPriceFixation	PF
	JOIN	vyuCTContractSequence		CD	ON	CD.intSplitFromId		=	PF.intContractDetailId
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
