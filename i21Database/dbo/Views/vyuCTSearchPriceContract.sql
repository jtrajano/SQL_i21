CREATE VIEW [dbo].[vyuCTSearchPriceContract]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractHeaderId) AS INT) AS intUniqueId,* 
	FROM
	(
		SELECT 		CAST (NULL AS INT) AS intPriceContractId,
					CAST (NULL AS INT) AS intPriceFixationId,
					intContractDetailId, 
					intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					(SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId) AS dblQuantity,
					strItemUOM AS strUOM,
					(SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId) dblNoOfLots,
					strLocationName,
					CD.intItemId,
					CD.intItemUOMId,
					intFutureMarketId,
					strFutMarketName,
					intFutureMonthId,
					strFutureMonth,
					dblBasis,
					dblFutures,
					dblCashPrice,
					intPriceItemUOMId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					intCurrencyId,
					intCompanyLocationId,
					'Unpriced' AS strStatus,
					CAST(0 AS INT) AS dblLotsFixed,
					dblNoOfLots AS dblBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId AS intBasisCommodityUOMId,
					CD.strEntityContract,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.strBook,
					CD.strSubBook

		FROM		vyuCTContractSequence		CD
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CD.intCommodityId AND CU.ysnDefault = 1
		JOIN		tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
		JOIN		tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		WHERE		intPricingTypeId = 2 
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0
		AND			intContractDetailId NOT IN (SELECT ISNULL(intContractDetailId,0) FROM tblCTPriceFixation)
		AND			CD.intContractStatusId <> 3
		AND			CD.intSplitFromId	IS NULL
		AND			CD.intContractStatusId NOT IN (2,3)

		UNION ALL
		
		SELECT 		CAST (NULL AS INT)			AS	intPriceContractId,
					CAST (NULL AS INT)			AS	intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					CD.intContractHeaderId,
					CD.strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CAST(NULL AS NUMERIC(18, 6)) AS	dblHeaderQuantity,
					QM.strUnitMeasure			AS	strHeaderUnitMeasure,
					ISNULL(CH.dblNoOfLots,SUM(CD.dblNoOfLots))			AS	dblNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(CD.intFutureMarketId)		AS	intFutureMarketId,
					MAX(CD.strFutMarketName)		AS	strFutMarketName,
					MAX(CD.intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonth)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblBasis,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblFutures,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CAST (NULL AS INT)			AS	intBookId,
					CAST (NULL AS INT)			AS	intSubBookId,
					CD.intSalespersonId,
					MAX(intCurrencyId)			AS	intCurrencyId,
					MAX(intCompanyLocationId)	AS	intCompanyLocationId,
					'Unpriced' AS strStatus,
					CAST(0 AS INT) AS intLotsFixed,
					CH.dblNoOfLots AS dblBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CAST (NULL AS INT)			AS	intDiscountScheduleCodeId,
					CU.intCommodityUnitMeasureId			AS	intBasisCommodityUOMId,
					CD.strEntityContract,
					MAX(CD.dtmStartDate)		AS	dtmStartDate,
					MAX(CD.dtmEndDate)			AS	dtmEndDate,
					CD.strBook,
					CD.strSubBook

		FROM		vyuCTContractSequence		CD
		JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		JOIN		tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId		=		CH.intCommodityUOMId
		JOIN		tblICUnitMeasure			QM	ON	QM.intUnitMeasureId					=		QU.intUnitMeasureId	
		JOIN		tblICItemUOM				PU	ON	PU.intItemUOMId		=	CD.intPriceItemUOMId		
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CD.intCommodityId AND CU.intUnitMeasureId = PU.intUnitMeasureId 
		WHERE		ISNULL(CD.ysnMultiplePriceFixation,0) = 1
		AND			CD.intContractHeaderId NOT IN (SELECT ISNULL(intContractHeaderId,0) FROM tblCTPriceFixation)
		AND			CD.intContractStatusId NOT IN (2,3)
		AND			CH.intPricingTypeId = 2
		GROUP BY	CD.intContractHeaderId,
					CD.strContractNumber,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CH.dblQuantity,
					QM.strUnitMeasure,
					CD.intSalespersonId,
					CU.intCommodityUnitMeasureId,
					CH.dblNoOfLots,
					CD.strEntityContract,
					CD.strBook,
					CD.strSubBook

		UNION ALL

		SELECT 		PF.intPriceContractId,
					PF.intPriceFixationId,
					PF.intContractDetailId, 
					PF.intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					CD.dblQuantity,
					strItemUOM AS strUOM,
					PF.[dblTotalLots] AS dblNoOfLots,
					strLocationName,
					CD.intItemId,
					CD.intItemUOMId,
					intFutureMarketId,
					strFutMarketName,
					intFutureMonthId,
					strFutureMonth,
					CD.dblBasis,
					CD.dblFutures,
					CD.dblCashPrice,
					intPriceItemUOMId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					intCurrencyId,
					intCompanyLocationId,
					CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL([dblLotsFixed],0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL([dblLotsFixed],0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		AS strStatus,
					PF.[dblLotsFixed],
					PF.[dblTotalLots]-[dblLotsFixed] AS dblBalanceNoOfLots,
					PF.intLotsHedged,
					PF.dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId AS intBasisCommodityUOMId,
					CD.strEntityContract,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.strBook,
					CD.strSubBook

		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractSequence		CD	ON	CD.intContractDetailId = PF.intContractDetailId
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CD.intCommodityId AND CU.ysnDefault = 1 
		JOIN		tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
		JOIN		tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		--WHERE		intPricingTypeId = 2 
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0
		AND			CD.intContractStatusId <> 3

		UNION ALL
		
		SELECT 		PF.intPriceContractId,
					PF.intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					CD.intContractHeaderId,
					CD.strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CAST(NULL AS NUMERIC(18, 6)) AS  dblHeaderQuantity,
					QM.strUnitMeasure			AS	strHeaderUnitMeasure,
					PF.[dblTotalLots]			AS	dblNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(CD.intFutureMarketId)		AS	intFutureMarketId,
					MAX(CD.strFutMarketName)		AS	strFutMarketName,
					MAX(CD.intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonth)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblBasis,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblFutures,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CAST (NULL AS INT)			AS	intBookId,
					CAST (NULL AS INT)			AS	intSubBookId,
					CD.intSalespersonId,
					MAX(intCurrencyId)			AS	intCurrencyId,
					MAX(intCompanyLocationId)	AS	intCompanyLocationId,
					CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(PF.[dblLotsFixed],0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL([dblLotsFixed],0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		AS strStatus,
					PF.[dblLotsFixed],
					PF.[dblTotalLots]-PF.[dblLotsFixed] AS dblBalanceNoOfLots,
					PF.intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CAST (NULL AS INT)			AS	intDiscountScheduleCodeId,
					CAST (NULL AS INT)			AS	intBasisCommodityUOMId,
					CD.strEntityContract,
					MAX(CD.dtmStartDate)		AS	dtmStartDate,
					MAX(CD.dtmEndDate)			AS	dtmEndDate,
					CD.strBook,
					CD.strSubBook

		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractSequence		CD	ON	CD.intContractHeaderId = PF.intContractHeaderId
		JOIN		tblCTContractHeader			CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		JOIN		tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
		JOIN		tblICUnitMeasure			QM	ON	QM.intUnitMeasureId					=		QU.intUnitMeasureId		
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CD.intCommodityId AND CU.ysnDefault = 1 
		WHERE		ISNULL(CD.ysnMultiplePriceFixation,0) = 1
		GROUP BY	CD.intContractHeaderId,
					CD.strContractNumber,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CH.dblQuantity,
					QM.strUnitMeasure,
					CD.intSalespersonId,
					PF.[dblLotsFixed],
					PF.[dblTotalLots],
					PF.intLotsHedged,
					PF.intPriceFixationId,
					CU.intCommodityUnitMeasureId,
					CD.strEntityContract,
					PF.intPriceContractId,
					CD.strBook,
					CD.strSubBook
	)t
