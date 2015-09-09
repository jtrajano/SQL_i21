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
					intNoOfLots,
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
					intPriceItemUOMId
		
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
					SUM(intNoOfLots)			AS	intNoOfLots,
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
					CAST (NULL AS INT)			AS	intPriceItemUOMId
		
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
					strHeaderUnitMeasure
	)t
