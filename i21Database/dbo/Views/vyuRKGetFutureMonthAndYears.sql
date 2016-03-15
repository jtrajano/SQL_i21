CREATE VIEW vyuRKGetFutureMonthAndYears

AS
select convert(int,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow,* from (
SELECT top 100 percent 
LEFT(strFutureMonth,3) strFutureMonth,replace(strFutureMonth,' ','('+strSymbol+') ' ) strFutureMonthYear, intFutureMonthId,dtmFirstNoticeDate,dtmLastTradingDate,
strFutureMonth strFutureMonthYearWOSymbol,
ysnExpired,
intFutureMarketId 
FROM tblRKFuturesMonth 
order by convert(datetime,'01 '+strFutureMonth) asc)t  

