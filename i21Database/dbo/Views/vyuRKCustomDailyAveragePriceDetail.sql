CREATE VIEW [dbo].[vyuRKCustomDailyAveragePriceDetail]
AS
SELECT [Daily Average Price Detail Id] = t.intDailyAveragePriceDetailId
	, [Daily Average Price Id] = t.intDailyAveragePriceId
	, [Average No] = t.strAverageNo
	, [Date] = t.dtmDate
	, [Book Id] = t.intBookId
	, [Book] = t.strBook
	, [Sub Book Id] = t.intSubBookId
	, [Sub Book] = t.strSubBook
	, [Posted] = t.ysnPosted
	, [Future Market Id] = t.intFutureMarketId
	, [Future Market] = t.strFutureMarket
	, [Commodity Id] = t.intCommodityId
	, [Commodity] = t.strCommodity
	, [Future Month Id] = t.intFutureMonthId
	, [Future Month] = t.strFutureMonth
	, [No Of Lots] = t.dblNoOfLots
	, [Average Long Price] = t.dblAverageLongPrice
	, [Switch PL] = t.dblSwitchPL
	, [Options PL] = t.dblOptionsPL
	, [Net Long Avg] = t.dblNetLongAvg
	, [Broker Name] = t.strBrokerName
	, [Settlement Price] = t.dblSettlementPrice
	, [M2M] = t.dblM2M
	, [Tonnage] = t.dblTonnage
FROM vyuRKGetDailyAveragePriceDetail t