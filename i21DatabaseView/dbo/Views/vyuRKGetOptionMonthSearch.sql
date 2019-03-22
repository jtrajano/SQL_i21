CREATE VIEW vyuRKGetOptionMonthSearch
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
	fmar.strOptMarketName,
	strOptionMonth strOptionMonthOriginal ,
	strCommodityCode,
	intOptionMonthCode = DATEPART(m, CONVERT(DATETIME,'01 '+ m.strOptionMonth)),
	intFutureMonthCode = DATEPART(m, CONVERT(DATETIME,'01 '+ fm.strFutureMonth)),
	m.intConcurrencyId
FROM tblRKOptionsMonth m
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=m.intFutureMonthId
JOIN tblRKFutureMarket fmar on m.intFutureMarketId=fmar.intFutureMarketId
JOIN tblRKCommodityMarketMapping cmm on fmar.intFutureMarketId = cmm.intFutureMarketId
JOIN tblICCommodity c on cmm.intCommodityId =c.intCommodityId