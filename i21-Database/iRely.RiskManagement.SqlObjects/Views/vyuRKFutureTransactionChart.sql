CREATE VIEW [dbo].[vyuRKFutureTransactionChart]

AS
select TOP 100 PERCENT CONVERT(int,ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,'01 '+t.strFutureMonth))) as intRowNumber,* from (
SELECT strFutureMonth as strFutureMonth,
	sum(dblBuy) dblBuy,sum(dblSell) dblSell,intFutureMarketId,intCommodityId,intInstrumentTypeId from(
SELECT 
	fm.strFutureMonth,f.intFutureMarketId,f.intCommodityId,f.intInstrumentTypeId,
	SUM(isnull(f.intNoOfContract,0)) dblBuy,
	isnull((SELECT SUM(isnull(ft.intNoOfContract,0)) FROM tblRKFutOptTransaction ft 
		WHERE ft.intFutureMonthId=fm.intFutureMonthId and ft.intInstrumentTypeId=1 and ft.strBuySell='Sell'
	 ),0) dblSell
FROM  tblRKFutOptTransaction f
JOIN tblRKFuturesMonth fm on f.intFutureMonthId=fm.intFutureMonthId
WHERE intInstrumentTypeId=1 and strBuySell='Buy'
GROUP BY f.strBuySell, fm.intFutureMonthId,fm.strFutureMonth,f.intInstrumentTypeId,f.intFutureMarketId,f.intCommodityId)t group by strFutureMonth,intFutureMarketId,intCommodityId,intInstrumentTypeId

union
SELECT strOptionMonth as strFutureMonth,
sum(dblBuy) dblBuy,sum(dblSell) dblSell,intFutureMarketId,intCommodityId,intInstrumentTypeId from(
SELECT 
	fm.strOptionMonth,f.intFutureMarketId,f.intCommodityId,f.intInstrumentTypeId,
	SUM(isnull(f.intNoOfContract,0)) dblBuy,
	isnull((SELECT SUM(isnull(ft.intNoOfContract,0)) FROM tblRKFutOptTransaction ft 
		WHERE ft.intOptionMonthId=fm.intOptionMonthId and ft.intInstrumentTypeId=2 and ft.strBuySell='Sell'
	 ),0) dblSell
FROM  tblRKFutOptTransaction f
JOIN tblRKOptionsMonth fm on f.intOptionMonthId=fm.intOptionMonthId
WHERE intInstrumentTypeId=2 and strBuySell='Buy'
GROUP BY f.strBuySell, fm.intOptionMonthId,fm.strOptionMonth,f.intInstrumentTypeId,f.intFutureMarketId,f.intCommodityId)t group by strOptionMonth,intFutureMarketId,intCommodityId,intInstrumentTypeId
)t ORDER BY CONVERT(DATETIME,'01 '+t.strFutureMonth) 