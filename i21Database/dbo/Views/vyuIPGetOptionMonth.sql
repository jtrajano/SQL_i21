CREATE VIEW vyuIPGetOptionMonth
AS
SELECT O.intOptionMonthId
      ,O.intConcurrencyId
      ,O.intFutureMarketId
      ,O.intCommodityMarketId
      ,O.strOptionMonth
      ,O.intYear
      ,O.intFutureMonthId
      ,O.ysnMonthExpired
      ,O.dtmExpirationDate
      ,O.strOptMonthSymbol
      ,O.intCompanyId
	  ,FM.strFutMarketName
	  ,C.strCommodityCode
	  ,F.strFutureMonth
FROM tblRKOptionsMonth O
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = O.intFutureMarketId
JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityMarketId = O.intCommodityMarketId
JOIN tblICCommodity C ON C.intCommodityId = CMM.intCommodityId
JOIN tblRKFuturesMonth F ON F.intFutureMonthId = O.intFutureMonthId
