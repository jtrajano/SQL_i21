CREATE VIEW vyuIPGetFutureMonth
AS
SELECT F.intFutureMonthId
	,F.intConcurrencyId
	,F.strFutureMonth
	,F.intFutureMarketId
	,F.intCommodityMarketId
	,F.dtmFutureMonthsDate
	,F.strSymbol
	,F.intYear
	,F.dtmFirstNoticeDate
	,F.dtmLastNoticeDate
	,F.dtmLastTradingDate
	,F.dtmSpotDate
	,F.ysnExpired
	,F.intFutureMonthRefId
	,F.intCompanyId
	,FM.strFutMarketName
	,C.strCommodityCode
FROM tblRKFuturesMonth F WITH (NOLOCK)
LEFT JOIN tblRKFutureMarket FM WITH (NOLOCK) ON FM.intFutureMarketId = F.intFutureMarketId
LEFT JOIN tblRKCommodityMarketMapping CMM WITH (NOLOCK) ON CMM.intCommodityMarketId = F.intCommodityMarketId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = CMM.intCommodityId
