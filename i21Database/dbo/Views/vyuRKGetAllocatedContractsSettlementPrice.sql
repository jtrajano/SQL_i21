CREATE VIEW [dbo].[vyuRKGetAllocatedContractsSettlementPrice]
AS

SELECT sp.intAllocatedContractsSettlementPriceId
    , sp.intAllocatedContractsGainOrLossHeaderId
    , sp.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
    , sp.intFutureMonthId
	, fMon.strFutureMonth
	, sp.intFutSettlementPriceMonthId
    , sp.dblClosingPrice
	, sp.intConcurrencyId
FROM tblRKAllocatedContractsSettlementPrice sp
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = sp.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = sp.intFutureMonthId
