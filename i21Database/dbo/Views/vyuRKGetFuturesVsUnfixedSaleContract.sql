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
		SELECT 
			  intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, intCommodityId
			, dblNoOfLots = SUM(dblBalanceNoOfLots)
		FROM vyuCTSearchPriceContract WHERE intContractTypeId = 2 AND dblBalanceNoOfLots > 0 
		GROUP BY
			intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, intCommodityId
	) SalesContracts ON SalesContracts.intBookId = DAP.intBookId
		AND SalesContracts.intSubBookId = DAP.intSubBookId
		AND SalesContracts.intFutureMarketId = DAP.intFutureMarketId
		AND SalesContracts.intFutureMonthId = DAP.intFutureMonthId
		AND SalesContracts.intCommodityId = DAP.intCommodityId
	WHERE DAP.intDailyAveragePriceId IN (SELECT intDailyAveragePriceId
										FROM (
											SELECT intRowNum = ROW_NUMBER() OVER(PARTITION BY intBookId, intSubBookId ORDER BY dtmDate DESC)
												, intDailyAveragePriceId	
											FROM tblRKDailyAveragePrice
											WHERE ysnPosted = 1
										) t WHERE intRowNum = 1)
)t