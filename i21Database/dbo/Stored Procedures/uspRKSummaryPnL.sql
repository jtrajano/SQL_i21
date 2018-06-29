CREATE PROC [dbo].[uspRKSummaryPnL] 
	 @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCommodityId INT = NULL
	,@ysnExpired BIT
	,@intFutureMarketId INT = NULL
	,@intEntityId int = null
AS


SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)


DECLARE @UnRelaized AS TABLE 
(
intFutOptTransactionId int
,GrossPnL numeric(24,10)
,dblLong numeric(24,10)
,dblShort numeric(24,10)
,dblFutCommission numeric(24,10)
,strFutMarketName nvarchar(100)
,strFutureMonth nvarchar(100)
,dtmTradeDate datetime
,strInternalTradeNo nvarchar(100)
,strName nvarchar(100)
,strAccountNumber nvarchar(100)
,strBook nvarchar(100)
,strSubBook nvarchar(100)
,strSalespersonId nvarchar(100)
,strCommodityCode nvarchar(100)
,strLocationName nvarchar(100)
,Long1 int
,Sell1 int
,intNet int
,dblActual numeric(24,10)        
,dblClosing numeric(24,10)
,dblPrice numeric(24,10)
,dblContractSize numeric(24,10)
,dblFutCommission1 numeric(24,10)
,MatchLong numeric(24,10)
,MatchShort numeric(24,10)
,NetPnL numeric(24,10)
,intFutureMarketId int
,intFutureMonthId int
,intOriginalQty int
,intFutOptTransactionHeaderId int
,MonthOrder nvarchar(100)
,RowNum int
,intCommodityId int
,ysnExpired bit
,dblVariationMargin numeric(24,10)
,dblInitialMargin numeric(24,10)
,LongWaitedPrice numeric(24,10)
,ShortWaitedPrice numeric(24,10)
)
DECLARE @Relaized AS TABLE 
(
dblGrossPL numeric(24,10),
intMatchFuturesPSHeaderId int,
intMatchFuturesPSDetailId int,
intFutOptTransactionId int,
intLFutOptTransactionId int,
intSFutOptTransactionId int,
dblMatchQty numeric(24,10),
dtmLTransDate DateTime,
dtmSTransDate DateTime,
dblLPrice numeric(24,10),
dblSPrice numeric(24,10),
strLBrokerTradeNo nvarchar(100),
strSBrokerTradeNo nvarchar(100),
dblContractSize numeric(24,10),
dblFutCommission numeric(24,10),
strFutMarketName nvarchar(100),
strFutureMonth nvarchar(100),
intMatchNo int,
dtmMatchDate DateTime,
strName nvarchar(100),
strAccountNumber nvarchar(100),
strCommodityCode nvarchar(100),
strLocationName nvarchar(100),
dblNetPL numeric(24,10),
intFutureMarketId int,
MonthOrder nvarchar(100),
RowNum int,
intCommodityId int,
ysnExpired bit,
intFutureMonthId int
)


INSERT INTO @UnRelaized(RowNum, MonthOrder,intFutOptTransactionId ,GrossPnL ,dblLong ,dblShort ,dblFutCommission ,strFutMarketName ,strFutureMonth ,dtmTradeDate 
,strInternalTradeNo ,strName ,strAccountNumber ,strBook ,strSubBook ,strSalespersonId ,strCommodityCode ,strLocationName ,Long1 ,Sell1 ,intNet ,dblActual         
,dblClosing ,dblPrice ,dblContractSize ,dblFutCommission1 ,MatchLong ,MatchShort ,NetPnL ,intFutureMarketId ,intFutureMonthId ,intOriginalQty ,intFutOptTransactionHeaderId 
,intCommodityId ,ysnExpired ,dblVariationMargin ,dblInitialMargin ,LongWaitedPrice,ShortWaitedPrice
)
EXEC uspRKUnrealizedPnL  @dtmFromDate = @dtmFromDate, @dtmToDate=@dtmToDate,@intCommodityId = @intCommodityId,@ysnExpired = @ysnExpired,@intFutureMarketId = @intFutureMarketId ,@intEntityId=@intEntityId

INSERT INTO @Relaized(RowNum,MonthOrder,dblNetPL,dblGrossPL,intMatchFuturesPSHeaderId ,intMatchFuturesPSDetailId ,intFutOptTransactionId ,intLFutOptTransactionId ,
intSFutOptTransactionId ,dblMatchQty,dtmLTransDate ,dtmSTransDate ,dblLPrice,dblSPrice,strLBrokerTradeNo,strSBrokerTradeNo,dblContractSize,dblFutCommission,
strFutMarketName,strFutureMonth,intMatchNo ,dtmMatchDate ,strName,strAccountNumber,strCommodityCode,strLocationName,intFutureMarketId ,intCommodityId ,ysnExpired,intFutureMonthId 
)
EXEC uspRKRealizedPnL  @dtmFromDate = @dtmFromDate, @dtmToDate=@dtmToDate,@intCommodityId = @intCommodityId,@ysnExpired = @ysnExpired,@intFutureMarketId = @intFutureMarketId ,@intEntityId=@intEntityId


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
			,isnull(SUM(NetPnL), 0) dblUnrealized
			,isnull(max(dblClosing), 0) dblClosing
			,isnull(SUM(dblFutCommission), 0) dblFutCommission
			,isnull(SUM(dblPrice), 0) AS dblPrice
			,isnull((
					SELECT SUM(dblGrossPL)
					FROM vyuRKRealizedPnL r
					WHERE t.intFutureMarketId = r.intFutureMarketId AND t.intFutureMonthId = r.intFutureMonthId
					), 0) AS dblRealized
			,isnull(SUM(dblVariationMargin), 0) AS dblVariationMargin
			,isnull(SUM(dblInitialMargin), 0) AS dblInitialMargin
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
					,dblClosing AS dblClosing
					,dblPrice														
					,NetPnL					
					,dblVariationMargin
					,dblInitialMargin
				FROM @UnRelaized				
				
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
					,dblClosing AS dblClosing
					,dblPrice										
					,NetPnL					
					,dblVariationMargin
					,dblInitialMargin
				FROM @Relaized t
				LEFT JOIN @UnRelaized p ON t.intFutureMarketId = p.intFutureMarketId AND t.intFutureMonthId = p.intFutureMonthId
				WHERE t.intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN t.intCommodityId ELSE @intCommodityId END 
				AND t.intFutureMarketId = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN t.intFutureMarketId ELSE @intFutureMarketId END AND t.intFutureMonthId NOT IN (
						SELECT intFutureMonthId
						FROM @UnRelaized						
						) 
				) t
			
		GROUP BY intFutureMonthId
			,intFutureMarketId
			,strFutMarketName
			,strFutureMonth
		) t
END