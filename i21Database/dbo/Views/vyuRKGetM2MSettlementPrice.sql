CREATE VIEW [dbo].[vyuRKGetM2MSettlementPrice]
AS

SELECT sp.intM2MSettlementPriceId
    , sp.intM2MHeaderId
    , sp.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
    , sp.intFutureMonthId
	, fMon.strFutureMonth
	, sp.intFutSettlementPriceMonthId
    , sp.dblClosingPrice
	, sp.intConcurrencyId
FROM tblRKM2MSettlementPrice sp
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = sp.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = sp.intFutureMonthId
