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
				CD.dblNoOfLots dblTotalLots,
				CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
				PU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
				CD.dblQuantity,
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
				CD.ysnMultiplePriceFixation

		FROM	vyuCTContractSequence		CD
		JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
		JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId=	CD.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID	=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId	=	MA.intUnitMeasureId	
		WHERE	dblNoOfLots IS NOT NULL		AND 
				ISNULL(CD.ysnMultiplePriceFixation,0) = 0

		UNION ALL

		SELECT 	CD.intContractHeaderId,
				CAST (NULL AS INT)				AS	intContractDetailId, 
				MAX(CD.intFutureMarketId)		AS	intOriginalFutureMarketId,
				MAX(CD.intFutureMonthId)		AS	intOriginalFutureMonthId,
				CAST (NULL AS NUMERIC(18,6))	AS	dblOriginalBasis,
				SUM(CD.dblNoOfLots)				AS	dblTotalLots,
				CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
				CU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
				CAST(NULL AS NUMERIC(18, 6))	AS	dblQuantity,
				CAST (NULL AS INT)				AS	intItemUOMId,
				QM.strUnitMeasure				AS	strPriceUOM,
				CAST (NULL AS NVARCHAR(40))		AS	strItemUOM,
				MAX(CD.strFutMarketName)		AS	strFutureMarket,
				MAX(strFutureMonth)				AS	strFutureMonth,
				CAST (NULL AS INT)				AS	intContractSeq,
				strContractType,
				strEntityName,
				CD.strContractNumber,					
				CY.strCurrency					AS	strMarketCurrency,
				UM.strUnitMeasure				AS	strMarketUOM,				
				CD.ysnMultiplePriceFixation				

		FROM	vyuCTContractSequence		CD	
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CD.intCommodityId AND CU.ysnDefault = 1 
		JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	CU.intUnitMeasureId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	(
																					SELECT  TOP 1 DT.intFutureMarketId  
																					FROM	tblCTContractDetail DT 
																					WHERE	DT.intContractHeaderId = CD.intContractHeaderId
																				)
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
		WHERE	ISNULL(CD.ysnMultiplePriceFixation,0) = 1
		GROUP BY	CD.intContractHeaderId,
					CU.intCommodityUnitMeasureId,
					QM.strUnitMeasure,
					strContractType,
					strEntityName,
					CD.strContractNumber,					
					CY.strCurrency,
					UM.strUnitMeasure,				
					CD.ysnMultiplePriceFixation
	)t



