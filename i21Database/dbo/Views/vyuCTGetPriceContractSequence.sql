CREATE VIEW [dbo].[vyuCTGetPriceContractSequence]

AS

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractSeq ASC) AS INT) intUniqueId,
			CD.intContractHeaderId,
			CD.intContractDetailId,
			CD.intFutureMarketId intOriginalFutureMarketId,
			CD.intFutureMonthId intOriginalFutureMonthId,
			CD.dblBasis dblOriginalBasis,
			CD.dblNoOfLots dblTotalLots,
			CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
			PU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
			CD.dblQuantity,
			CD.intItemUOMId,
			CD.strItemUOM,
			CD.strFutMarketName AS strFutureMarket,
			CD.strFutureMonth,
			CD.intContractSeq,
			CD.strContractType,
			CD.strEntityName,
			CD.strContractNumber,
			CY.strCurrency	AS strMarketCurrency,
			UM.strUnitMeasure AS strMarketUOM

	FROM	vyuCTContractSequence		CD
	JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId=	CD.intFutureMarketId
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID	=	MA.intCurrencyId
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId	=	MA.intUnitMeasureId	
	WHERE	dblNoOfLots IS NOT NULL


