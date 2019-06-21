CREATE FUNCTION [dbo].[fnRKRollToNearby]
(
	@intContractDetailId INT
	, @intFutureMarketId INT
	, @intFutureMonthId INT
	, @dblFuturePrice NUMERIC(18, 6)
)
RETURNS @Result TABLE
(
	intContractDetailId INT
	, intFutureMonthId INT
	, dblFuturePrice NUMERIC(18, 6)
	, ysnExpired INT
	, intNearByFutureMonthId INT
	, dblNearByFuturePrice NUMERIC(18, 6)
	, dblSpread NUMERIC(18, 6)
)
AS
BEGIN
	DECLARE @ysnExpired BIT = 1
		, @intNearByFutureMonthId INT
		, @intNearByFutureMarketId INT
		, @dblNearByFuturePrice NUMERIC(18, 6)
		, @dblSpread NUMERIC(18, 6)
		, @dtmFutureMonth DATETIME

	SELECT TOP 1 @ysnExpired = ysnExpired
		, @dtmFutureMonth = dtmFutureMonthsDate
	FROM tblRKFuturesMonth
	WHERE intFutureMonthId = @intFutureMonthId
	
	IF (@ysnExpired = 1)
	BEGIN
		SELECT TOP 1 @intNearByFutureMonthId = intFutureMonthId
			, @intNearByFutureMarketId = intFutureMarketId
		FROM (
			SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY intFutureMarketId, intFutureMonthId ORDER BY dtmFutureMonthsDate)
				, intFutureMonthId
				, intFutureMarketId
			FROM tblRKFuturesMonth
			WHERE intFutureMonthId <> @intFutureMonthId
				AND intFutureMarketId = @intFutureMarketId
				AND dtmFutureMonthsDate > @dtmFutureMonth
				AND ysnExpired <> 1
		) tbl WHERE intRowId = 1

		SET @dblNearByFuturePrice = dbo.fnRKGetLastSettlementPrice (@intNearByFutureMarketId, @intNearByFutureMonthId)
		SET @dblSpread = @dblFuturePrice - @dblNearByFuturePrice

		INSERT INTO @Result(intContractDetailId
			, intFutureMonthId
			, dblFuturePrice
			, ysnExpired
			, intNearByFutureMonthId
			, dblNearByFuturePrice
			, dblSpread)
		SELECT @intContractDetailId
			, @intFutureMonthId
			, @dblFuturePrice
			, @ysnExpired
			, @intNearByFutureMonthId
			, @dblNearByFuturePrice
			, @dblSpread
	END
	ELSE
	BEGIN
		INSERT INTO @Result(intContractDetailId
			, intFutureMonthId
			, dblFuturePrice
			, ysnExpired
			, intNearByFutureMonthId
			, dblNearByFuturePrice
			, dblSpread)
		SELECT @intContractDetailId
			, @intFutureMonthId
			, @dblFuturePrice
			, 0
			, NULL
			, NULL
			, NULL
	END
	RETURN
END
