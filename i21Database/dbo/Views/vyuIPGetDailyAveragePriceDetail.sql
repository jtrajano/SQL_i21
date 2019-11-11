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
	,D.intBrokerId
	,D.intConcurrencyId
	,FM.strFutMarketName
	,FMON.strFutureMonth
	,FMON.ysnExpired
	,C.strCommodityCode
	,B.strName
FROM tblRKDailyAveragePriceDetail D
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = D.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMON ON FMON.intFutureMonthId = D.intFutureMonthId
LEFT JOIN tblICCommodity C ON C.intCommodityId = D.intCommodityId
LEFT JOIN tblEMEntity B ON B.intEntityId = D.intBrokerId
