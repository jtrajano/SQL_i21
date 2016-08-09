CREATE VIEW vyuRKGetFutureMonthAndYears

AS
SELECT top 100 percent CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow,
LEFT(strFutureMonth,3) strFutureMonth,replace(strFutureMonth,' ','('+strSymbol+') ' ) strFutureMonthYear, intFutureMonthId,dtmFirstNoticeDate,
dtmLastTradingDate as dtmLastTradingDate,
strFutureMonth strFutureMonthYearWOSymbol,
ysnExpired,
intFutureMarketId,CONVERT(DATETIME,'01 '+strFutureMonth) as dtmMonthYear 
FROM tblRKFuturesMonth  
ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC 