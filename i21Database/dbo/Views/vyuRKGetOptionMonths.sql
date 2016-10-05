CREATE VIEW vyuRKGetOptionMonths 

AS
SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMonthId)) AS intRow,* from (
SELECT top 100 percent  LEFT(strOptionMonth,3) strOptionMonth,replace(strOptionMonth,' ','('+m.strOptSymbol+') ' )  strOptionMonthYear, 
	   intOptionMonthId,dtmFirstNoticeDate,dtmLastTradingDate as dtmLastTradingDate,   
strFutureMonth strFutureMonthYearWOSymbol,op.intFutureMonthId,strOptionMonth as strOptionMonthYearWOSymbol,op.intFutureMarketId,ysnMonthExpired
,CONVERT(DATETIME,'01 '+strOptionMonth) as dtmMonthYear 
	    FROM tblRKOptionsMonth op 
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=op.intFutureMonthId
JOIN tblRKFutureMarket m on m.intFutureMarketId=op.intFutureMarketId 
ORDER BY CONVERT(DATETIME,'01 '+strOptionMonth) ASC)t