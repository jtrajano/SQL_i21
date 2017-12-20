CREATE FUNCTION dbo.fnRKGetVariationMargin (
	@intFutureMarketId INT
	,@intFutureMonthId INT
	,@ClosingDate DATE
	,@dtmTradeDate DATE
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @result AS NUMERIC(18, 6)

	DECLARE @dblLastSettle INT

	SELECT @dblLastSettle = count(dblLastSettle)
	FROM tblRKFuturesSettlementPrice p
	INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
	WHERE p.intFutureMarketId = @intFutureMarketId AND pm.intFutureMonthId = @intFutureMonthId AND CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @ClosingDate, 111)
	IF(@dtmTradeDate=@ClosingDate)
	BEGIN
	SET @result = 0
	END
	ELSE
	 IF (isnull(@dblLastSettle, 0) > 1)
	BEGIN
		DECLARE @dblLastSettle1 NUMERIC(24, 10)
			,@dblLastSettle2 NUMERIC(24, 10)

		SELECT @dblLastSettle1 = dblLastSettle
		FROM (
			SELECT TOP 2 ROW_NUMBER() OVER (
					ORDER BY dtmPriceDate DESC
					) intRowNum
				,dblLastSettle
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			WHERE p.intFutureMarketId = @intFutureMarketId AND pm.intFutureMonthId = @intFutureMonthId 
			AND CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @ClosingDate, 111)
			ORDER BY dtmPriceDate DESC
			) t
		WHERE intRowNum = 1

		SELECT @dblLastSettle2 = dblLastSettle
		FROM (
			SELECT TOP 2 ROW_NUMBER() OVER (
					ORDER BY dtmPriceDate DESC
					) intRowNum
				,dblLastSettle
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			WHERE p.intFutureMarketId = @intFutureMarketId AND pm.intFutureMonthId = @intFutureMonthId 
			AND CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @ClosingDate, 111)
			ORDER BY dtmPriceDate DESC
			) t
		WHERE intRowNum = 2

		SET @result = @dblLastSettle2-@dblLastSettle1
	END
	ELSE
	BEGIN
		SET @result = 0
	END

	RETURN @result
END
