CREATE PROC [dbo].[uspRKSummaryPnL] 
	@dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCommodityId INT = NULL
	,@ysnExpired BIT
	,@intFutureMarketId INT = NULL
AS
SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

IF isnull(@ysnExpired, 'False') = 'False'
BEGIN
	SELECT *
		,dblUnrealized + dblRealized AS dblTotal
	FROM (
		SELECT intFutureMarketId
			,intFutureMonthId
			,strFutMarketName
			,strFutureMonth
			,SUM(ISNULL(dblLong, 0)) intLongContracts
			,isnull(CASE WHEN SUM(LongWaitedPrice) = 0 THEN NULL ELSE SUM(LongWaitedPrice) / isnull(SUM(ISNULL(dblLong, 0)), NULL) END, 0) dblLongAvgPrice
			,SUM(ISNULL(dblShort, 0)) intShortContracts
			,isnull(CASE WHEN SUM(ShortWaitedPrice) = 0 THEN NULL ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL) END, 0) dblShortAvgPrice
			,SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS intNet
			,isnull(SUM(dblClosing), 0) dblUnrealized
			,isnull(max(dblClosing1), 0) dblClosing
			,isnull(SUM(dblFutCommission), 0) dblFutCommission
			,isnull(SUM(dblPrice), 0) AS dblPrice
			,isnull((
					SELECT SUM(dblGrossPL)
					FROM vyuRKRealizedPnL r
					WHERE u.intFutureMarketId = r.intFutureMarketId AND u.intFutureMonthId = r.intFutureMonthId
					), 0) AS dblRealized
			,ysnExpired
			,isnull(SUM(dblVariationMargin), 0) AS dblVariationMargin
			,isnull(SUM(dblInitialMargin), 0) AS dblInitialMargin
		FROM (
			SELECT *
				,(isnull(GrossPnL, 0) * (isnull(dblClosing1, 0) - isnull(dblPrice, 0))) - isnull(dblFutCommission, 0) AS dblClosing
			FROM (
				SELECT GrossPnL
					,LongWaitedPrice
					,dblLong
					,dblShort
					,ShortWaitedPrice
					,dblFutCommission
					,intNet
					,intFutOptTransactionId
					,strFutMarketName
					,strFutureMonth
					,intFutureMonthId
					,intCommodityId
					,intFutureMarketId
					,dtmTradeDate
					,intOriginalQty
					,Long1
					,Sell1
					,intNet1
					,dblActual
					,(
						SELECT dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate)
						) AS dblClosing1
					,dblPrice
					,dblContractSize
					,intConcurrencyId
					,dblFutCommission1
					,MatchLong
					,MatchShort
					,NetPnL
					,ysnExpired
					,dblVariationMargin
					,dblInitialMargin
				FROM vyuRKUnrealizedPnL
				WHERE intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END AND intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN intFutureMarketId ELSE @intFutureMarketId END AND ysnExpired = @ysnExpired AND convert(DATETIME, CONVERT(VARCHAR(10), dtmTradeDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
				
				UNION
				
				SELECT DISTINCT GrossPnL
					,LongWaitedPrice
					,dblLong
					,dblShort
					,ShortWaitedPrice
					,t.dblFutCommission
					,intNet
					,t.intFutOptTransactionId
					,t.strFutMarketName
					,t.strFutureMonth
					,t.intFutureMonthId
					,t.intCommodityId
					,t.intFutureMarketId
					,p.dtmTradeDate
					,p.intOriginalQty
					,p.Long1
					,Sell1
					,intNet1
					,dblActual
					,(
						SELECT dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, getdate())
						) AS dblClosing1
					,dblPrice
					,t.dblContractSize
					,0. intConcurrencyId
					,t.dblFutCommission1
					,MatchLong
					,MatchShort
					,NetPnL
					,t.ysnExpired
					,p.dblVariationMargin dblVariationMargin
					,p.dblInitialMargin
				FROM vyuRKRealizedPnL t
				LEFT JOIN vyuRKUnrealizedPnL p ON t.intFutureMarketId = p.intFutureMarketId AND t.intFutureMonthId = p.intFutureMonthId
				WHERE t.intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN t.intCommodityId ELSE @intCommodityId END AND t.intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN t.intFutureMarketId ELSE @intFutureMarketId END AND t.intFutureMonthId NOT IN (
						SELECT intFutureMonthId
						FROM vyuRKUnrealizedPnL
						WHERE intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END AND intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN intFutureMarketId ELSE @intFutureMarketId END AND convert(DATETIME, CONVERT(VARCHAR(10), dtmTradeDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
						) AND t.ysnExpired = @ysnExpired AND p.dtmTradeDate <= @dtmToDate
				) t
			) u
		GROUP BY intFutureMonthId
			,intFutureMarketId
			,strFutMarketName
			,strFutureMonth
			,ysnExpired
		) t
END
ELSE
BEGIN
	SELECT *
		,dblUnrealized + dblRealized AS dblTotal
	FROM (
		SELECT intFutureMarketId
			,intFutureMonthId
			,strFutMarketName
			,strFutureMonth
			,SUM(ISNULL(dblLong, 0)) intLongContracts
			,isnull(CASE WHEN SUM(LongWaitedPrice) = 0 THEN NULL ELSE SUM(LongWaitedPrice) / isnull(SUM(ISNULL(dblLong, 0)), NULL) END, 0) dblLongAvgPrice
			,SUM(ISNULL(dblShort, 0)) intShortContracts
			,isnull(CASE WHEN SUM(ShortWaitedPrice) = 0 THEN NULL ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL) END, 0) dblShortAvgPrice
			,SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS intNet
			,isnull(SUM(dblClosing), 0) dblUnrealized
			,isnull(max(dblClosing1), 0) dblClosing
			,isnull(SUM(dblFutCommission), 0) dblFutCommission
			,isnull(SUM(dblPrice), 0) AS dblPrice
			,isnull((
					SELECT SUM(dblGrossPL)
					FROM vyuRKRealizedPnL r
					WHERE u.intFutureMarketId = r.intFutureMarketId AND u.intFutureMonthId = r.intFutureMonthId
					), 0) AS dblRealized
			,ysnExpired
			,isnull(SUM(dblVariationMargin), 0) AS dblVariationMargin
			,isnull(SUM(dblInitialMargin), 0) AS dblInitialMargin
		FROM (
			SELECT *
				,(isnull(GrossPnL, 0) * (isnull(dblClosing1, 0) - isnull(dblPrice, 0))) - isnull(dblFutCommission, 0) AS dblClosing
			FROM (
				SELECT GrossPnL
					,LongWaitedPrice
					,dblLong
					,dblShort
					,ShortWaitedPrice
					,dblFutCommission
					,intNet
					,intFutOptTransactionId
					,strFutMarketName
					,strFutureMonth
					,intFutureMonthId
					,intCommodityId
					,intFutureMarketId
					,dtmTradeDate
					,intOriginalQty
					,Long1
					,Sell1
					,intNet1
					,dblActual
					,(
						SELECT dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate)
						) AS dblClosing1
					,dblPrice
					,dblContractSize
					,intConcurrencyId
					,dblFutCommission1
					,MatchLong
					,MatchShort
					,NetPnL
					,ysnExpired
					,dblVariationMargin
					,dblInitialMargin
				FROM vyuRKUnrealizedPnL
				WHERE intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END AND intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN intFutureMarketId ELSE @intFutureMarketId END AND convert(DATETIME, CONVERT(VARCHAR(10), dtmTradeDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
				
				UNION
				
				SELECT DISTINCT GrossPnL
					,LongWaitedPrice
					,dblLong
					,dblShort
					,ShortWaitedPrice
					,t.dblFutCommission
					,intNet
					,t.intFutOptTransactionId
					,t.strFutMarketName
					,t.strFutureMonth
					,t.intFutureMonthId
					,t.intCommodityId
					,t.intFutureMarketId
					,p.dtmTradeDate
					,p.intOriginalQty
					,p.Long1
					,Sell1
					,intNet1
					,dblActual
					,(
						SELECT dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, getdate())
						) AS dblClosing1
					,dblPrice
					,t.dblContractSize
					,0. intConcurrencyId
					,t.dblFutCommission1
					,MatchLong
					,MatchShort
					,NetPnL
					,t.ysnExpired
					,p.dblVariationMargin dblVariationMargin
					,p.dblInitialMargin dblInitialMargin
				FROM vyuRKRealizedPnL t
				LEFT JOIN vyuRKUnrealizedPnL p ON t.intFutureMarketId = p.intFutureMarketId AND t.intFutureMonthId = p.intFutureMonthId
				WHERE t.intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN t.intCommodityId ELSE @intCommodityId END AND t.intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN t.intFutureMarketId ELSE @intFutureMarketId END AND t.intFutureMonthId NOT IN (
						SELECT intFutureMonthId
						FROM vyuRKUnrealizedPnL
						WHERE intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN intCommodityId ELSE @intCommodityId END AND intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN intFutureMarketId ELSE @intFutureMarketId END AND convert(DATETIME, CONVERT(VARCHAR(10), dtmTradeDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
						) AND p.dtmTradeDate <= @dtmToDate
				) t
			) u
		GROUP BY intFutureMonthId
			,intFutureMarketId
			,strFutMarketName
			,strFutureMonth
			,ysnExpired
		) t
END
