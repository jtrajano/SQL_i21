﻿CREATE VIEW vyuRKGetOptionMonthSearch
AS
SELECT intOptionMonthId ,
	m.intFutureMarketId ,
	m.intCommodityMarketId ,
	strOptionMonth ,
	m.intYear ,
	m.intFutureMonthId ,
	ysnMonthExpired ,
	dtmExpirationDate ,
	strOptMonthSymbol,
	strFutureMonth,
	strOptMarketName,
	strOptionMonth strOptionMonthOriginal ,
	strCommodityCode
FROM tblRKOptionsMonth m
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=m.intFutureMonthId
JOIN tblRKFutureMarket fmar on m.intFutureMarketId=fmar.intFutureMarketId
JOIN tblICCommodity c on m.intCommodityMarketId=c.intCommodityId