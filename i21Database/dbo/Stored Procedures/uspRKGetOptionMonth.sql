CREATE PROC uspRKGetOptionMonth
	@intFutureMarketId int = null

AS

SELECT LEFT(strOptionMonth,3) COLLATE Latin1_General_CI_AS strOptionMonth
	, replace(strOptionMonth,' ','('+m.strOptSymbol+') ' ) COLLATE Latin1_General_CI_AS strOptionMonthYear
	, intOptionMonthId
	, dtmFirstNoticeDate
	, dtmLastTradingDate
	, replace(strFutureMonth,' ','('+m.strFutSymbol+') ' ) COLLATE Latin1_General_CI_AS strFutureMonthYear
	, op.intFutureMonthId
FROM tblRKOptionsMonth op
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=op.intFutureMonthId
JOIN tblRKFutureMarket m on m.intFutureMarketId=op.intFutureMarketId 
WHERE op.intFutureMarketId =@intFutureMarketId  ORDER BY CONVERT(DATETIME,'01 '+strOptionMonth) ASC