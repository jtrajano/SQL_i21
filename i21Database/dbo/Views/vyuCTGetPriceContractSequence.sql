CREATE VIEW [dbo].[vyuCTGetPriceContractSequence]

AS

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractSeq ASC) AS INT) intUniqueId,
			*
	FROM
	(
		SELECT	CD.intContractHeaderId,
				CD.intContractDetailId,
				CD.intFutureMarketId intOriginalFutureMarketId,
				CD.intFutureMonthId intOriginalFutureMonthId,
				CD.dblBasis dblOriginalBasis,
				(
					SELECT SUM(dblNoOfLots)
					FROM (
						SELECT	dblNoOfLots dblNoOfLots
						FROM	tblCTContractDetail
						WHERE	intContractDetailId = CD.intContractDetailId				
						UNION ALL
						SELECT	dblNoOfLots dblNoOfLots
						FROM	tblCTContractDetail
						WHERE	intSplitFromId = CD.intContractDetailId
					) tbl
				) dblTotalLots,
				CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
				PU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
				(
					SELECT SUM(dblQuantity)
					FROM (
						SELECT	dblQuantity
						FROM	tblCTContractDetail
						WHERE	intContractDetailId = CD.intContractDetailId
						UNION ALL
						SELECT	dblQuantity
						FROM	tblCTContractDetail
						WHERE	intSplitFromId = CD.intContractDetailId
					) tbl
				) dblQuantity,
				CD.intItemUOMId,
				CD.strPriceUOM,
				CD.strItemUOM,
				CD.strFutMarketName				AS strFutureMarket,
				CD.strFutureMonth,
				CD.intContractSeq,
				CD.strContractType,
				CD.strEntityName,
				CD.strContractNumber,
				CY.strCurrency					AS strMarketCurrency,
				UM.strUnitMeasure				AS strMarketUOM,				
				CD.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				SY.ysnSubCurrency				AS	ysnSeqSubCurrency,
				MA.intCurrencyId				AS	intMarketCurrencyId,
				CY.ysnSubCurrency				AS	ysnMarketSubCurrency
		FROM	vyuCTContractSequence		CD
		JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
												AND	CD.dblNoOfLots IS NOT NULL		 
												AND	ISNULL(CD.ysnMultiplePriceFixation,0) = 0
		JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId=	CD.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID	=	MA.intCurrencyId
		JOIN	tblSMCurrency				SY	ON	SY.intCurrencyID	=	CD.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId	=	MA.intUnitMeasureId	

		UNION ALL

		SELECT 	CH.intContractHeaderId,
				CAST (NULL AS INT)				AS	intContractDetailId, 
				CH.intFutureMarketId			AS	intOriginalFutureMarketId,
				CH.intFutureMonthId				AS	intOriginalFutureMonthId,
				CAST (NULL AS NUMERIC(18,6))	AS	dblOriginalBasis,
				CH.dblNoOfLots					AS	dblTotalLots,
				CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
				CU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
				CH.dblQuantity,
				CAST (NULL AS INT)				AS	intItemUOMId,
				PM.strUnitMeasure				AS	strPriceUOM,
				QM.strUnitMeasure				AS	strItemUOM,
				MA.strFutMarketName				AS	strFutureMarket,
				MO.strFutureMonth				AS	strFutureMonth,
				CAST (NULL AS INT)				AS	intContractSeq,
				CT.strContractType,
				EY.strName						AS	strEntityName,
				CH.strContractNumber,					
				CY.strCurrency					AS	strMarketCurrency,
				PM.strUnitMeasure				AS	strMarketUOM,				
				CH.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				CD.ysnSubCurrency				AS	ysnSeqSubCurrency,
				MA.intCurrencyId				AS	intMarketCurrencyId,
				CY.ysnSubCurrency				AS	ysnMarketSubCurrency			

		FROM	tblCTContractHeader			CH	
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId	=	CH.intContractTypeId
												AND	ISNULL(ysnMultiplePriceFixation,0) = 1
												AND	CH.intContractHeaderId	IN	(SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId <> 2)
		JOIN	tblEMEntity					EY	ON	EY.intEntityId			=	CH.intEntityId
		JOIN	tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CH.intFutureMarketId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CH.intCommodityId 
												AND CU.intUnitMeasureId		=	MA.intUnitMeasureId
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	CH.intFutureMonthId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId		=	MA.intUnitMeasureId	
		CROSS APPLY fnCTGetTopOneSequence(CH.intContractHeaderId,0)	CD	
	)t