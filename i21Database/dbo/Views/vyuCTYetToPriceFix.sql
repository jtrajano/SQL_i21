CREATE VIEW [dbo].[vyuCTYetToPriceFix]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractHeaderId) AS INT) AS intUniqueId,* 
	FROM
	(
		SELECT 		CAST (NULL AS INT) AS intPriceFixationId,
					intContractDetailId, 
					intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblDetailQuantity AS dblQuantity,
					strItemUOM AS strUOM,
					CAST(dblNoOfLots AS INT) AS intNoOfLots,
					strLocationName,
					intItemId,
					intItemUOMId,
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
					CAST(0 AS INT) AS intLotsFixed,
					CAST(dblNoOfLots AS INT) AS intBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(8,4)) AS dblFinalPrice

		FROM		vyuCTContractDetailView 
		WHERE		intPricingTypeId = 2 
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0
		AND			intContractDetailId NOT IN (SELECT intContractDetailId FROM tblCTPriceFixation)
		
		UNION ALL
		
		SELECT 		CAST (NULL AS INT)			AS	intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					intContractHeaderId,
					strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblHeaderQuantity,
					strHeaderUnitMeasure,
					CAST(ROUND(SUM(dblNoOfLots),0)AS INT)	AS	intNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(intFutureMarketId)		AS	intFutureMarketId,
					MAX(strFutMarketName)		AS	strFutMarketName,
					MAX(intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonth)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(8,4)) AS	dblBasis,
					CAST (NULL AS NUMERIC(8,4)) AS	dblFutures,
					CAST (NULL AS NUMERIC(9,4)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CAST (NULL AS INT)			AS	intBookId,
					CAST (NULL AS INT)			AS	intSubBookId,
					intSalespersonId,
					MAX(intCurrencyId)			AS	intCurrencyId,
					MAX(intCompanyLocationId)	AS	intCompanyLocationId,
					'Unpriced' AS strStatus,
					CAST(0 AS INT) AS intLotsFixed,
					CAST(ROUND(SUM(dblNoOfLots),0)AS INT) AS intBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(8,4)) AS dblFinalPrice

		FROM		vyuCTContractDetailView 
		WHERE		ISNULL(ysnMultiplePriceFixation,0) = 1
		AND			intContractHeaderId NOT IN (SELECT ISNULL(intContractHeaderId,0) FROM tblCTPriceFixation)
		GROUP BY	intContractHeaderId,
					strContractNumber,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblHeaderQuantity,
					strHeaderUnitMeasure,
					intSalespersonId

		UNION ALL

		SELECT 		PF.intPriceFixationId,
					PF.intContractDetailId, 
					PF.intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblDetailQuantity AS dblQuantity,
					strItemUOM AS strUOM,
					PF.intTotalLots AS intNoOfLots,
					strLocationName,
					intItemId,
					intItemUOMId,
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
					CASE	WHEN ISNULL(PF.intTotalLots,0)-ISNULL(intLotsFixed,0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL(intLotsFixed,0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		AS strStatus,
					PF.intLotsFixed,
					PF.intTotalLots-intLotsFixed AS intBalanceNoOfLots,
					PF.intLotsHedged,
					PF.dblFinalPrice

		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractDetailView		CD	ON	CD.intContractDetailId = PF.intContractDetailId
		WHERE		intPricingTypeId = 2 
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0

		UNION ALL
		
		SELECT 		PF.intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					CH.intContractHeaderId,
					strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblHeaderQuantity,
					strHeaderUnitMeasure,
					PF.intTotalLots				AS	intNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(intFutureMarketId)		AS	intFutureMarketId,
					MAX(strFutMarketName)		AS	strFutMarketName,
					MAX(intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonth)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(8,4)) AS	dblBasis,
					CAST (NULL AS NUMERIC(8,4)) AS	dblFutures,
					CAST (NULL AS NUMERIC(9,4)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CAST (NULL AS INT)			AS	intBookId,
					CAST (NULL AS INT)			AS	intSubBookId,
					intSalespersonId,
					MAX(intCurrencyId)			AS	intCurrencyId,
					MAX(intCompanyLocationId)	AS	intCompanyLocationId,
					CASE	WHEN ISNULL(CAST(ROUND(SUM(dblNoOfLots),0)AS INT),0)-ISNULL(PF.intLotsFixed,0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL(intLotsFixed,0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		AS strStatus,
					PF.intLotsFixed,
					PF.intTotalLots-PF.intLotsFixed AS intBalanceNoOfLots,
					PF.intLotsHedged,
					CAST(NULL AS NUMERIC(8,4)) AS dblFinalPrice
		
		FROM		tblCTPriceFixation			PF
		JOIN		vyuCTContractDetailView		CH	ON	CH.intContractHeaderId = PF.intContractHeaderId
		WHERE		ISNULL(ysnMultiplePriceFixation,0) = 1
		GROUP BY	CH.intContractHeaderId,
					CH.strContractNumber,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					dblHeaderQuantity,
					strHeaderUnitMeasure,
					intSalespersonId,
					PF.intLotsFixed,
					PF.intTotalLots,
					PF.intLotsHedged,
					PF.intPriceFixationId
	)t
