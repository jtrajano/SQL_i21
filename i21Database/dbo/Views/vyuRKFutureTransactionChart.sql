CREATE VIEW [dbo].[vyuRKFutureTransactionChart]

AS
SELECT TOP 100 PERCENT CONVERT(int,ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,'01 '+t.strFutureMonth))) as intRowNumber,strFutureMonth,sum(dblBuy) dblBuy,sum(dblSell) dblSell from(
SELECT 
	fm.strFutureMonth,
	SUM(isnull(f.intNoOfContract,0)) dblBuy,
	isnull((SELECT SUM(isnull(ft.intNoOfContract,0)) FROM tblRKFutOptTransaction ft 
		WHERE ft.intFutureMonthId=fm.intFutureMonthId and ft.intInstrumentTypeId=1 and ft.strBuySell='Sell'
	 ),0) dblSell
FROM  tblRKFutOptTransaction f
JOIN tblRKFuturesMonth fm on f.intFutureMonthId=fm.intFutureMonthId
WHERE intInstrumentTypeId=1 and strBuySell='Buy'
GROUP BY f.strBuySell, fm.intFutureMonthId,fm.strFutureMonth,f.intInstrumentTypeId)t group by strFutureMonth
ORDER BY CONVERT(DATETIME,'01 '+t.strFutureMonth) 