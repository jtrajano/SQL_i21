CREATE VIEW [dbo].[vyuRKCustomSettlementPrice]
AS
SELECT [Futures Market] = t.strFutMarketName
	, [Instrument Type] = 'Futures'
	, [Date] = t.dtmPriceDate
	, [Month] = m.strFutureMonth
	, [Last Settle] = t2.dblLastSettle
	, [Low] = t2.dblLow
	, [High] = t2.dblHigh
	, [Strike] = NULL
	, [Type] = t.strPricingType
	, [Settle] = NULL
	, [Delta] = NULL
	, [Future Comment] = t2.strComments
	, [Option Comment] = NULL
FROM vyuRKGetSettlementPriceHeader t
INNER JOIN tblRKFutSettlementPriceMarketMap t2
	ON t2.intFutureSettlementPriceId = t.intFutureSettlementPriceId
INNER JOIN tblRKFuturesMonth m
	ON m.intFutureMonthId = t2.intFutureMonthId

UNION

SELECT [Futures Market] = t.strFutMarketName
	, [Instrument Type] = 'Options'
	, [Date] = t.dtmPriceDate
	, [Month] = m.strOptionMonth
	, [Last Settle] = NULL
	, [Low] = NULL
	, [High] = NULL
	, [Strike] = t2.dblStrike
	, [Type] = t.strPricingType
	, [Settle] = t2.dblSettle
	, [Delta] = t2.dblDelta
	, [Future Comment] = NULL
	, [Option Comment] = t2.strComments
FROM vyuRKGetSettlementPriceHeader t
INNER JOIN tblRKOptSettlementPriceMarketMap t2
	ON t2.intFutureSettlementPriceId = t.intFutureSettlementPriceId
INNER JOIN tblRKOptionsMonth m
	ON m.intFutureMonthId = t2.intOptionMonthId