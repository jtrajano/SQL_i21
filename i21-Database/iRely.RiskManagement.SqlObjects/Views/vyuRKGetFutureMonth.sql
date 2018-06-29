CREATE VIEW vyuRKGetFutureMonth

AS

SELECT top 100 percent s.intFutureMonthId,
        s.intFutureMarketId,
        s.strSymbol,
        s.strFutureMonth,
        s.intConcurrencyId,
        s.intYear,
        s.dtmFirstNoticeDate,
        s.dtmLastNoticeDate,
        s.dtmLastTradingDate,
        s.dtmSpotDate,
        s.ysnExpired,
        strFutMarketName strFutMarketName,
        strFutureMonth strFutureMonthOriginal ,
        strCommodityCode strCommodityCode
FROM tblRKFuturesMonth s
join tblRKFutureMarket m on m.intFutureMarketId=s.intFutureMarketId
join tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId
join tblICCommodity c on mm.intCommodityId=c.intCommodityId
order by 1 desc