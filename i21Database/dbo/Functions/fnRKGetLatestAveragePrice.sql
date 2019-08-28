CREATE FUNCTION [dbo].[fnRKGetLatestAveragePrice]
(
	@Date DATETIME
	, @FutureMarketId INT
	, @FutureMonthId INT
	, @CommodityId INT
	, @BookId INT
	, @SubBookId INT
)
RETURNS @Result TABLE
(
	intDailyAveragePriceDetailId INT
	, dblLatestAveragePrice NUMERIC(18, 6)
	, dblNoOfLots NUMERIC(18, 6)
)
AS
BEGIN
	INSERT INTO @Result(intDailyAveragePriceDetailId
		, dblLatestAveragePrice
		, dblNoOfLots)
	SELECT TOP 1 intDailyAveragePriceDetailId
		, dblAverageLongPrice + dblSwitchPL + dblOptionsPL
		, dblNoOfLots - (SELECT ISNULL(SUM(ISNULL(dblNoOfLots, 0)), 0) FROM tblCTPriceFixationDetail CT WHERE CT.intDailyAveragePriceDetailId = vyuRKGetDailyAveragePriceDetail.intDailyAveragePriceDetailId)
	FROM vyuRKGetDailyAveragePriceDetail
	WHERE intFutureMarketId = @FutureMarketId
		AND intFutureMonthId = @FutureMonthId
		AND intCommodityId = @CommodityId
		AND ISNULL(intBookId, 0) = ISNULL(@BookId, ISNULL(intBookId, 0))
		AND ISNULL(intSubBookId, 0) = ISNULL(@SubBookId, ISNULL(intSubBookId, 0))
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@Date AS FLOAT)) AS DATETIME)
		AND ysnPosted = 1
		AND ysnExpired = 0
	RETURN
END
