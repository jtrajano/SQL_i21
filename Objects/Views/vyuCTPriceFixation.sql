CREATE VIEW vyuCTPriceFixation

AS

SELECT 				PF.intPriceFixationId,
					intEntityId,
					intContractTypeId,
					strLocationName,
					dblDetailQuantity AS dblQuantity,
					CD.intItemUOMId,
					intFutureMarketId,
					strFutMarketName,
					intFutureMonthId,
					strFutureMonth,
					CD.dblBasis,
					CD.dblFutures,
					CD.dblCashPrice,
					CD.intCommodityId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					CD.intCompanyLocationId,
					CD.intCurrencyId,
					CD.ysnMultiplePriceFixation,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId AS intBasisCommodityUOMId

		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractDetailView		CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CD.intCommodityId	AND CU.ysnDefault = 1 
		JOIN		tblICItemUOM				IM	ON	IM.intItemUOMId			=	CD.intPriceItemUOMId
		JOIN		tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId		=	CD.intCommodityId	AND PU.intUnitMeasureId = IM.intUnitMeasureId
		AND			PF.intContractDetailId IS NOT NULL

		UNION ALL
		
		SELECT 		PF.intPriceFixationId,
					intEntityId,
					intContractTypeId,
					LTRIM(NULL)					AS	strLocationName,
					dblHeaderQuantity,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(intFutureMarketId)		AS	intFutureMarketId,
					MAX(strFutMarketName)		AS	strFutMarketName,
					MAX(intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonth)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblBasis,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblFutures,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblCashPrice,
					CD.intCommodityId,
					CAST (NULL AS INT)			AS	intBookId,
					CAST (NULL AS INT)			AS	intSubBookId,
					intSalespersonId,
					MAX(CD.intCompanyLocationId)	AS	intCompanyLocationId,
					MAX(CD.intCurrencyId)		AS	intCurrencyId,
					CD.ysnMultiplePriceFixation,
					CAST (NULL AS INT)			AS	intDiscountScheduleCodeId,
					CAST (NULL AS INT)			AS	intBasisCommodityUOMId

		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractDetailView		CD	ON	CD.intContractHeaderId = PF.intContractHeaderId
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CD.intCommodityId AND CU.ysnDefault = 1 
		WHERE		PF.intContractDetailId IS NULL
		GROUP BY	PF.intPriceFixationId,
					intEntityId,
					intContractTypeId,
					dblHeaderQuantity,
					CD.intCommodityId,
					intSalespersonId,
					CD.ysnMultiplePriceFixation