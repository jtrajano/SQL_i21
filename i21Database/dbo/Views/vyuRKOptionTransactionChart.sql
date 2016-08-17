CREATE VIEW [dbo].[vyuRKOptionTransactionChart]

AS

SELECT TOP 100 PERCENT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,'01 '+t.strOptionMonth))) as intRowNumber,strOptionMonth,sum(dblBuy) dblBuy,sum(dblSell) dblSell from(
SELECT 
	fm.strOptionMonth,
	SUM(isnull(f.intNoOfContract,0)) dblBuy,
	isnull((SELECT SUM(isnull(ft.intNoOfContract,0)) FROM tblRKFutOptTransaction ft 
		WHERE ft.intOptionMonthId=fm.intOptionMonthId and ft.intInstrumentTypeId=2 and ft.strBuySell='Sell'
	 ),0) dblSell
FROM  tblRKFutOptTransaction f
JOIN tblRKOptionsMonth fm on f.intOptionMonthId=fm.intOptionMonthId
WHERE intInstrumentTypeId=2 and strBuySell='Buy'
GROUP BY f.strBuySell, fm.intOptionMonthId,fm.strOptionMonth,f.intInstrumentTypeId)t group by strOptionMonth
order by CONVERT(DATETIME,'01 '+t.strOptionMonth) 