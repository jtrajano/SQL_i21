CREATE VIEW vyuCTLimitsForDerivative
AS
SELECT l.intBookId
	,l.intLimitId
	,l.intFutureMarketId
	,l.intFutureMonthId
	,l.intCommodityId
	,l.intSubBookId
	,l.dblLimit
	,fm.strFutMarketName
	,replace(m.strFutureMonth, ' ', '(' + strSymbol + ') ') strFutureMonth
	,c.strCommodityCode
	,sb.strSubBook
	,l.intConcurrencyId
FROM tblCTLimit l
JOIN tblCTBook b ON b.intBookId = l.intBookId
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = l.intFutureMarketId
JOIN tblICCommodity c ON c.intCommodityId = l.intCommodityId
JOIN tblCTSubBook sb ON sb.intSubBookId = l.intSubBookId
LEFT JOIN tblRKFuturesMonth m ON m.intFutureMonthId = l.intFutureMonthId