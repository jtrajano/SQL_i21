CREATE VIEW vyuIPGetDailyAveragePriceDetail
AS
SELECT D.intDailyAveragePriceDetailId
	,D.intDailyAveragePriceId
	,D.intFutureMarketId
	,D.intCommodityId
	,D.intFutureMonthId
	,D.dblNoOfLots
	,D.dblAverageLongPrice
	,D.dblSwitchPL
	,D.dblOptionsPL
	,D.dblNetLongAvg
	,D.dblSettlementPrice
	,D.intBrokerId
	,D.intDailyAveragePriceDetailRefId
	,D.intConcurrencyId
	,FM.strFutMarketName
	,FMON.strFutureMonth
	,FMON.ysnExpired
	,C.strCommodityCode
	,B.strName
FROM tblRKDailyAveragePriceDetail D WITH (NOLOCK)
LEFT JOIN tblRKFutureMarket FM WITH (NOLOCK) ON FM.intFutureMarketId = D.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMON WITH (NOLOCK) ON FMON.intFutureMonthId = D.intFutureMonthId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = D.intCommodityId
LEFT JOIN tblEMEntity B WITH (NOLOCK) ON B.intEntityId = D.intBrokerId
