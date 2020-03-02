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
	  ,O.intOptionMonthRefId
      ,O.intCompanyId
	  ,FM.strFutMarketName
	  ,C.strCommodityCode
	  ,F.strFutureMonth
FROM tblRKOptionsMonth O WITH (NOLOCK)
LEFT JOIN tblRKFutureMarket FM WITH (NOLOCK) ON FM.intFutureMarketId = O.intFutureMarketId
LEFT JOIN tblRKCommodityMarketMapping CMM WITH (NOLOCK) ON CMM.intCommodityMarketId = O.intCommodityMarketId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = CMM.intCommodityId
LEFT JOIN tblRKFuturesMonth F WITH (NOLOCK) ON F.intFutureMonthId = O.intFutureMonthId
