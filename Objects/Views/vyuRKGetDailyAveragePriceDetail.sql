CREATE VIEW [dbo].[vyuRKGetDailyAveragePriceDetail]

AS

SELECT Detail.intDailyAveragePriceDetailId
	, Detail.intDailyAveragePriceId
	, Header.strAverageNo
	, Header.dtmDate
	, Header.intBookId
	, Header.strBook
	, Header.intSubBookId
	, Header.strSubBook
	, Header.ysnPosted
    , Detail.intFutureMarketId
	, strFutureMarket = Market.strFutMarketName
    , Detail.intCommodityId
	, strCommodity = Commodity.strCommodityCode
    , Detail.intFutureMonthId
	, Month.strFutureMonth
    , Detail.dblNoOfLots
    , Detail.dblAverageLongPrice
    , Detail.dblSwitchPL
    , Detail.dblOptionsPL
    , Detail.dblNetLongAvg
    , Detail.intBrokerId
	, strBrokerName = Broker.strName
    , Detail.intConcurrencyId
	, Month.ysnExpired
FROM tblRKDailyAveragePriceDetail Detail
LEFT JOIN vyuRKGetDailyAveragePrice Header ON Header.intDailyAveragePriceId = Detail.intDailyAveragePriceId
LEFT JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = Detail.intFutureMarketId
LEFT JOIN tblRKFuturesMonth Month ON Month.intFutureMonthId = Detail.intFutureMonthId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Detail.intCommodityId
LEFT JOIN tblEMEntity Broker ON Broker.intEntityId = Detail.intBrokerId