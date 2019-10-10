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
	,F.intCompanyId
	,FM.strFutMarketName
	,C.strCommodityCode
FROM tblRKFuturesMonth F
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = F.intFutureMarketId
JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityMarketId = F.intCommodityMarketId
JOIN tblICCommodity C ON C.intCommodityId = CMM.intCommodityId
