CREATE FUNCTION [dbo].[fnRKGetDAPSettlementSimulation]
(
	@intCommodityId INT
	, @intProductTypeId INT
	, @dtmDate DATETIME
	, @intBookId INT
	, @intSubBookId INT
)
RETURNS @returntable TABLE
(
	intCommodityId INT
	, intProductTypeId INT
	, dblFuturesM2M NUMERIC(24, 10)
	, dblFuturesM2MPlus NUMERIC(24, 10)
	, dblFuturesM2MMinus NUMERIC(24, 10)
)
AS
BEGIN
	INSERT INTO @returntable
	SELECT intCommodityId
		, intProductTypeId
		, dblFuturesM2M = SUM(dblFuturesM2M)
		, dblFuturesM2MPlus = SUM(dblFuturesM2MPlus)
		, dblFuturesM2MMinus = SUM(dblFuturesM2MMinus)
	FROM (
		SELECT t.*
			, dblFuturesM2MPlus = dblFuturesM2M + (dblFuturesM2M * (dblM2MSimulationPercent / 100))
			, dblFuturesM2MMinus = dblFuturesM2M - (dblFuturesM2M * (dblM2MSimulationPercent / 100))
		FROM
		(
			SELECT dap.intCommodityId
				, intProductTypeId = MAT.strCommodityAttributeId
				, dap.intFutureMarketId
				, dap.intFutureMonthId
				, dap.dblNoOfLots
				, dap.dblNetLongAvg
				, dblSettlementPrice = ISNULL(dap.dblSettlementPrice, 0)
				, dblFuturesM2M = dap.dblM2M
			FROM vyuRKGetDailyAveragePriceDetail dap
			JOIN tblRKCommodityMarketMapping MAT ON MAT.intFutureMarketId = dap.intFutureMarketId
			WHERE dap.intDailyAveragePriceId = (SELECT TOP 1 intDailyAveragePriceId
												FROM tblRKDailyAveragePrice
												WHERE ysnPosted = 1 AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
													AND ISNULL(tblRKDailyAveragePrice.intBookId, 0) = ISNULL(@intBookId, ISNULL(tblRKDailyAveragePrice.intBookId, 0))
													AND ISNULL(tblRKDailyAveragePrice.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(tblRKDailyAveragePrice.intSubBookId, 0))
												ORDER BY dtmDate DESC)
		) t
		JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = t.intFutureMarketId
	) t
	WHERE intCommodityId = ISNULL(@intCommodityId, intCommodityId)
		AND intProductTypeId = ISNULL(@intProductTypeId, intProductTypeId)
	GROUP BY intCommodityId, intProductTypeId

	RETURN
END
