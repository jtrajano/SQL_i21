CREATE PROC uspRKSummaryPnL
    @dtmToDate datetime,
	@intCommodityId int = null,
	@ysnExpired bit
 AS  
  
if isnull(@ysnExpired,'False' ) = 'False'
BEGIN
SELECT *
	,dblUnrealized + dblRealized AS dblTotal
FROM (
	SELECT intFutureMarketId
		,intFutureMonthId
		,strFutMarketName
		,strFutureMonth
		,SUM(ISNULL(dblLong, 0)) intLongContracts
		,CASE 
			WHEN SUM(LongWaitedPrice) = 0
				THEN NULL
			ELSE SUM(LongWaitedPrice) / isnull(SUM(ISNULL(dblLong, 0)), NULL)
			END dblLongAvgPrice
		,SUM(ISNULL(dblShort, 0)) intShortContracts
		,CASE 
			WHEN SUM(ShortWaitedPrice) = 0
				THEN NULL
			ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL)
			END dblShortAvgPrice
		,SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS intNet
		,isnull(SUM(dblClosing), 0) dblUnrealized
		,isnull(max(dblClosing1), 0) dblClosing
		,isnull(SUM(dblFutCommission), 0) dblFutCommission
		,isnull(SUM(dblPrice), 0) AS dblPrice
		,isnull((
				SELECT SUM(dblGrossPL)
				FROM vyuRKRealizedPnL r
				WHERE u.intFutureMarketId = r.intFutureMarketId
					AND u.intFutureMonthId = r.intFutureMonthId
				), 0) AS dblRealized,ysnExpired
	FROM (
		SELECT *
			,(isnull(GrossPnL, 0) * (isnull(dblClosing1,0) - isnull(dblPrice,0)))-isnull(dblFutCommission,0) AS dblClosing
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
				,(SELECT dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate)
				  ) AS dblClosing1
				,dblPrice
				,dblContractSize
				,intConcurrencyId
				,dblFutCommission1
				,MatchLong
				,MatchShort
				,NetPnL,ysnExpired
			FROM vyuRKUnrealizedPnL where intCommodityId= case when isnull(@intCommodityId,0)=0 then intCommodityId else @intCommodityId end and ysnExpired=@ysnExpired
			and dtmTradeDate >= @dtmToDate
			) t
		) u
	GROUP BY intFutureMonthId
		,intFutureMarketId
		,strFutMarketName
		,strFutureMonth,ysnExpired
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
		,CASE 
			WHEN SUM(LongWaitedPrice) = 0
				THEN NULL
			ELSE SUM(LongWaitedPrice) / isnull(SUM(ISNULL(dblLong, 0)), NULL)
			END dblLongAvgPrice
		,SUM(ISNULL(dblShort, 0)) intShortContracts
		,CASE 
			WHEN SUM(ShortWaitedPrice) = 0
				THEN NULL
			ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL)
			END dblShortAvgPrice
		,SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS intNet
		,isnull(SUM(dblClosing), 0) dblUnrealized
		,isnull(max(dblClosing1), 0) dblClosing
		,isnull(SUM(dblFutCommission), 0) dblFutCommission
		,isnull(SUM(dblPrice), 0) AS dblPrice
		,isnull((
				SELECT SUM(dblGrossPL)
				FROM vyuRKRealizedPnL r
				WHERE u.intFutureMarketId = r.intFutureMarketId
					AND u.intFutureMonthId = r.intFutureMonthId
				), 0) AS dblRealized,ysnExpired
	FROM (
		SELECT *
			,(isnull(GrossPnL, 0) * (isnull(dblClosing1,0) - isnull(dblPrice,0)))-isnull(dblFutCommission,0) AS dblClosing
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
				,(SELECT dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate)
				  ) AS dblClosing1
				,dblPrice
				,dblContractSize
				,intConcurrencyId
				,dblFutCommission1
				,MatchLong
				,MatchShort
				,NetPnL,ysnExpired
			FROM vyuRKUnrealizedPnL where intCommodityId= case when isnull(@intCommodityId,0)=0 then intCommodityId else @intCommodityId end 
			and dtmTradeDate >= @dtmToDate
			) t
		) u
	GROUP BY intFutureMonthId
		,intFutureMarketId
		,strFutMarketName
		,strFutureMonth,ysnExpired
	) t
	END