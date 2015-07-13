CREATE VIEW vyuRKSummaryPnL  
  AS

  SELECT *,dblUnrealized+dblRealized as dblTotal FROM (  
  SELECT intFutureMarketId,intFutureMonthId,strFutMarketName,strFutureMonth,  
   SUM(ISNULL(dblLong,0)) intLongContracts  
  ,CASE WHEN SUM(LongWaitedPrice)=0 then null else SUM(LongWaitedPrice)/isnull(SUM(ISNULL(dblLong,0)),null)end dblLongAvgPrice  
  ,SUM(ISNULL(dblShort,0)) intShortContracts  
  ,CASE WHEN SUM(ShortWaitedPrice)=0 then null else SUM(ShortWaitedPrice)/isnull(SUM(ISNULL(dblShort,0)),null) end dblShortAvgPrice  
  ,SUM(ISNULL(dblLong,0))-SUM(ISNULL(dblShort,0)) as intNet  
  ,isnull(SUM(NetPnL),0) dblUnrealized  
  ,isnull((SELECT SUM(dblNetPL) FROM vyuRKRealizedPnL r WHERE u.intFutureMarketId=r.intFutureMarketId and u.intCommodityId=r.intCommodityId and u.intFutureMonthId=r.intFutureMonthId),0) as dblRealized  
  FROM vyuRKUnrealizedPnL u  
  GROUP BY intFutureMonthId,intCommodityId,intFutureMarketId,strFutMarketName,strFutureMonth
)t  
