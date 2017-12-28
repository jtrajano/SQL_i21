CREATE FUNCTION dbo.fnRKGetVariationMargin (
	 @intFutOptTransactionId INT
	,@ClosingDate DATE
	,@dtmTradeDate DATE
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @result AS NUMERIC(18, 6)
	DECLARE @dblLastSettle INT
	DECLARE @intFutureMarketId INT
	DECLARE @intFutureMonthId INT
	DECLARE @strBuySell nvarchar(10)
	SELECT @intFutureMarketId=intFutureMarketId,@intFutureMonthId=intFutureMonthId,@strBuySell=strBuySell FROM tblRKFutOptTransaction WHERE intFutOptTransactionId=@intFutOptTransactionId

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
		WHERE intRowNum = 1

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
		WHERE intRowNum = 2
				
		if @strBuySell='Buy'
			SET @result = @dblLastSettle2-@dblLastSettle1	
		else
			SET @result = @dblLastSettle1-@dblLastSettle2
	END
	ELSE
	BEGIN
		SET @result = 0
	END

	RETURN @result
END
