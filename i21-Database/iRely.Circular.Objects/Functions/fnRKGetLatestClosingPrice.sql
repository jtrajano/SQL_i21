CREATE FUNCTION dbo.fnRKGetLatestClosingPrice (
	@intFutureMarketId INT
	,@intFutureMonthId INT
	,@ClosingDate DATE
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @result AS NUMERIC(18, 6)

	SELECT TOP 1 @result = dblLastSettle
	FROM tblRKFuturesSettlementPrice p
	INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
	WHERE p.intFutureMarketId = @intFutureMarketId
		AND pm.intFutureMonthId = @intFutureMonthId
		AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @ClosingDate, 111)
	ORDER BY dtmPriceDate DESC
	RETURN @result
END