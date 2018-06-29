CREATE VIEW [dbo].[vyuRKFutureMatchedChart]

AS

SELECT TOP 100 PERCENT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) as intRowNumber,sum(dblMatchQty) dblMatchQty ,strFutureMonth from(
SELECT d.dblMatchQty dblMatchQty,fm.strFutureMonth FROM tblRKMatchFuturesPSHeader h
JOIN tblRKMatchFuturesPSDetail d ON h.intMatchFuturesPSHeaderId=d.intMatchFuturesPSHeaderId
JOIN tblRKFuturesMonth fm on h.intFutureMonthId=fm.intFutureMonthId
) t GROUP BY strFutureMonth