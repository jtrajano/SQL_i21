CREATE VIEW vyuRKSummaryPnL  
  AS

  SELECT *,dblUnrealized+dblRealized as dblTotal FROM (  
  SELECT intFutureMarketId,intFutureMonthId,strFutMarketName,strFutureMonth,  
   SUM(ISNULL(dblLong,0)) intLongContracts  
  ,SUM(LongWaitedPrice)/SUM(ISNULL(dblLong,0)) dblLongAvgPrice  
  ,SUM(ISNULL(dblShort,0)) intShortContracts  
  ,SUM(ShortWaitedPrice)/SUM(ISNULL(dblShort,0)) dblShortAvgPrice  
  ,SUM(ISNULL(dblLong,0))-SUM(ISNULL(dblShort,0)) as intNet  
  ,isnull(SUM(NetPnL),0) dblUnrealized  
  ,isnull((SELECT SUM(dblNetPL) FROM vyuRKRealizedPnL r WHERE u.intFutureMarketId=r.intFutureMarketId and u.intCommodityId=r.intCommodityId and u.intFutureMonthId=r.intFutureMonthId),0) as dblRealized  
  FROM vyuRKUnrealizedPnL u   
  GROUP BY intFutureMonthId,intCommodityId,intFutureMarketId,strFutMarketName,strFutureMonth)t  