CREATE FUNCTION [dbo].[fnRKGetLatestAveragePrice]
(
	@Date DATETIME
	, @FutureMarketId INT
	, @FutureMonthId INT
	, @CommodityId INT
	, @BookId INT
	, @SubBookId INT
)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @LatestAvePrice NUMERIC(18, 6) = 0.00
	SELECT TOP 1 @LatestAvePrice = ISNULL(dblNetLongAvg, 0.00)
	FROM vyuRKGetDailyAveragePriceDetail
	WHERE intFutureMarketId = @FutureMarketId
		AND intFutureMonthId = @FutureMonthId
		AND intCommodityId = @CommodityId
		AND ISNULL(intBookId, 0) = ISNULL(@BookId, ISNULL(intBookId, 0))
		AND ISNULL(intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(intSubBookId, 0))
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)

	RETURN @LatestAvePrice
END
