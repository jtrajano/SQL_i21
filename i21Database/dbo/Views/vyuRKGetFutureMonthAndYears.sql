CREATE VIEW vyuRKGetFutureMonthAndYears

AS
select CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow,* from (
SELECT top 100 percent 
LEFT(strFutureMonth,3) strFutureMonth,replace(strFutureMonth,' ','('+strSymbol+') ' ) strFutureMonthYear, intFutureMonthId,dtmFirstNoticeDate,
dtmLastTradingDate as dtmLastTradingDate,
strFutureMonth strFutureMonthYearWOSymbol,
ysnExpired,
intFutureMarketId 
FROM tblRKFuturesMonth  
ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC)t  