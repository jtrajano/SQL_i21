CREATE VIEW vyuRKGetFutureMonthAndYears

AS
SELECT top 100 percent 
	 CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow
	,LEFT(strFutureMonth,3) COLLATE Latin1_General_CI_AS strFutureMonth
	,replace(strFutureMonth,' ','('+strSymbol+') ' ) COLLATE Latin1_General_CI_AS strFutureMonthYear
	,intFutureMonthId
	,dtmFirstNoticeDate,
	dtmLastTradingDate as dtmLastTradingDate
	,strFutureMonth strFutureMonthYearWOSymbol
	,strFutureMonth strRollingMonth
	,ysnExpired
	,CONVERT(DATETIME,'01 '+strFutureMonth) as dtmMonthYear
	,strFutureMonth +' ('+strSymbol+')' COLLATE Latin1_General_CI_AS strFutureMonthWithSymbol
	,intFutureMarketId
	,intCommodityMarketId
FROM tblRKFuturesMonth  
ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC