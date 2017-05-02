CREATE VIEW [dbo].[vyuCTGridPriceContractFixation]

AS 

	--WITH cteContractDetail AS
	--(
	--	SELECT	ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractSeq DESC) AS intRowNum,
	--			DT.intContractHeaderId, DT.intFutureMarketId, DT.intFutureMonthId, strFutMarketName, strFutureMonth, strContractType, strEntityName, strContractNumber, ysnMultiplePriceFixation
	--	FROM	vyuCTContractSequence DT 
	--)

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

				(SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE CD.intContractDetailId IN (intContractDetailId,intSplitFromId)) AS dblQuantity,
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
				CD.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				CD.ysnSubCurrency				AS	ysnSeqSubCurrency,
				MA.intCurrencyId				AS	intMarketCurrencyId,
				CY.ysnSubCurrency				AS	ysnMarketSubCurrency	

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

				CH.dblQuantity,
				PM.strUnitMeasure		AS	strPriceUOM,
				QM.strUnitMeasure		AS	strItemUOM,
				NULL,
				CH.intFutureMarketId,
				MA.strFutMarketName		AS	strFutureMarket,
				CH.intFutureMonthId,
				MO.strFutureMonth,
				NULL,
				CT.strContractType,
				EY.strName				AS	strEntityName,
				CH.strContractNumber,
				NULL					AS	dblConvertedBasis,
				CY.strCurrency			AS	strMarketCurrency,
				UM.strUnitMeasure		AS	strMarketUOM,
				CH.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				CD.ysnSubCurrency				AS	ysnSeqSubCurrency,
				MA.intCurrencyId				AS	intMarketCurrencyId,
				CY.ysnSubCurrency				AS	ysnMarketSubCurrency	

		FROM	tblCTPriceFixation	PF	
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId 
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId		=	CU.intUnitMeasureId
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	PF.intContractHeaderId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CH.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	CH.intFutureMonthId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId			=	CH.intEntityId
		JOIN	tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId
		CROSS APPLY fnCTGetTopOneSequence(CH.intContractHeaderId,0)	CD
		WHERE	ISNULL(CH.ysnMultiplePriceFixation,0) = 1
	)t