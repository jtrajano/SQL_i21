CREATE VIEW dbo.vyuCTRawToWipConversion
AS

SELECT c.intRawToWipConversionId, c.intBookId, c.intSubBookId, c.intFuturesMarketId,
	c.intConcurrencyId, c.dblQuantityPerLot, m.strFutMarketName AS strFuturesMarket,
	b.strBook, sb.strSubBook, m.strFutMarketName
FROM tblCTRawToWipConversion c
INNER JOIN tblCTBook b ON b.intBookId = c.intBookId
INNER JOIN tblRKFutureMarket m ON m.intFutureMarketId = c.intFuturesMarketId
LEFT OUTER JOIN tblCTSubBook sb ON sb.intBookId = b.intBookId
	AND sb.intSubBookId = c.intSubBookId