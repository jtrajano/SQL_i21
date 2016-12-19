CREATE VIEW [dbo].[vyuCTGridPriceContractFixation]

AS 

	WITH cteContractDetail AS
	(
		SELECT	ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractSeq DESC) AS intRowNum,
				DT.intContractHeaderId, DT.intFutureMarketId, DT.intFutureMonthId, strFutMarketName, strFutureMonth, strContractType, strEntityName, strContractNumber, ysnMultiplePriceFixation
		FROM	vyuCTContractSequence DT 
	)

	SELECT * FROM
	(
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
				CD.strPriceUOM,
				CD.strItemUOM,
				CD.intItemUOMId,
				CD.intFutureMarketId,
				CD.strFutMarketName AS strFutureMarket,
				CD.intFutureMonthId,
				CD.strFutureMonth,
				CD.intContractSeq,
				CD.strContractType,
				CD.strEntityName,
				CD.strContractNumber,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId, CD.intPriceCommodityUOMId ,CD.dblBasis)	AS dblConvertedBasis,
				CY.strCurrency	AS strMarketCurrency,
				UM.strUnitMeasure AS strMarketUOM,
				CD.ysnMultiplePriceFixation

		FROM	tblCTPriceFixation	PF
		JOIN	vyuCTContractSequence		CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	

		UNION ALL

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

				NULL,
				QM.strUnitMeasure AS strPriceUOM,
				NULL,
				NULL,
				CD.intFutureMarketId,
				CD.strFutMarketName AS strFutureMarket,
				CD.intFutureMonthId,
				CD.strFutureMonth,
				NULL,
				CD.strContractType,
				CD.strEntityName,
				CD.strContractNumber,
				NULL	AS dblConvertedBasis,
				CY.strCurrency	AS strMarketCurrency,
				UM.strUnitMeasure AS strMarketUOM,
				CD.ysnMultiplePriceFixation

		FROM	tblCTPriceFixation	PF	
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	PF.intFinalPriceUOMId 
		JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	CU.intUnitMeasureId
		JOIN	cteContractDetail			CD	ON	CD.intContractHeaderId	=	PF.intContractHeaderId AND CD.intRowNum = 1
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
		WHERE	ISNULL(CD.ysnMultiplePriceFixation,0) = 1
	)t