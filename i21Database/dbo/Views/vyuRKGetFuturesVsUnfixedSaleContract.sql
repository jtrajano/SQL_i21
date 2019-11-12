CREATE VIEW [dbo].[vyuRKGetFuturesVsUnfixedSaleContract]

AS

SELECT *
FROM (
	SELECT DAP.dtmDate
		, DAP.intBookId
		, DAP.strBook
		, DAP.intSubBookId
		, DAP.strSubBook
		, DAP.intFutureMarketId
		, DAP.strFutureMarket
		, DAP.intFutureMonthId
		, DAP.strFutureMonth
		, DAP.intCommodityId
		, DAP.strCommodity
		, DAP.dblNoOfLots
		, DAP.dblNetLongAvg
		, dblUnfixedLots = ISNULL(SalesContracts.dblNoOfLots, 0)
		, dblNetPosition = DAP.dblNoOfLots - ISNULL(SalesContracts.dblNoOfLots, 0)
	FROM vyuRKGetDailyAveragePriceDetail DAP
	LEFT JOIN (
		SELECT Detail.intBookId
			, Detail.intSubBookId
			, Detail.intFutureMarketId
			, Detail.intFutureMonthId
			, Header.intCommodityId
			, dblNoOfLots = SUM(ISNULL(Detail.dblNoOfLots, 0))
		FROM tblCTContractDetail Detail
		LEFT JOIN tblCTContractHeader Header ON Header.intContractHeaderId = Detail.intContractHeaderId
		WHERE Header.intContractTypeId = 2
			AND Detail.intContractStatusId = 1
			AND Header.intPricingTypeId IN (2, 3, 5)
		GROUP BY Detail.intBookId
			, Detail.intSubBookId
			, Detail.intFutureMarketId
			, Detail.intFutureMonthId
			, Header.intCommodityId
	) SalesContracts ON SalesContracts.intBookId = DAP.intBookId
		AND SalesContracts.intSubBookId = DAP.intSubBookId
		AND SalesContracts.intFutureMarketId = DAP.intFutureMarketId
		AND SalesContracts.intFutureMonthId = DAP.intFutureMonthId
		AND SalesContracts.intCommodityId = DAP.intCommodityId
	WHERE DAP.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId FROM tblRKDailyAveragePrice ORDER BY dtmDate DESC)
)t