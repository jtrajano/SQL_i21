CREATE VIEW vyuRKGetFutureMonthAndYears

AS

SELECT TOP 100 PERCENT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow
	, LEFT(strFutureMonth, 3) COLLATE Latin1_General_CI_AS strFutureMonth
	, REPLACE(strFutureMonth, ' ', '(' + strSymbol + ') ') COLLATE Latin1_General_CI_AS strFutureMonthYear
	, intFutureMonthId
	, dtmFirstNoticeDate
	, dtmLastTradingDate as dtmLastTradingDate
	, strFutureMonth strFutureMonthYearWOSymbol
	, strFutureMonth strRollingMonth
	, ysnExpired
	, CONVERT(DATETIME,'01 '+strFutureMonth) as dtmMonthYear
	, (strFutureMonth + ' (' + strSymbol + ')') COLLATE Latin1_General_CI_AS strFutureMonthWithSymbol
	, intFutureMarketId
	, intCommodityMarketId
FROM tblRKFuturesMonth  
ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC