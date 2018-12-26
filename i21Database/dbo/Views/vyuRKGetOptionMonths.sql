CREATE VIEW vyuRKGetOptionMonths 

AS
SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow,* from (
SELECT top 100 percent  LEFT(strOptionMonth,3) COLLATE Latin1_General_CI_AS strOptionMonth,replace(strOptionMonth,' ','('+m.strOptSymbol+') ' )  COLLATE Latin1_General_CI_AS strOptionMonthYear, 
	   intOptionMonthId,dtmFirstNoticeDate,dtmLastTradingDate as dtmLastTradingDate,   
strFutureMonth strFutureMonthYearWOSymbol,op.intFutureMonthId,strOptionMonth as strOptionMonthYearWOSymbol,op.intFutureMarketId,ysnMonthExpired
,CONVERT(DATETIME,'01 '+strOptionMonth) as dtmMonthYear 
	    FROM tblRKOptionsMonth op 
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=op.intFutureMonthId
JOIN tblRKFutureMarket m on m.intFutureMarketId=op.intFutureMarketId and isnull(ysnMonthExpired,0) =0
ORDER BY CONVERT(DATETIME,'01 '+strOptionMonth) ASC)t